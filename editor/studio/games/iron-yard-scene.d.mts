import type { SceneDocument } from '../../../examples/games/iron_yard/editor/scene/contracts.ts';
import type { Snapshot, Command } from '../public/contract.d.ts';
export { defaultScene } from '../../../examples/games/iron_yard/editor/scene/document.ts';
export { validateSceneDocument } from '../../../examples/games/iron_yard/editor/scene/contracts.ts';
export const sceneId: 'iron-yard.scene';
export function readScene(snapshot: Snapshot): SceneDocument;
export function sceneCommand(document: SceneDocument): Command;
