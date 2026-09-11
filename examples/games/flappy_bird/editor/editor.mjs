import { define2DEditor } from '../../../../editor/studio/scene2d/editor.mjs';
import { profile } from './scene.mjs';
export const { apiVersion, id, game, sceneSchema, validateDocument, activate } =
  define2DEditor(profile);
