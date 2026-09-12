import { partById, createPartTabs } from './studio-parts.mjs';

/** Inspector edits the authored document. Debugger inspects paused game state. */
export function installInspectorParts(host, workspace) {
  const container = document.querySelector('.inspector');
  const chrome = workspace?.slot('inspector').chrome ?? container;
  const inspector = partById('inspector');
  const debuggerPart = partById('debugger');
  const tabs = document.createElement('div');
  tabs.className = 'part-tabs';
  tabs.setAttribute('role', 'tablist');
  tabs.setAttribute('aria-label', 'Inspector parts');
  const parts = createPartTabs([inspector, debuggerPart], {
    defaultId: 'inspector',
    onOpen: draw,
  });
  function button(part) {
    const tab = document.createElement('button');
    tab.type = 'button';
    tab.id = 'part-tab-' + part.id;
    tab.setAttribute('role', 'tab');
    tab.textContent = part.title;
    tab.addEventListener('click', () => parts.open(part.id));
    return tab;
  }
  const inspectorTab = button(inspector);
  const debuggerTab = button(debuggerPart);
  tabs.append(inspectorTab, debuggerTab);
  chrome.prepend(tabs);
  function draw() {
    const debugging = host.transport().debugging;
    const active = parts.active();
    container.classList.toggle('part-inspector', active === 'inspector');
    container.classList.toggle('part-debugger', active === 'debugger');
    inspectorTab.setAttribute('aria-selected', String(active === 'inspector'));
    debuggerTab.setAttribute('aria-selected', String(active === 'debugger'));
    debuggerTab.disabled = !debugging;
    debuggerTab.title = debugging ? 'Paused game state' : 'Play a project to debug runtime state';
  }
  const unsubscribe = host.subscribe(() => {
    const debugging = host.transport().debugging;
    if (debugging && parts.active() !== 'debugger') parts.open('debugger');
    if (!debugging && parts.active() !== 'inspector') parts.open('inspector');
    else draw();
  });
  draw();
  return {
    open: (id) => parts.open(id),
    dispose() {
      unsubscribe();
      tabs.remove();
      container.classList.remove('part-inspector', 'part-debugger');
    },
  };
}
