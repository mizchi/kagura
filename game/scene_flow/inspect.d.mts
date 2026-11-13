import type {SceneFlowDefinition, SceneFlowInspection} from '../../assets/web/kagura-scene-flow.generated.js';
export type {SceneFlowDefinition, SceneFlowInspection};
export function inspectSceneFlow(value: unknown): SceneFlowInspection;
export function inspectSceneDocuments(value: {
  entry: string;
  game: string;
  scenes: {id: string; data: unknown}[];
}): SceneFlowInspection;
