import { check, exact, encodeJSON, decodeJSON, prepareManifest, deepFreeze, PluginError } from './contract.mjs';

/** DOM-free plugin lifetime and commit authority, shared by browser and headless hosts. */
export function createPluginHost(editor) {
  const entries = new Map(), listeners = new Set(); let disposed = false;
  function notify() { for (const listener of listeners) { try { listener(); } catch (error) { console.error('Plugin catalog listener failed', error); } } }
  function release(entry) {
    entry.lifetime.abort();
    try { Promise.resolve(entry.transport.dispose?.()).catch(error => console.error('Plugin dispose failed', error)); } catch (error) { console.error('Plugin dispose failed', error); }
  }
  function alive(entry, signal) { check(!disposed && !entry.lifetime.signal.aborted && !signal?.aborted && entries.get(entry.manifest.id) === entry, 'Plugin invocation canceled', 'canceled'); }
  async function invokeEntry(entry, name, args, options = {}) {
    try {
      alive(entry, options.signal);
      const tool = entry.manifest.tools.find(tool => tool.name === name);
      check(tool, 'Unknown plugin tool');
      const input = decodeJSON(encodeJSON(args)), validator = entry.validators.get(name);
      check(validator.input(input), 'Plugin arguments do not match inputSchema');
      const snapshot = editor.snapshot();
      if (tool.effect === 'transaction') check(Number.isInteger(options.expectedRevision) && snapshot.revision === options.expectedRevision, 'Editor changed; expectedRevision is required', 'conflict');
      const signal = options.signal ? AbortSignal.any([entry.lifetime.signal, options.signal]) : entry.lifetime.signal;
      const request = encodeJSON({ apiVersion: 1, tool: name, arguments: input, snapshot });
      let abort;
      const canceled = new Promise((_, reject) => { abort = () => reject(new PluginError('canceled', 'Plugin invocation canceled')); signal.addEventListener('abort', abort, { once: true }); });
      let source;
      try { source = await Promise.race([entry.transport.invoke(request, { signal }), canceled]); }
      finally { signal.removeEventListener('abort', abort); }
      alive(entry, signal);
      const response = decodeJSON(source); exact(response, ['result', 'commands']);
      check(Object.hasOwn(response, 'result'), 'Plugin result is required');
      check(!validator.output || validator.output(response.result), 'Plugin result does not match outputSchema');
      if (tool.effect === 'read') {
        check(response.commands === undefined, 'Read tool cannot return commands');
        return { ok: true, result: response.result, revision: snapshot.revision };
      }
      check(Array.isArray(response.commands) && response.commands.length >= 1 && response.commands.length <= 100, 'Transaction tool must return 1-100 commands');
      const committed = editor.dispatch({ expectedRevision: options.expectedRevision, commands: response.commands });
      if (!committed.ok) return committed;
      return { ok: true, result: response.result, revision: committed.snapshot.revision };
    } catch (error) {
      return { ok: false, error: { code: error.code ?? 'plugin_error', message: error.message }, revision: editor.snapshot().revision };
    }
  }
  return Object.freeze({
    register(plugin) {
      check(!disposed, 'Plugin host disposed');
      check(plugin?.transport && typeof plugin.transport.invoke === 'function' && (plugin.mount === undefined || typeof plugin.mount === 'function'), 'Invalid plugin transport or mount');
      const prepared = prepareManifest(plugin.manifest), id = prepared.manifest.id;
      check(entries.has(id) || entries.size < 32, 'Plugin limit is 32');
      check(plugin.transport.dispose === undefined || typeof plugin.transport.dispose === 'function', 'Invalid plugin dispose');
      const transport = { invoke: plugin.transport.invoke.bind(plugin.transport), dispose: plugin.transport.dispose?.bind(plugin.transport) };
      const entry = { ...prepared, transport, lifetime: new AbortController() };
      entry.tools = entry.manifest.tools.map(tool => {
        const properties = { arguments: tool.inputSchema };
        if (tool.effect === 'transaction') properties.expectedRevision = { type: 'integer', minimum: 0, maximum: 2147483647 };
        return deepFreeze({
          name: `kagura.pane.${id}.${tool.name}`, description: tool.description,
          inputSchema: { type: 'object', properties, required: Object.keys(properties), additionalProperties: false },
          annotations: { readOnlyHint: tool.effect === 'read', untrustedContentHint: true },
          async execute(input, options = {}) {
            try {
              alive(entry, options.signal); exact(input, Object.keys(properties));
              return await invokeEntry(entry, tool.name, input.arguments, { expectedRevision: input.expectedRevision, signal: options.signal });
            } catch (error) { return { ok: false, error: { code: error.code ?? 'invalid', message: error.message }, revision: editor.snapshot().revision }; }
          },
        });
      });
      const previous = entries.get(id); entries.set(id, entry); if (previous) release(previous);
      notify(); return decodeJSON(encodeJSON(entry.manifest));
    },
    unregister(id) { const entry = entries.get(id); if (entry) { entries.delete(id); release(entry); notify(); } },
    has: id => entries.has(id),
    tools: () => [...entries.values()].flatMap(entry => entry.tools),
    list: () => [...entries.values()].map(entry => decodeJSON(encodeJSON(entry.manifest))),
    subscribe(listener) { listeners.add(listener); return () => listeners.delete(listener); },
    async invoke(id, name, args, options) {
      const entry = entries.get(id);
      if (!entry) return { ok: false, error: { code: 'invalid', message: 'Unknown pane plugin' }, revision: editor.snapshot().revision };
      return invokeEntry(entry, name, args, options);
    },
    dispose() { disposed = true; for (const entry of entries.values()) release(entry); entries.clear(); notify(); listeners.clear(); },
  });
}
