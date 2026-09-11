import { readGameScene, bindingsCommand } from './contract.mjs';
import { createHeadlessEditor } from '../headless/index.mjs';
/** A profile is owned by the game; this module knows only the portable entity contract. */
export function compileProfile(input, profile) {
  const { document, bindings, nodes } = readGameScene(input, profile.game);
  if (document.units !== 'meters' || document.up !== 'Y' || document.forward !== '+Z')
    throw Error('This game uses meters, Y up and +Z forward');
  if (bindings.length !== nodes.size || nodes.size > 512)
    throw Error('Every node needs a game component (max 512)');
  const entities = bindings.map((binding) => {
    const node = nodes.get(binding.node),
      spec = profile.components[binding.component];
    if (!spec) throw Error('Unsupported component: ' + binding.component);
    if (node.parent || node.rotation.some((v) => v !== 0))
      throw Error('Use root nodes without rotation');
    if (node.asset !== spec.asset) throw Error('Component requires ' + spec.asset);
    if (node.position.some((v) => Math.abs(v) > 1000) || node.scale.some((v) => v <= 0 || v > 2000))
      throw Error('Transform is out of range');
    if (spec.fixedScale && node.scale.some((v, i) => v !== spec.scale[i]))
      throw Error('Actor scale is fixed');
    if (binding.component === 'spawn' && node.position[1] !== profile.spawnHeight)
      throw Error('Invalid spawn height');
    const portal = binding.component === 'portal';
    if (
      Object.keys(binding.properties).some((k) => !portal || k !== 'target') ||
      (portal &&
        (typeof binding.properties.target !== 'string' ||
          !/^[A-Za-z][A-Za-z0-9_.-]{0,79}$/.test(binding.properties.target)))
    )
      throw Error('Invalid component properties');
    if (binding.component === 'floor' && Math.abs(node.position[1] + node.scale[1] / 2) > 0.00001)
      throw Error('Floor surface must be at Y=0');
    return {
      id: node.id,
      kind: binding.component,
      position: node.position,
      scale: node.scale,
      color: node.color,
      target: portal ? binding.properties.target : '',
    };
  });
  const spawns = entities.filter((e) => e.kind === 'spawn');
  if (spawns.length !== 1 || !entities.some((e) => e.kind === 'floor'))
    throw Error('Scene needs one spawn and a floor');
  const [x, , z] = spawns[0].position,
    radius = 0.5;
  const inside = (e) =>
    Math.abs(x - e.position[0]) + radius <= e.scale[0] / 2 &&
    Math.abs(z - e.position[2]) + radius <= e.scale[2] / 2;
  const intersects = (e) =>
    Math.abs(x - e.position[0]) < e.scale[0] / 2 + radius &&
    Math.abs(z - e.position[2]) < e.scale[2] / 2 + radius;
  if (
    !entities.some((e) => e.kind === 'floor' && inside(e)) ||
    entities.some((e) => ['wall', 'box', 'pillar'].includes(e.kind) && intersects(e))
  )
    throw Error('Spawn is blocked');
  return { apiVersion: 1, game: profile.game, data: { version: 1, entities } };
}
export function profileCommands(tool, args, snapshot, profile) {
  const { bindings, nodes } = readGameScene(snapshot.document, profile.game);
  let commands;
  if (tool === 'scene_add') {
    const spec = profile.components[args.kind];
    if (!spec || args.kind === 'spawn') throw Error('Unsupported component');
    let n = 1;
    while (nodes.has(args.kind + '-' + n)) n++;
    const id = args.kind + '-' + n;
    commands = [
      { op: 'node.add', id, name: id, asset: spec.asset, parent: '' },
      { op: 'node.transform', id, position: spec.position, rotation: [0, 0, 0], scale: spec.scale },
      { op: 'node.material', id, color: spec.color },
      bindingsCommand(profile.game, [
        ...bindings,
        {
          node: id,
          component: args.kind,
          properties: args.kind === 'portal' ? { target: args.target } : {},
        },
      ]),
    ];
  } else if (tool === 'scene_remove') {
    commands = [{ op: 'node.remove', id: args.id }];
  } else if (tool === 'scene_target') {
    if (!bindings.some((b) => b.node === args.id && b.component === 'portal'))
      throw Error('Select a portal');
    commands = [
      bindingsCommand(
        profile.game,
        bindings.map((b) =>
          b.node === args.id ? { ...b, properties: { target: args.target } } : b,
        ),
      ),
    ];
  } else throw Error('Unknown scene tool');
  const temp = createHeadlessEditor(snapshot.document);
  const reply = temp.dispatch({ commands, expectedRevision: temp.snapshot().revision });
  if (!reply.ok) throw Error(reply.error.message);
  compileProfile(temp.snapshot().document, profile);
  return commands;
}
export function compileProject(entry, scenes) {
  if (!scenes.some((s) => s.id === entry)) throw Error('Unknown entry scene');
  for (const scene of scenes)
    for (const entity of scene.data.entities ?? [])
      if (entity.kind === 'portal' && !scenes.some((s) => s.id === entity.target))
        throw Error('Unknown portal destination: ' + entity.target);
  return { entry, scenes };
}
