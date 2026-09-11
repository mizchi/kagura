import { defineProfileEditor } from '../../../../editor/studio/scene/editor.mjs';
import { profile } from './scene.mjs';
export const { apiVersion, id, game, sceneSchema, validateDocument, activate } = defineProfileEditor(profile);
