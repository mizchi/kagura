import { validateHierarchy } from './hierarchy.mjs';

function selectedNode(selection, kind, id) {
  return selection?.kind === kind && selection.id === id;
}

function annotateView(nodes, subjectIds, selection) {
  return nodes.map((node) => ({
    ...node,
    origin: node.subject && subjectIds.has(node.subject) ? 'state' : node.generated ? 'state' : 'definition',
    selected: selectedNode(selection, 'node', node.id),
    children: annotateView(node.children, subjectIds, selection),
  }));
}

function fromDocument(document, selection) {
  const byParent = new Map();
  for (const node of document.nodes ?? []) {
    const parent = node.parent ?? '';
    const siblings = byParent.get(parent) ?? [];
    siblings.push(node);
    byParent.set(parent, siblings);
  }
  function children(parent) {
    return (byParent.get(parent) ?? []).map((node) => ({
      id: node.id,
      name: node.name,
      kind: node.asset ?? 'node',
      generated: false,
      origin: 'definition',
      selected: selectedNode(selection, 'node', node.id),
      children: children(node.id),
    }));
  }
  return children('');
}

function collectVisuals(nodes, into = new Map()) {
  for (const node of nodes) {
    if (node.subject) {
      const list = into.get(node.subject) ?? [];
      list.push(node.id);
      into.set(node.subject, list);
    }
    collectVisuals(node.children ?? [], into);
  }
  return into;
}

/** Game state is the source of truth. Draw IDs are observations; subjects are the editable graph. */
export function buildSceneGraph(input = {}) {
  const scenes = Array.isArray(input.scenes)
    ? input.scenes.map((scene) => ({
        id: scene.id,
        path: scene.path ?? scene.id,
        entry: !!scene.entry,
      }))
    : [];
  const subjectsIn = input.inspection?.subjects ?? [];
  const subjectIds = new Set(subjectsIn.map((subject) => subject.id));
  const view = input.hierarchy
    ? annotateView(validateHierarchy(input.hierarchy), subjectIds, input.selection)
    : input.document
      ? fromDocument(input.document, input.selection)
      : [];
  const visuals = collectVisuals(view);
  const subjects = subjectsIn.map((subject) => ({
    id: subject.id,
    name: subject.name,
    origin: subject.fields?.every((field) => field.access === 'readonly') ? 'derived' : 'state',
    fields: subject.fields ?? [],
    visuals: visuals.get(subject.id) ?? [],
    selected: selectedNode(input.selection, 'subject', subject.id),
  }));
  return {
    activeScene: input.sceneId ?? scenes.find((scene) => scene.entry)?.id ?? scenes[0]?.id ?? '',
    scenes,
    subjects,
    view,
    selection: input.selection ?? null,
  };
}

export function scenesFromManifest(manifest) {
  if (!manifest) return [];
  if (manifest.scenes)
    return Object.entries(manifest.scenes).map(([id, path]) => ({
      id,
      path,
      entry: id === manifest.entryScene,
    }));
  if (manifest.scene) return [{ id: manifest.scene, path: manifest.scene, entry: true }];
  return [];
}
