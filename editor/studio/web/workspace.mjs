import { isInspectorChrome } from './studio-parts.mjs';

/** Named regions of the scene editor. Extensions fill these; they do not scrape CSS classes. */
export const WORKSPACE_SLOTS = Object.freeze([
  'hierarchy',
  'resources',
  'viewport',
  'timeline',
  'inspector',
  'tools',
]);

const FALLBACK = Object.freeze({
  hierarchy: '.hierarchy',
  resources: '.assets',
  viewport: '.viewport',
  timeline: '.timeline',
  inspector: '.inspector',
  tools: '.agent',
});

export function resolveSlotSelector(id) {
  if (!WORKSPACE_SLOTS.includes(id)) throw Error('Unknown workspace slot: ' + id);
  return `[data-slot="${id}"], ${FALLBACK[id]}`;
}

function move(nodes, parent) {
  for (const node of nodes) parent.append(node);
}

const SHELL_OWNED = new Set(['viewport', 'tools']);

function passthroughSlot(id, host) {
  host.dataset.slot = id;
  return {
    id,
    host,
    chrome: host,
    body: host,
    active: () => 'default',
    adopt() {
      throw Error(id + ' is owned by the scene editor shell');
    },
    release() {},
    dispose() {},
  };
}

function createSlot(id, host) {
  host.dataset.slot = id;
  if (SHELL_OWNED.has(id)) return passthroughSlot(id, host);
  host.classList.add('workspace-slot');
  let chrome = host.querySelector(':scope > .slot-chrome');
  let body = host.querySelector(':scope > .slot-body');
  if (!chrome) {
    chrome = document.createElement('div');
    chrome.className = 'slot-chrome';
  }
  if (!body) {
    body = document.createElement('div');
    body.className = 'slot-body';
  }
  const keep = [...host.childNodes].filter((node) => isInspectorChrome(node));
  const rest = [...host.childNodes].filter((node) => node !== chrome && node !== body && !isInspectorChrome(node));
  let fallback = body.querySelector(':scope > .slot-default');
  if (!fallback) {
    fallback = document.createElement('div');
    fallback.className = 'slot-default';
    move(rest, fallback);
    body.append(fallback);
  }
  move(keep, chrome);
  if (chrome.parentNode !== host) host.insertBefore(chrome, host.firstChild);
  if (body.parentNode !== host) host.append(body);
  const views = new Map();
  let active = 'default';
  function layer(viewId) {
    return body.querySelector(`:scope > .slot-view[data-view="${viewId}"]`);
  }
  function show(id) {
    active = id;
    fallback.hidden = id !== 'default';
    for (const [viewId, record] of views) {
      const node = layer(viewId);
      if (node) node.hidden = viewId !== id;
      if (viewId !== id) continue;
      record.shown = true;
    }
  }
  function release(viewId) {
    if (!viewId) {
      for (const id of [...views.keys()]) release(id);
      return;
    }
    const record = views.get(viewId);
    if (!record) {
      if (active === viewId) show('default');
      return;
    }
    record.abort.abort();
    layer(viewId)?.remove();
    views.delete(viewId);
    if (active === viewId) {
      const rest = [...views.keys()];
      show(rest.at(-1) ?? 'default');
    }
  }
  return {
    id,
    host,
    chrome,
    body,
    active: () => active,
    adopt(definition) {
      if (!definition?.id || typeof definition.mount !== 'function') throw Error('Invalid slot view');
      let node = layer(definition.id);
      if (!node) {
        node = document.createElement('div');
        node.className = 'slot-view';
        node.dataset.view = definition.id;
        if (definition.title) node.setAttribute('aria-label', definition.title);
        body.append(node);
        const abort = new AbortController();
        views.set(definition.id, { abort, shown: true });
        definition.mount({ element: node, signal: abort.signal, slot: id });
      }
      show(definition.id);
      return node;
    },
    release,
    dispose() {
      release();
      fallback.hidden = false;
    },
  };
}

/** Generic scene-editor shell. Built-in 3D content is the default view in each slot. */
export function createWorkspace(root = document) {
  const slots = new Map();
  for (const id of WORKSPACE_SLOTS) {
    const host = root.querySelector(resolveSlotSelector(id));
    if (!host) throw Error('Missing workspace slot: ' + id);
    slots.set(id, createSlot(id, host));
  }
  return Object.freeze({
    list: () => [...slots.keys()],
    slot(id) {
      const found = slots.get(id);
      if (!found) throw Error('Unknown workspace slot: ' + id);
      return found;
    },
    dispose() {
      for (const slot of slots.values()) slot.dispose();
    },
  });
}
