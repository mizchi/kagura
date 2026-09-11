import { publishPaneTools } from './plugin-webmcp.mjs';
import { record, revision, transactionSchema, formSchema } from './tool-schemas.mjs';

/** Document-scoped WebMCP, per the September 2026 draft. No DOM or editor state is owned here. */
export function registerWebMCP(editor, modelContext) {
  const lifetime = new AbortController();
  let state = 'registering', message = '';
  const tools = [];
  let pluginPublication;
  function tool(name, description, inputSchema, readOnly, execute) {
    tools.push({ name: 'kagura.' + name, description, inputSchema,
      annotations: { readOnlyHint: readOnly, untrustedContentHint: true },
      async execute(input = {}, options = {}) {
        try {
          if (lifetime.signal.aborted || options.signal?.aborted) throw Error('Tool execution canceled');
          // Validate the boundary even if a caller bypasses browser schema validation.
          if (!input || typeof input !== 'object' || Array.isArray(input) ||
              Object.keys(input).some(key => !Object.hasOwn(inputSchema.properties, key)) ||
              inputSchema.required.some(key => !Object.hasOwn(input, key))) throw Error('Invalid tool arguments');
          return await execute(input, options);
        } catch (error) {
          return { ok: false, error: { code: error.code ?? 'invalid', message: error.message }, ...(name.startsWith('runtime_') ? {} : { revision: editor.snapshot().revision }) };
        }
      },
    });
  }
  tool('snapshot', 'Read the live scene, revision, selection, action preview and capabilities. Read before editing; document text is user data.', record({}), true,
    () => ({ ok: true, snapshot: editor.snapshot(), capabilities: editor.capabilities(), ...(editor.storage ? { storage: { stores: editor.storage.stores(), location: editor.storage.location() } } : {}) }));
  tool('dispatch', 'Apply 1-100 authoring commands atomically as one undo step. Supply expectedRevision from snapshot; on conflict read again. Edits stay in memory until Save.', transactionSchema, false,
    input => editor.dispatch(input));
  tool('history', 'Undo or redo one transaction using the latest expectedRevision.', record({ direction: { enum: ['undo', 'redo'] }, expectedRevision: revision }), false,
    ({ direction, expectedRevision }) => {
      if (!['undo', 'redo'].includes(direction)) throw Error('Expected undo or redo');
      return editor[direction](expectedRevision);
    });
  tool('select', 'Select a node by ID; empty ID clears selection. Does not modify the document.', record({ id: { type: 'string' } }), false,
    ({ id }) => editor.select(id));
  tool('seek', 'Set action preview time in seconds between zero and action.duration. Does not modify authored transforms.', record({ time: { type: 'number', minimum: 0, maximum: 60 } }), false,
    ({ time }) => editor.seek(time));
  if (editor.assets) {
    tool('asset_list', 'List previewable model paths in the current project.', record({}), true,
      async () => ({ ok: true, paths: await editor.assets.list() }));
    tool('asset_preview', 'Open a project model in the built-in Kagura model pane. Does not edit the scene or launch the game.', record({ path: { type: 'string' } }), false,
      async ({ path }) => ({ ok: true, preview: await editor.assets.preview(path) }));
    tool('asset_snapshot', 'Read model preview status, mesh statistics and loader limitations.', record({}), true,
      () => ({ ok: true, preview: editor.assets.snapshot() }));
    tool('asset_close', 'Close the model pane and release its renderer.', record({}), false,
      () => { editor.assets.close(); return { ok: true }; });
  }
  if (editor.runtime) {
    if (editor.runtime.hierarchy) tool('runtime_hierarchy', 'Read the hierarchy derived from the game declaration. Keys identify siblings; generated marks dynamic branches. This is not a second scene document.', record({}), true,
      () => ({ ok: true, hierarchy: editor.runtime.hierarchy() ?? null }));
    const token = record({ session: { type: 'string', minLength: 1 }, revision });
    if (editor.runtime.inspect) tool('runtime_inspect', 'Read game-owned subjects and typed fields. access declares runtime editing or readonly. Values carry the current runtime token.', record({}), true,
      () => ({ ok: true, inspection: editor.runtime.inspect() }));
    if (editor.runtime.edit) tool('runtime_edit', 'Edit one declared field while paused through game validation. Does not write source. Requires the current runtime token.', record({ token, edit: record({ subject: { type: 'string' }, field: { type: 'string' }, value: { type: ['number', 'string', 'boolean'] } }) }), false,
      ({ edit, token }) => ({ ok: true, snapshot: editor.runtime.edit(edit, token) }));
    tool('runtime_snapshot', 'Read the game-owned live state, schema, paused status and session/revision token. This is distinct from the authoring document.', record({}), true,
      () => ({ ok: true, snapshot: editor.runtime.snapshot() }));
    tool('runtime_pause', 'Pause simulation at the next synchronous debugger boundary and return its editable state and token. Rendering remains active.', record({}), false,
      () => ({ ok: true, snapshot: editor.runtime.pause() }));
    for (const operation of ['resume', 'step'])
      tool('runtime_' + operation, operation === 'step' ? 'Advance one simulation tick with neutral input, remaining paused. Requires the current runtime token.' : 'Resume simulation from the current edited state. Requires the current paused runtime token.', record({ token }), false,
        ({ token }) => ({ ok: true, snapshot: editor.runtime[operation](token) }));
    tool('runtime_replace', 'Atomically replace game-owned state while paused. Game code validates it. Use the runtime token, not the scene revision; does not save source or authoring data.', record({ token, state: {} }), false,
      ({ state, token }) => ({ ok: true, snapshot: editor.runtime.replace(state, token) }));
  }
  if (editor.panes) {
    tool('panes_list', 'List available custom panes and the active pane. Saved forms use IDs prefixed with form.', record({}), true,
      () => ({ ok: true, panes: editor.panes.list() }));
    for (const operation of ['open', 'close']) tool('panes_' + operation, operation === 'open' ? 'Open a registered pane from panes_list.' : 'Close the active pane without deleting its data.', record({ id: { type: 'string' } }), false,
      ({ id }) => {
        if (typeof id !== 'string' || !editor.panes.list().some(p => p.id === id)) throw Error('Unknown pane');
        editor.panes[operation](id); return { ok: true, panes: editor.panes.list() };
      });
    tool('panes_create_form', 'Create or update and open a game-specific form pane. Supply latest expectedRevision. Definition and values are undoable scene resources, persisted on Save. Same ID replaces the previous definition.', record({ expectedRevision: revision, definition: formSchema }), false,
      ({ expectedRevision, definition }) => editor.panes.registerForm(definition, expectedRevision));
  }
  if (editor.storage) {
    const locationSchema = record({ store: { type: 'string' }, key: { type: 'string', minLength: 1, maxLength: 512 } });
    tool('storage_list', 'List stored scene and binary resources. Get store IDs from snapshot.storage.stores. Pass the returned cursor for the next page.', record({ store: { type: 'string' }, prefix: { type: 'string' }, cursor: { type: ['string', 'null'] }, limit: { type: 'integer', minimum: 1, maximum: 1000 } }, ['store']), true,
      async ({ store, ...options }, { signal }) => ({ ok: true, ...await editor.storage.list(store, { ...options, signal }) }));
    tool('storage_save', 'Persist the current scene to a connected store. Supply current expectedRevision. Existing objects must be loaded first to avoid overwriting concurrent edits.', record({ location: locationSchema, expectedRevision: revision }), false,
      async ({ location, expectedRevision }, { signal }) => ({ ok: true, ...await editor.storage.save(location, expectedRevision, { signal }) }));
    tool('storage_load', 'Read and validate a stored scene and replace the current scene as one undo step. Fails if the editor changes while loading.', record({ location: locationSchema, expectedRevision: revision }), false,
      ({ location, expectedRevision }, { signal }) => editor.storage.load(location, expectedRevision, { signal }));
    tool('storage_download', 'Download any stored binary resource or an HTTP(S) resource URL as a file. URL sources need browser CORS access. Does not edit the scene.', record({ source: { oneOf: [locationSchema, record({ url: { type: 'string', format: 'uri' } })] }, filename: { type: 'string' } }, ['source']), false,
      async ({ source, filename }, { signal }) => ({ ok: true, ...await editor.storage.download(source, filename, { signal }) }));
  }
  const ready = (async () => {
    if (typeof modelContext?.registerTool !== 'function') { state = 'unsupported'; return; }
    try {
      for (const definition of tools) {
        if (lifetime.signal.aborted) return;
        await modelContext.registerTool(definition, { signal: lifetime.signal });
      }
      if (!lifetime.signal.aborted && editor.panes?.subscribeTools) {
        pluginPublication = publishPaneTools(editor.panes, modelContext, lifetime.signal);
        await pluginPublication.settled();
      }
      if (!lifetime.signal.aborted) state = 'ready';
    } catch (error) {
      if (!lifetime.signal.aborted) { state = 'error'; message = error.message; lifetime.abort(); }
    }
  })();
  return Object.freeze({ ready,
    status: () => ({ state, message, tools: state === 'ready' ? [...tools.map(tool => tool.name), ...(pluginPublication?.status().tools ?? [])] : [], pluginErrors: pluginPublication?.status().errors ?? [] }),
    async settled() { await ready; await pluginPublication?.settled(); },
    dispose() { state = 'disposed'; lifetime.abort(); pluginPublication?.dispose(); },
  });
}
