// Ported from mizchi/modeling-playground game/studio; scene-editor.html v1 contract.
import { validateSceneDocument, type SceneDocument } from './contracts.ts';

export function addEntity(
  source: SceneDocument,
  kind: 'enemy' | 'container',
  wave: number,
): { doc: SceneDocument; id: string } {
  const doc = structuredClone(source),
    ids = new Set([...doc.stage.targets, ...doc.stage.solids].map((x) => x.id));
  let n = 1;
  while (ids.has(`${kind}-${n}`)) n++;
  const id = `${kind}-${n}`;
  // Find an unoccupied grid cell instead of creating an unusable overlapping prefab.
  for (let z = doc.stage.bounds.minZ + 8; z < doc.stage.bounds.maxZ - 8; z += 10)
    for (let x = doc.stage.bounds.minX + 8; x < doc.stage.bounds.maxX - 8; x += 10) {
      if (
        Math.hypot(x - doc.stage.spawn[0], z - doc.stage.spawn[2]) < 10 ||
        doc.stage.targets.some((t) => Math.hypot(x - t.position[0], z - t.position[2]) < 8)
      )
        continue;
      const next = structuredClone(doc);
      if (kind === 'enemy') {
        next.stage.targets = [...next.stage.targets, { id, position: [x, 0, z], yaw: Math.PI }];
        next.mission.waves[wave].targets.push(id);
      } else
        next.stage.solids = [
          ...next.stage.solids,
          { id, kind: 'container', center: [x, 1.6, z], size: [5, 3.2, 8], color: '#9a6746' },
        ];
      try {
        return { doc: validateSceneDocument(next), id };
      } catch {
        /* Try the next free cell. */
      }
    }
  throw Error('配置できる空き領域がありません（敵は各波8機、全体24機まで）。');
}

export function removeEntity(source: SceneDocument, id: string): SceneDocument {
  const doc = structuredClone(source);
  if (id === 'spawn') throw Error('出撃地点は削除できません。');
  const wave = doc.mission.waves.find((w) => w.targets.includes(id));
  if (wave?.targets.length === 1) throw Error('各波に最低1機の敵が必要です。');
  doc.stage.solids = doc.stage.solids.filter((s) => s.id !== id);
  doc.stage.targets = doc.stage.targets.filter((t) => t.id !== id);
  if (wave) wave.targets = wave.targets.filter((t) => t !== id);
  return validateSceneDocument(doc);
}
