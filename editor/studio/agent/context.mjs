function ids(values) {
  return (values ?? []).map((value) => value.id).filter(Boolean);
}

/** Compact live editor projection. The agent must not invent IDs that are not listed here. */
export function editorTurnContext(host) {
  const snapshot = host.snapshot();
  const graph = host.graph?.() ?? { activeScene: "", subjects: [], view: [] };
  return {
    revision: snapshot.revision,
    selection: Object.hasOwn(graph, "selection")
      ? (graph.selection?.id ?? "")
      : (snapshot.selection ?? ""),
    scene: graph.activeScene ?? "",
    subjects: ids(graph.subjects),
    nodes: ids(snapshot.document?.nodes).length
      ? ids(snapshot.document.nodes)
      : ids(graph.view),
  };
}

export function formatEditorTurn(text, context) {
  return (
    "Live Kagura Studio state:\n" +
    "- revision: " +
    context.revision +
    "\n- selection: " +
    (context.selection || "(none)") +
    "\n- scene: " +
    (context.scene || "(none)") +
    "\n- subjects: " +
    (context.subjects.join(", ") || "(none)") +
    "\n- nodes: " +
    (context.nodes.join(", ") || "(none)") +
    "\n\nUse editor_dispatch/editor_select/select_scene for authoring changes. Full-state games use runtime_inspect/runtime_pause/runtime_edit. Field-editing games use runtime_fields_inspect/runtime_fields_pause/runtime_fields_edit/runtime_fields_resume with the current session/revision/scope token. runtime_observe is read-only. Do not invent subject or node IDs.\n\nUser:\n" +
    text
  );
}
