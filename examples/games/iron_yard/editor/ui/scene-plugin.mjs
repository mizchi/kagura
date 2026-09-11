import { defaultScene } from '../scene/document.ts';
import { validateSceneDocument } from '../scene/contracts.ts';
import { addEntity, removeEntity } from '../scene/operations.ts';
export { defaultScene, validateSceneDocument };
export const sceneId = 'iron-yard.scene';
const object = (properties) => ({
  type: 'object',
  properties,
  required: Object.keys(properties),
  additionalProperties: false,
});
export const sceneTools = [
  {
    name: 'scene_load',
    description:
      'Load a scene-editor.html v1 IRON YARD document. Validate geometry, references and collisions before committing.',
    effect: 'transaction',
    inputSchema: object({ document: { type: 'object' } }),
  },
  {
    name: 'scene_export',
    description: 'Export the current IRON YARD scene in the modeling-playground scene-editor.html format.',
    effect: 'read',
    inputSchema: object({}),
  },
  {
    name: 'scene_edit',
    description:
      'Edit a solid, enemy or spawn by ID. ID scene edits name/camera/lighting/mission/action; ID action edits rifle fields. Units metres/radians/seconds.',
    effect: 'transaction',
    inputSchema: object({ id: { type: 'string' }, changes: { type: 'object', minProperties: 1 } }),
  },
  {
    name: 'scene_add',
    description: 'Add an enemy to a wave or a container in free space.',
    effect: 'transaction',
    inputSchema: object({
      kind: { enum: ['enemy', 'container'] },
      wave: { type: 'integer', minimum: 0, maximum: 7 },
    }),
  },
  {
    name: 'scene_remove',
    description: 'Remove a solid or enemy, preserving wave references and at least one enemy per wave.',
    effect: 'transaction',
    inputSchema: object({ id: { type: 'string' } }),
  },
  {
    name: 'attack_preview',
    description:
      'Replay one rifle shot with the real MoonBit combat simulation. Seeking backwards is silent and does not mutate the scene.',
    effect: 'read',
    inputSchema: object({ time: { type: 'number', minimum: 0, maximum: 1.5 } }),
  },
];
export function readScene(snapshot) {
  const resource = snapshot.document.resources.find((r) => r.id === sceneId);
  if (!resource) return defaultScene();
  if (resource.kind !== sceneId || resource.version !== 1) throw Error('Unsupported IRON YARD scene version');
  return validateSceneDocument(resource.data);
}
export function sceneCommand(document) {
  return {
    op: 'resource.put',
    resource: { id: sceneId, kind: sceneId, version: 1, data: validateSceneDocument(document) },
  };
}
export async function invokeScene(tool, args, snapshot) {
  let doc = tool === 'scene_load' ? defaultScene() : readScene(snapshot),
    result = {};
  if (tool === 'scene_export') return { result: doc };
  if (tool === 'attack_preview') {
    const { replayAttack } = await import('../headless.mjs');
    return { result: replayAttack(doc.action, args.time) };
  }
  if (tool === 'scene_load') doc = validateSceneDocument(args.document);
  else if (tool === 'scene_add') {
    if (!doc.mission.waves[args.wave]) throw Error('Unknown wave');
    const added = addEntity(doc, args.kind, args.wave);
    doc = added.doc;
    result = { id: added.id };
  } else if (tool === 'scene_remove') {
    if (![...doc.stage.solids, ...doc.stage.targets].some((e) => e.id === args.id))
      throw Error('Unknown entity');
    doc = removeEntity(doc, args.id);
  } else if (tool === 'scene_edit') {
    let target, allowed;
    if (args.id === 'scene') {
      target = doc;
      allowed = ['name', 'camera', 'lighting', 'mission', 'action'];
    } else if (args.id === 'action') {
      target = doc.action;
      allowed = Object.keys(doc.action).filter((k) => !['id', 'version'].includes(k));
    } else if (args.id === 'spawn') {
      target = { position: doc.stage.spawn };
      allowed = ['position'];
    } else {
      target = doc.stage.solids.find((s) => s.id === args.id);
      allowed = ['center', 'size', 'color', 'kind'];
      if (!target) {
        target = doc.stage.targets.find((t) => t.id === args.id);
        allowed = ['position', 'yaw'];
      }
    }
    if (!target || Object.keys(args.changes).some((k) => !allowed.includes(k)))
      throw Error('Unknown entity or unsupported field');
    Object.assign(target, structuredClone(args.changes));
    if (args.id === 'spawn') doc.stage.spawn = target.position;
  } else throw Error('Unknown scene tool');
  return { result, commands: [sceneCommand(doc)] };
}
