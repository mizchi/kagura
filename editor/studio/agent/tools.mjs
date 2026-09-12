function reply(value) {
  return { content: [{ type: 'text', text: JSON.stringify(value) }], details: value };
}

/** Same revision/token contract as window.kagura and WebMCP. Host methods throw on rejection. */
export function createEditorTools(host) {
  return [
    {
      name: 'editor_snapshot',
      description:
        'Read the live authoring document, revision and selection. Call before editor_dispatch.',
      execute: async () => reply(host.snapshot()),
    },
    {
      name: 'editor_dispatch',
      description:
        'Apply authoring commands as one undo step. Supply expectedRevision from editor_snapshot.',
      execute: async (args) => reply(host.dispatch(args)),
    },
    {
      name: 'editor_select',
      description: 'Select an authoring node by ID. Empty ID clears the selection.',
      execute: async ({ id }) => reply(host.select(id ?? '')),
    },
    {
      name: 'select_scene',
      description: 'Switch the open project scene. Does not write source until Save.',
      execute: async ({ id }) => reply(await host.selectScene(id)),
    },
    {
      name: 'scene_graph',
      description:
        'Read the state-based hierarchy: project scenes, logical subjects and the current view tree.',
      execute: async () => reply(host.graph()),
    },
    {
      name: 'runtime_inspect',
      description: 'Read game-owned subjects and typed fields plus the current runtime token.',
      execute: async () => reply(host.runtime.inspect()),
    },
    {
      name: 'runtime_pause',
      description: 'Pause simulation and return the editable runtime snapshot and token.',
      execute: async () => reply(host.runtime.pause()),
    },
    {
      name: 'runtime_edit',
      description:
        'Edit one declared field while paused. Requires the current session and revision token.',
      execute: async ({ subject, field, value, session, revision }) =>
        reply(host.runtime.edit({ subject, field, value }, { session, revision })),
    },
  ];
}

export function editorToolNames() {
  return createEditorTools({}).map((tool) => tool.name);
}
