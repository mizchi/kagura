// Ported from mizchi/modeling-playground game/studio; scene-editor.html v1 contract.
import { STAGE } from '../stage.ts';
import { validateSceneDocument, type SceneDocument } from './contracts.ts';
import { DEFAULT_ACTION } from './action.ts';
export { DEFAULT_ACTION } from './action.ts';
export function defaultScene(): SceneDocument {
  const stage = structuredClone(STAGE);
  stage.targets = Array.from({ length: 3 }, (_, wave) =>
    STAGE.targets.map((t, index) => ({
      ...t,
      id: `B-${String(wave * 3 + index + 1).padStart(2, '0')}`,
      position: [...t.position] as typeof t.position,
    })),
  ).flat();
  return validateSceneDocument({
    version: 1,
    id: 'iron-yard',
    name: 'IRON YARD / 境界線防衛',
    units: 'meters',
    up: 'Y',
    forward: '+Z',
    assets: { player: 'model.strix', enemy: 'model.bastion', bgm: 'bgm.battle' },
    stage,
    camera: { fov: 58 },
    lighting: { skyColor: '#a4b3bd', sunIntensity: 3.2 },
    action: structuredClone(DEFAULT_ACTION),
    mission: {
      timeLimit: 180,
      waves: Array.from({ length: 3 }, (_, wave) => ({
        id: `wave-${wave + 1}`,
        targets: stage.targets.slice(wave * 3, wave * 3 + 3).map((t) => t.id),
      })),
    },
  });
}
export function stageForWave(doc: SceneDocument, index: number) {
  const ids = new Set(doc.mission.waves[index].targets);
  return { ...doc.stage, targets: doc.stage.targets.filter((t) => ids.has(t.id)) };
}
