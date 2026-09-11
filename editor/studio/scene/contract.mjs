import { createHeadlessEditor } from '../headless/index.mjs';
export const sceneResourceId = 'kagura.scene';
/** Shared scene bindings: transforms live in nodes; game meaning lives in components. */
export function readGameScene(input, expectedGame) {
  const document = createHeadlessEditor(input).snapshot().document;
  const resource = document.resources.find((r) => r.id === sceneResourceId);
  if (resource?.kind !== sceneResourceId || resource.version !== 1)
    throw Error('Missing game scene definition');
  const data = resource.data;
  if (
    Object.keys(data).some((k) => !['game', 'bindings'].includes(k)) ||
    typeof data.game !== 'string' ||
    !/^[a-z][a-z0-9_]{0,79}$/.test(data.game) ||
    (expectedGame && data.game !== expectedGame) ||
    !Array.isArray(data.bindings)
  )
    throw Error('Invalid game scene contract');
  const nodes = new Map(document.nodes.map((node) => [node.id, node])),
    seen = new Set();
  for (const binding of data.bindings) {
    if (
      !binding ||
      Object.keys(binding).some((k) => !['node', 'component', 'properties'].includes(k)) ||
      !nodes.has(binding.node) ||
      seen.has(binding.node) ||
      typeof binding.component !== 'string' ||
      !/^[a-z][a-z0-9_.-]{0,79}$/.test(binding.component) ||
      !binding.properties ||
      typeof binding.properties !== 'object' ||
      Array.isArray(binding.properties)
    )
      throw Error('Invalid or dangling scene binding');
    seen.add(binding.node);
  }
  return { document, game: data.game, bindings: data.bindings, nodes };
}
export function bindingsCommand(game, bindings) {
  return {
    op: 'resource.put',
    resource: { id: sceneResourceId, kind: sceneResourceId, version: 1, data: { game, bindings } },
  };
}
