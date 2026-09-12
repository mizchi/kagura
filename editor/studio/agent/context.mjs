function ids(values) {
  return (values ?? []).map((value) => value.id).filter(Boolean);
}

/** Compact live editor projection. The agent must not invent IDs that are not listed here. */
export function editorTurnContext(host) {
  const snapshot = host.snapshot();
  const graph = host.graph?.() ?? { activeScene: '', subjects: [], view: [] };
  return {
    revision: snapshot.revision,
    selection: snapshot.selection ?? '',
    scene: graph.activeScene ?? '',
    subjects: ids(graph.subjects),
    nodes: ids(snapshot.document?.nodes).length ? ids(snapshot.document.nodes) : ids(graph.view),
  };
}

export function formatEditorTurn(text, context) {
  return (
    'Live Kagura Studio state:\n' +
    '- revision: ' +
    context.revision +
    '\n- selection: ' +
    (context.selection || '(none)') +
    '\n- scene: ' +
    (context.scene || '(none)') +
    '\n- subjects: ' +
    (context.subjects.join(', ') || '(none)') +
    '\n- nodes: ' +
    (context.nodes.join(', ') || '(none)') +
    '\n\nMutate only through editor_snapshot, scene_graph, editor_dispatch, editor_select, select_scene, runtime_inspect, runtime_pause, runtime_edit. Do not invent subject or node IDs.\n\nUser:\n' +
    text
  );
}
