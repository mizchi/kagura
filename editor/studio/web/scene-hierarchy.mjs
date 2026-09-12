import { buildSceneGraph, scenesFromManifest } from '../runtime/scene-graph.mjs';

function selectionOf(editor, host) {
  if (host.transport().debugging) return undefined;
  const id = editor?.snapshot?.().selection;
  return id ? { kind: 'node', id } : undefined;
}

/** State-based scene graph: scenes, logical subjects, then the observed view tree. */
export function installSceneHierarchy(host, setStatus, selectSubject = () => {}, editor, workspace) {
  const container = document.querySelector('.hierarchy');
  const slot = workspace?.slot('hierarchy');
  let panel,
    bar,
    signature,
    errorMessage,
    disposed = false;
  const expanded = new Map();
  function clearOverlay() {
    slot?.release('runtime');
    panel?.remove();
    panel = undefined;
    signature = undefined;
    container.classList.remove('runtime-inspecting', 'scene-graph');
    expanded.clear();
  }
  function clear() {
    clearOverlay();
    bar?.remove();
    bar = undefined;
  }
  function sceneChooser(graph) {
    const scene = document.createElement('label');
    scene.className = 'graph-scene';
    const caption = document.createElement('span');
    caption.textContent = 'Scene';
    const chooser = document.createElement('select');
    chooser.setAttribute('aria-label', 'Hierarchy scene');
    for (const entry of graph.scenes) {
      const option = document.createElement('option');
      option.value = entry.id;
      option.textContent = entry.id + (entry.entry ? ' (start)' : '');
      chooser.append(option);
    }
    chooser.value = graph.activeScene;
    chooser.disabled = graph.scenes.length < 2;
    chooser.addEventListener('change', () => {
      host.selectScene(chooser.value).then(
        () => setStatus('Opened scene · ' + chooser.value),
        (error) => setStatus('Error · ' + error.message),
      );
    });
    scene.append(caption, chooser);
    return scene;
  }
  function renderAuthoringBar() {
    const graph = buildSceneGraph({
      sceneId: host.sceneId?.() ?? '',
      scenes: scenesFromManifest(host.project?.()?.manifest),
      document: editor?.snapshot?.().document,
      selection: selectionOf(editor, host),
    });
    if (graph.scenes.length < 2) {
      bar?.remove();
      bar = undefined;
      return;
    }
    const next = sceneChooser(graph);
    next.classList.add('hierarchy-scene-bar');
    if (bar) bar.replaceWith(next);
    else {
      const heading = container.querySelector('.panel-heading');
      heading ? heading.after(next) : container.prepend(next);
    }
    bar = next;
  }
  function graphInput() {
    const hierarchy = host.hierarchy();
    if (!hierarchy) return null;
    let inspection;
    try {
      inspection = host.transport().debugging ? host.debug('inspect') : null;
    } catch {
      inspection = null;
    }
    return {
      sceneId: host.sceneId?.() ?? '',
      scenes: scenesFromManifest(host.project?.()?.manifest),
      hierarchy,
      inspection,
      selection: selectionOf(editor, host),
    };
  }
  function render() {
    if (disposed) return;
    try {
      const input = graphInput();
      if (!input) {
        clearOverlay();
        renderAuthoringBar();
        return;
      }
      bar?.remove();
      bar = undefined;
      const graph = buildSceneGraph(input);
      const next = JSON.stringify(graph);
      if (next === signature) return;
      signature = next;
      errorMessage = undefined;
      if (!panel) {
        if (slot) {
          panel = slot.adopt({
            id: 'runtime',
            title: 'Scene hierarchy',
            mount({ element }) {
              element.classList.add('runtime-hierarchy');
              element.setAttribute('aria-label', 'Scene hierarchy');
            },
          });
        } else {
          panel = document.createElement('section');
          panel.className = 'runtime-hierarchy';
          panel.setAttribute('aria-label', 'Scene hierarchy');
          container.append(panel);
        }
      }
      container.classList.add('runtime-inspecting');
      panel.replaceChildren();
      if (graph.scenes.length) panel.append(sceneChooser(graph));
      if (graph.subjects.length) {
        const list = document.createElement('div');
        list.className = 'graph-subjects';
        list.setAttribute('aria-label', 'Runtime subjects');
        for (const subject of graph.subjects) {
          const row = document.createElement('button');
          row.type = 'button';
          row.className = 'graph-subject' + (subject.selected ? ' selected' : '');
          row.dataset.subjectId = subject.id;
          row.dataset.origin = subject.origin;
          row.textContent =
            subject.name + ' · ' + subject.origin + (subject.visuals.length ? '' : ' · unbound');
          row.addEventListener('click', () => selectSubject(subject.id));
          list.append(row);
        }
        panel.append(list);
      }
      function append(parent, node, depth) {
        const row = document.createElement('details'),
          label = document.createElement('summary');
        row.dataset.sceneId = node.id;
        row.dataset.generated = String(!!node.generated);
        row.dataset.origin = node.origin;
        if (node.subject) row.dataset.subject = node.subject;
        label.textContent =
          node.name +
          ' · ' +
          node.kind +
          (node.generated ? ' · generated' : '') +
          (node.subject ? ' · ' + node.subject : '');
        if (node.selected) row.classList.add('selected');
        label.addEventListener('click', (event) => {
          if (node.subject) selectSubject(node.subject);
          event.stopPropagation();
        });
        row.open = expanded.get(node.id) ?? true;
        row.addEventListener('toggle', () => row.isConnected && expanded.set(node.id, row.open));
        row.append(label);
        for (const child of node.children) append(row, child, depth + 1);
        parent.append(row);
      }
      for (const node of graph.view) append(panel, node, 0);
    } catch (error) {
      if (error.message !== errorMessage) setStatus('Error · ' + error.message);
      errorMessage = error.message;
    }
  }
  const unsubscribe = host.subscribe(render);
  const editorUnsubscribe = editor?.subscribe?.(render);
  const interval = setInterval(render, 250);
  render();
  return {
    dispose() {
      disposed = true;
      unsubscribe();
      editorUnsubscribe?.();
      clearInterval(interval);
      clear();
    },
  };
}
