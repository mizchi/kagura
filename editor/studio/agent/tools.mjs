function reply(value) {
  return {
    content: [{ type: "text", text: JSON.stringify(value) }],
    details: value,
  };
}

/** Same revision/token contract as window.kagura and WebMCP. Host methods throw on rejection. */
export function createEditorTools(host) {
  const fields = () => {
    if (!host.runtime?.fields)
      throw Error("Runtime field editing is not available");
    return host.runtime.fields;
  };
  return [
    {
      name: "editor_snapshot",
      description:
        "Read the live authoring document, revision and selection. Call before editor_dispatch.",
      execute: async () => reply(await host.snapshot()),
    },
    {
      name: "editor_dispatch",
      description:
        "Apply authoring commands as one undo step. Supply expectedRevision from editor_snapshot.",
      execute: async (args) => reply(await host.dispatch(args)),
    },
    {
      name: "editor_select",
      description:
        "Select an authoring node by ID. Empty ID clears the selection.",
      execute: async ({ id }) => reply(await host.select(id ?? "")),
    },
    {
      name: "select_scene",
      description:
        "Switch the open project scene. Does not write source until Save.",
      execute: async ({ id }) => reply(await host.selectScene(id)),
    },
    {
      name: "scene_graph",
      description:
        "Read the state-based hierarchy: project scenes, logical subjects and the current view tree.",
      execute: async () => reply(await host.graph()),
    },
    {
      name: "runtime_inspect",
      description:
        "Read game-owned subjects and typed fields plus the current runtime token.",
      execute: async () => reply(await host.runtime.inspect()),
    },
    {
      name: "runtime_observe",
      description:
        "Read published scene/UI observations from games without a debug adapter. Read only; does not pause the game.",
      execute: async () => reply(await (host.runtime.observe?.() ?? null)),
    },
    {
      name: "runtime_pause",
      description:
        "Pause simulation and return the editable runtime snapshot and token.",
      execute: async () => reply(await host.runtime.pause()),
    },
    {
      name: "runtime_edit",
      description:
        "Edit one declared field while paused. Requires the current session and revision token.",
      execute: async ({ subject, field, value, session, revision }) =>
        reply(
          await host.runtime.edit(
            { subject, field, value },
            { session, revision },
          ),
        ),
    },
    {
      name: "runtime_fields_inspect",
      description:
        "Read declared runtime fields and the session/revision/scope token; no full checkpoint support is implied.",
      execute: async () => reply(await fields().inspect()),
    },
    {
      name: "runtime_fields_pause",
      description:
        "Pause the game and return its declared fields with a current token.",
      execute: async () => reply(await fields().pause()),
    },
    {
      name: "runtime_fields_resume",
      description:
        "Resume a field-editing game with the current paused session/revision/scope token.",
      execute: async ({ session, revision, scope }) =>
        reply(await fields().resume({ session, revision, scope })),
    },
    {
      name: "runtime_fields_edit",
      description:
        "Edit one declared field while paused. Requires the current session/revision/scope token and game validation.",
      execute: async ({ subject, field, value, session, revision, scope }) =>
        reply(
          await fields().edit(
            { subject, field, value },
            { session, revision, scope },
          ),
        ),
    },
  ];
}

export function editorToolNames() {
  return createEditorTools({}).map((tool) => tool.name);
}
