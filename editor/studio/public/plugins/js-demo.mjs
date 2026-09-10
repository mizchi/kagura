/** Portable JavaScript tool plugin; neither manifest nor invoke depends on the browser. */
export const manifest = {
  apiVersion: 1, id: 'demo.js', title: 'Combat tools',
  tools: [{
    name: 'set_damage', description: 'Set combat damage (0-999) as an undoable game resource.',
    effect: 'transaction',
    inputSchema: {
      type: 'object', properties: { damage: { type: 'integer', minimum: 0, maximum: 999 } },
      required: ['damage'], additionalProperties: false,
    },
    outputSchema: { type: 'integer', minimum: 0, maximum: 999 },
  }],
};

export function invoke({ tool, arguments: args }) {
  if (tool !== 'set_damage') throw new Error('Unknown tool');
  return {
    result: args.damage,
    commands: [{ op: 'resource.put', resource: {
      id: 'combat.settings', kind: 'game.combat', version: 1, data: { damage: args.damage },
    } }],
  };
}

/** Optional browser entry; the host supplies a generated pane when mount is omitted. */
export function install(api) {
  api.panes.registerPlugin(api.plugins.defineJSPlugin({ manifest, invoke }));
  api.panes.open(manifest.id);
  return () => api.panes.unregister(manifest.id);
}
