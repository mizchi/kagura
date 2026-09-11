import { readGameScene, bindingsCommand } from '../../../../editor/studio/scene/contract.mjs';
const game = 'hacknslash_3d';
const kinds = ['floor', 'wall', 'spawn', 'enemy'];
const enemyKinds = ['basic', 'fast', 'tank', 'ranged'];
export function compileScene(document) {
  const scene = readGameScene(document, game),
    rectangles = [],
    enemies = [],
    spawns = [];
  if (scene.bindings.length !== scene.nodes.size)
    throw Error('すべてのノードにゲーム用コンポーネントが必要です');
  for (const binding of scene.bindings) {
    const node = scene.nodes.get(binding.node),
      kind = binding.component,
      properties = binding.properties;
    if (!kinds.includes(kind)) throw Error('Unknown scene component: ' + kind);
    if (node.parent || node.rotation.some((v) => v !== 0))
      throw Error(node.id + ': タイル配置はルート直下・回転0にしてください');
    const [x, , z] = node.position;
    if (kind === 'floor' || kind === 'wall') {
      if (node.asset !== 'primitive.box' || Object.keys(properties).length)
        throw Error('Invalid tile component');
      const width = node.scale[0],
        depth = node.scale[2],
        left = x - width / 2,
        top = z - depth / 2;
      if (
        ![left, top, width, depth].every(Number.isInteger) ||
        width < 1 ||
        depth < 1 ||
        left < 1 ||
        top < 1 ||
        left + width > 99 ||
        top + depth > 79
      )
        throw Error(node.id + ': X/Zの辺は1mグリッド、範囲はX 1〜99 / Z 1〜79です');
      rectangles.push({ id: node.id, kind, x: left, z: top, width, depth });
    } else {
      if (!Number.isFinite(x) || !Number.isFinite(z)) throw Error('Invalid actor position');
      if (kind === 'spawn') {
        if (Object.keys(properties).length) throw Error('Invalid spawn component');
        spawns.push([x, z]);
      } else {
        if (
          Object.keys(properties).some((k) => !['kind', 'hp'].includes(k)) ||
          !enemyKinds.includes(properties.kind) ||
          !Number.isInteger(properties.hp) ||
          properties.hp < 1 ||
          properties.hp > 10000
        )
          throw Error('Invalid enemy component');
        enemies.push({ id: node.id, x, z, ...properties });
      }
    }
  }
  if (spawns.length !== 1 || !rectangles.some((r) => r.kind === 'floor') || enemies.length > 128)
    throw Error('シーンには床と開始位置1つが必要です（敵は128体まで）');
  const inside = (r, x, z) => x >= r.x && x < r.x + r.width && z >= r.z && z < r.z + r.depth;
  const walkable = (x, z) =>
    rectangles.some((r) => r.kind === 'floor' && inside(r, x, z)) &&
    !rectangles.some((r) => r.kind === 'wall' && inside(r, x, z));
  for (const [x, z] of [spawns[0], ...enemies.map((e) => [e.x, e.z])])
    for (const dx of [-0.375, 0.375])
      for (const dz of [-0.375, 0.375])
        if (!walkable(x + dx, z + dz))
          throw Error('開始位置と敵は壁に重ならない床の上に配置してください');
  return { apiVersion: 1, game, data: { version: 1, rectangles, spawn: spawns[0], enemies } };
}
export function sceneCommands(tool, args, snapshot) {
  const scene = readGameScene(snapshot.document, game);
  if (tool === 'scene_properties') {
    const binding = scene.bindings.find((b) => b.node === args.id);
    if (binding?.component !== 'enemy') throw Error('敵ノードを選択してください');
    const bindings = scene.bindings.map((b) =>
      b.node === args.id ? { ...b, properties: args.properties } : b,
    );
    const command = bindingsCommand(game, bindings);
    compileScene({
      ...scene.document,
      resources: scene.document.resources.map((r) =>
        r.id === 'kagura.scene' ? command.resource : r,
      ),
    });
    return [command];
  }
  if (tool === 'scene_remove') {
    if (!scene.nodes.has(args.id)) throw Error('Select a scene node');
    const bindings = scene.bindings.filter((b) => b.node !== args.id);
    const doc = {
      ...scene.document,
      nodes: scene.document.nodes.filter((n) => n.id !== args.id),
      resources: scene.document.resources.map((r) =>
        r.id === 'kagura.scene' ? bindingsCommand(game, bindings).resource : r,
      ),
    };
    compileScene(doc);
    return [{ op: 'node.remove', id: args.id }, bindingsCommand(game, bindings)];
  }
  if (tool !== 'scene_add' || !['floor', 'wall', 'enemy'].includes(args.kind))
    throw Error('Unknown scene operation');
  let index = 1;
  while (scene.nodes.has(args.kind + '-' + index)) index++;
  const id = args.kind + '-' + index,
    kind = args.kind;
  const node = {
    id,
    name: id,
    asset: kind === 'enemy' ? 'primitive.cylinder' : 'primitive.box',
    parent: '',
    position:
      kind === 'enemy' ? [16.5, 0.5, 16.5] : kind === 'wall' ? [26.5, 0.25, 22] : [24, -0.125, 20],
    rotation: [0, 0, 0],
    scale: kind === 'enemy' ? [0.75, 1, 0.75] : kind === 'wall' ? [1, 0.5, 4] : [8, 0.25, 8],
    color: kind === 'enemy' ? 0xc34c45 : kind === 'wall' ? 0x5a5040 : 0x3a4a2a,
  };
  const binding = {
    node: id,
    component: kind,
    properties: kind === 'enemy' ? { kind: 'basic', hp: 30 } : {},
  };
  return [
    { op: 'node.add', id, name: id, asset: node.asset },
    {
      op: 'node.transform',
      id,
      position: node.position,
      rotation: node.rotation,
      scale: node.scale,
    },
    { op: 'node.material', id, color: node.color },
    bindingsCommand(game, [...scene.bindings, binding]),
  ];
}
