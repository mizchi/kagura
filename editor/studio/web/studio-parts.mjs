/** Named workspace parts. Layout owns placement; each part owns one job. */
export const STUDIO_PARTS = Object.freeze([
  Object.freeze({ id: 'hierarchy', title: 'Hierarchy', role: 'scene-graph' }),
  Object.freeze({ id: 'inspector', title: 'Inspector', role: 'authoring' }),
  Object.freeze({ id: 'debugger', title: 'Debugger', role: 'runtime' }),
  Object.freeze({ id: 'terminal', title: 'Terminal', role: 'shell' }),
  Object.freeze({ id: 'agent', title: 'Agent', role: 'chat' }),
]);

export function partById(id) {
  return STUDIO_PARTS.find((part) => part.id === id);
}

export function partByRole(role) {
  return STUDIO_PARTS.find((part) => part.role === role);
}

export function isWorkspacePane(id) {
  return id === 'studio.terminal' || id === 'studio.agent';
}

const PANE_TAB_ORDER = [
  'console',
  'studio.agent',
  'studio.terminal',
  'studio.storage',
  'studio.models',
  'studio.motions',
  'studio.project',
  'creator',
];

export function paneTabRank(id) {
  const index = PANE_TAB_ORDER.indexOf(id);
  return index === -1 ? PANE_TAB_ORDER.length : index;
}

export function isInspectorChrome(node) {
  return node?.classList?.contains('part-tabs') || node?.classList?.contains('runtime-inspector');
}

export function createPartTabs(parts, { defaultId, onOpen } = {}) {
  let active = parts.some((part) => part.id === defaultId) ? defaultId : parts[0]?.id;
  return {
    list: () => parts.map((part) => ({ ...part, active: part.id === active })),
    active: () => active,
    open(id) {
      if (!parts.some((part) => part.id === id)) throw Error('Unknown part: ' + id);
      active = id;
      onOpen?.(id);
    },
  };
}
