/** A read-only projection of the game's declaration, refreshed independently of source drafts. */
export function installSceneHierarchy(host, setStatus) {
  const container = document.querySelector('.hierarchy');
  let panel,
    signature,
    errorMessage,
    disposed = false;
  const expanded = new Map();
  function clear() {
    panel?.remove();
    panel = undefined;
    signature = undefined;
    container.classList.remove('runtime-inspecting');
    expanded.clear();
  }
  function render() {
    if (disposed) return;
    try {
      const nodes = host.hierarchy();
      if (!nodes) {
        clear();
        return;
      }
      const next = JSON.stringify(nodes);
      if (next === signature) return;
      signature = next;
      errorMessage = undefined;
      if (!panel) {
        panel = document.createElement('section');
        panel.className = 'runtime-hierarchy';
        panel.setAttribute('aria-label', 'Scene hierarchy');
        container.append(panel);
        container.classList.add('runtime-inspecting');
      }
      panel.replaceChildren();
      const heading = document.createElement('h2');
      heading.textContent = 'Scene hierarchy';
      panel.append(heading);
      function append(parent, node, depth) {
        const row = document.createElement('details'),
          label = document.createElement('summary');
        row.dataset.sceneId = node.id;
        row.dataset.generated = String(node.generated);
        label.textContent = node.name + ' · ' + node.kind + (node.generated ? ' · generated' : '');
        row.open = expanded.get(node.id) ?? depth < 2;
        row.addEventListener('toggle', () => row.isConnected && expanded.set(node.id, row.open));
        row.append(label);
        for (const child of node.children) append(row, child, depth + 1);
        parent.append(row);
      }
      for (const node of nodes) append(panel, node, 0);
    } catch (error) {
      if (error.message !== errorMessage) setStatus('Error · ' + error.message);
      errorMessage = error.message;
    }
  }
  const unsubscribe = host.subscribe(render);
  const interval = setInterval(render, 250);
  render();
  return {
    dispose() {
      disposed = true;
      unsubscribe();
      clearInterval(interval);
      clear();
    },
  };
}
