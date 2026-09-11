import { validateSceneDocument } from './contracts.ts';
export const soundFiles = Object.freeze({
  'sfx.blunt': 'rifle',
  'sfx.sword': 'hit',
  'sfx.explosion': 'explosion',
  'sfx.confirm': 'confirm',
  'sfx.cancel': 'cancel',
});
export function runtimeRecipe(input) {
  const doc = validateSceneDocument(input),
    b = doc.stage.bounds;
  return {
    bounds: [b.minX, b.maxX, b.minZ, b.maxZ],
    spawn: doc.stage.spawn,
    solids: doc.stage.solids.map((s) => ({ ...s, color: parseInt(s.color.slice(1), 16) })),
    targets: doc.stage.targets,
    waves: doc.mission.waves.map((w) =>
      w.targets.map((id) => doc.stage.targets.findIndex((t) => t.id === id)),
    ),
    timeLimit: doc.mission.timeLimit,
    fov: doc.camera.fov,
    sky: parseInt(doc.lighting.skyColor.slice(1), 16),
    sun: doc.lighting.sunIntensity,
    action: {
      cooldown: doc.action.cooldown,
      damage: doc.action.damage,
      flashDuration: doc.action.flashDuration,
      flashColor: parseInt(doc.action.flashColor.slice(1), 16),
      recoilDuration: doc.action.recoilDuration,
      recoilStrength: doc.action.recoilStrength,
      shotSound: soundFiles[doc.action.shotSound],
      hitSound: soundFiles[doc.action.hitSound],
    },
  };
}
