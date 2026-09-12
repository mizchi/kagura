import { createPluginHost } from '../plugins/host.mjs';
import { pluginPane } from './plugin-pane.mjs';
import { FORM_KIND, validId, validateForm, validValue, exampleForm } from './form-contract.mjs';
import { isWorkspacePane, paneTabRank } from './studio-parts.mjs';
function check(condition, message) { if (!condition) throw new Error(message); }

export function createPaneHost(host, editor, controls) {
  const registry = new Map(), signatures = new Map();
  const plugins = createPluginHost(editor);
  let active = 'console', mounted, disposed = false, lastSyncedRevision = -1;
  const consolePage = document.createElement('div');
  consolePage.className = 'pane-content';
  consolePage.append(...host.childNodes);
  const tabs = document.createElement('div'); tabs.className = 'pane-tabs'; tabs.setAttribute('role', 'tablist'); tabs.setAttribute('aria-label', 'Custom panes');
  const content = document.createElement('div'); content.className = 'pane-content'; content.setAttribute('role', 'tabpanel');
  const actions = document.createElement('div'); actions.className = 'pane-actions';
  const newButton = button('New pane', () => open('creator'));
  const closeButton = button('Close pane', () => close(active));
  actions.append(newButton, closeButton);
  host.classList.add('pane-host'); host.replaceChildren(tabs, actions, consolePage, content);

  function button(label, action) {
    const node = document.createElement('button'); node.type = 'button'; node.textContent = label;
    node.addEventListener('click', action); return node;
  }
  function teardown() {
    if (!mounted) return;
    const current = mounted; mounted = undefined;
    current.abort.abort();
    for (const cleanup of current.cleanups) { try { cleanup(); } catch (error) { console.error('Pane cleanup failed', error); } }
    content.replaceChildren();
  }
  function tabIds() {
    return [...registry.keys()].sort((a, b) => paneTabRank(a) - paneTabRank(b));
  }
  function drawTabs() {
    tabs.replaceChildren();
    for (const id of tabIds()) {
      const definition = registry.get(id);
      const tab = button(definition.title, () => open(id));
      tab.id = 'pane-tab-' + id; tab.setAttribute('role', 'tab'); tab.setAttribute('aria-selected', String(id === active));
      tab.tabIndex = id === active ? 0 : -1;
      tab.addEventListener('keydown', event => {
        const ids = tabIds(), index = ids.indexOf(id);
        const next = event.key === 'ArrowRight' ? ids[(index + 1) % ids.length] : event.key === 'ArrowLeft' ? ids[(index + ids.length - 1) % ids.length] : event.key === 'Home' ? ids[0] : event.key === 'End' ? ids.at(-1) : undefined;
        if (next) { event.preventDefault(); open(next); document.getElementById('pane-tab-' + next)?.focus(); }
      });
      tabs.append(tab);
    }
    consolePage.hidden = active !== 'console'; content.hidden = active === 'console';
    (active === 'console' ? consolePage : content).setAttribute('aria-labelledby', 'pane-tab-' + active);
    closeButton.disabled = active === 'console';
    const workspace = isWorkspacePane(active) || registry.get(active)?.workspace === true;
    actions.hidden = workspace;
    host.classList.toggle('workspace-part', workspace);
  }
  function open(id) {
    check(!disposed && registry.has(id), 'Unknown pane: ' + id);
    if (active === id && (mounted || id === 'console')) return;
    teardown(); active = id; drawTabs();
    if (id === 'console') return;
    const instance = { abort: new AbortController(), cleanups: [] }; mounted = instance;
    const context = Object.freeze({
      element: content, editor, signal: instance.abort.signal,
      subscribe(listener) {
        if (instance.abort.signal.aborted) return () => {};
        const unsubscribe = editor.subscribe(snapshot => {
          if (!instance.abort.signal.aborted) {
            try { listener(snapshot); } catch (error) { console.error('Pane subscriber failed', error); }
          }
        });
        instance.cleanups.push(unsubscribe); return unsubscribe;
      },
    });
    try {
      const cleanup = registry.get(id).mount(context);
      check(cleanup === undefined || typeof cleanup === 'function', 'Pane mount must return a synchronous disposer');
      if (cleanup) {
        if (instance.abort.signal.aborted) cleanup(); else instance.cleanups.push(cleanup);
      }
    } catch (error) {
      teardown(); content.textContent = 'Pane error: ' + error.message;
    }
  }
  function close(id) { if (active === id) open('console'); }
  function register(definition, internal = false, plugin = false) {
    check(!disposed && (validId(definition.id) || internal && definition.id.startsWith('form.')) && typeof definition.title === 'string' && definition.title.trim() && definition.title.length <= 120 && typeof definition.mount === 'function', 'Invalid pane definition');
    check(internal || !['console', 'creator'].includes(definition.id) && !definition.id.startsWith('form.'), 'Reserved pane ID');
    if (!plugin) plugins.unregister(definition.id);
    const reopen = active === definition.id;
    if (reopen) { teardown(); active = ''; }
    registry.set(definition.id, Object.freeze({ ...definition }));
    if (reopen) open(definition.id); else drawTabs();
  }
  function unregister(id) {
    check(!['console', 'creator'].includes(id) && !id.startsWith('form.'), 'Use resource.remove to delete a saved form');
    close(id); plugins.unregister(id); registry.delete(id); drawTabs();
  }
  function registerPlugin(plugin) {
    const manifest = plugins.register(plugin);
    register({ id: manifest.id, title: manifest.title, mount: plugin.mount ?? pluginPane(manifest, plugins, editor) }, false, true);
  }
  function registerForm(definition, expectedRevision = editor.snapshot().revision) {
    const form = validateForm(definition);
    const reply = editor.dispatch({ expectedRevision, commands: [{ op: 'resource.put', resource: { id: form.id, kind: FORM_KIND, version: 1, data: form } }] });
    if (reply.ok) open('form.' + form.id);
    return reply;
  }
  function mountForm(resourceId, context) {
    const get = () => editor.snapshot().document.resources.find(r => r.id === resourceId)?.data;
    const definition = validateForm(get());
    const heading = document.createElement('h2'); heading.textContent = definition.title;
    const note = document.createElement('p'); note.className = 'muted'; note.textContent = definition.gameId + ' · ' + resourceId;
    const error = document.createElement('p'); error.setAttribute('role', 'alert');
    context.element.append(heading, note);
    const updates = [];
    context.signal.addEventListener('abort', () => { context.element.replaceChildren(); }, { once: true });
    function commit(field, value) {
      if (!validValue(field, value)) { refresh(); error.textContent = 'Invalid value: ' + field.label; return; }
      const snapshot = editor.snapshot(), resource = snapshot.document.resources.find(r => r.id === resourceId);
      if (!resource) return;
      const reply = editor.dispatch({ expectedRevision: snapshot.revision, commands: [{ op: 'resource.put', resource: { ...resource, data: { ...resource.data, values: { ...resource.data.values, [field.key]: value } } } }] });
      refresh();
      error.textContent = reply.ok ? '' : reply.error.message;
    }
    function refresh() {
      try {
        const data = validateForm(get());
        for (const update of updates) update(data.values);
        for (const input of context.element.querySelectorAll('input, select, button')) input.disabled = false;
        error.textContent = '';
      } catch (cause) {
        error.textContent = 'Invalid form data: ' + cause.message;
        for (const input of context.element.querySelectorAll('input, select, button')) input.disabled = true;
      }
    }
    for (const field of definition.fields) {
      const row = document.createElement('label'); row.className = 'custom-field';
      if (field.type === 'boolean') {
        const control = controls.mount_switch(row, field.label, definition.values[field.key], value => commit(field, value));
        updates.push(values => controls.update_switch(control, values[field.key]));
        context.signal.addEventListener('abort', () => controls.dispose_switch(control), { once: true });
      } else {
        const label = document.createElement('span'); label.textContent = field.label; row.append(label);
        const input = document.createElement(field.type === 'select' ? 'select' : 'input');
        if (field.type === 'select') for (const option of field.options) { const node = document.createElement('option'); node.value = option; node.textContent = option; input.append(node); }
        else {
          input.type = field.type;
          if (field.type === 'text') input.maxLength = 4096;
          else for (const key of ['min', 'max', 'step']) if (field[key] !== undefined) input[key] = field[key];
        }
        input.setAttribute('aria-label', field.label);
        input.addEventListener('change', () => commit(field, field.type === 'number' ? input.valueAsNumber : input.value), { signal: context.signal });
        updates.push(values => { const value = String(values[field.key]); if (input.value !== value) input.value = value; });
        row.append(input);
      }
      context.element.append(row);
    }
    context.element.append(error); refresh();
    let lastRevision = editor.snapshot().revision;
    context.subscribe(snapshot => {
      if (snapshot.revision !== lastRevision) { lastRevision = snapshot.revision; refresh(); }
    });

  }
  function syncForms(snapshot) {
    if (snapshot.revision === lastSyncedRevision) return;
    lastSyncedRevision = snapshot.revision;
    const found = new Set();
    for (const resource of snapshot.document.resources) {
      if (resource.kind !== FORM_KIND) continue;
      const id = 'form.' + resource.id; found.add(id);
      const signature = JSON.stringify([resource.version, resource.data.title, resource.data.gameId, resource.data.id, resource.data.fields]);
      if (signatures.get(id) === signature && (active !== id || mounted)) continue;
      signatures.set(id, signature);
      register({ id, title: typeof resource.data.title === 'string' ? resource.data.title.trim().slice(0, 120) || resource.id : resource.id, mount: context => {
        check(resource.version === 1 && resource.data.id === resource.id, 'Unsupported form version or ID');
        return mountForm(resource.id, context);
      } }, true);
    }
    for (const id of signatures.keys()) if (!found.has(id)) { close(id); registry.delete(id); signatures.delete(id); drawTabs(); }
  }
  registry.set('console', { title: 'Console' });
  register({ id: 'creator', title: 'Pane builder', mount({ element, signal }) {
    const description = document.createElement('p'); description.textContent = 'Define a game form with text, number, boolean and select fields. Saved with this scene.';
    const input = document.createElement('textarea'); input.setAttribute('aria-label', 'Pane definition JSON'); const initial = structuredClone(exampleForm);
    let suffix = 2;
    while (editor.snapshot().document.resources.some(r => r.id === initial.id)) initial.id = exampleForm.id + '-' + suffix++;
    input.value = JSON.stringify(initial, null, 2); input.rows = 18;
    const error = document.createElement('p'); error.setAttribute('role', 'alert');
    const create = document.createElement('button'); create.textContent = 'Create pane';
    create.addEventListener('click', () => { try { const reply = registerForm(JSON.parse(input.value)); if (!reply.ok) error.textContent = reply.error.message; } catch (cause) { error.textContent = cause.message; } }, { signal });
    element.append(description, input, create, error);
  } }, true);
  const unsubscribe = editor.subscribe(syncForms); syncForms(editor.snapshot()); drawTabs();
  return Object.freeze({ register: definition => register(definition), unregister, open, close, registerForm, registerPlugin,
    invokeTool: plugins.invoke, tools: plugins.tools, subscribeTools: plugins.subscribe,
    list: () => [...registry].map(([id, pane]) => ({ id, title: pane.title, active: id === active })),
    dispose() { teardown(); plugins.dispose(); unsubscribe(); disposed = true; registry.clear(); host.replaceChildren(...consolePage.childNodes); host.classList.remove('pane-host'); },
  });
}
