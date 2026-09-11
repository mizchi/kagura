export const sceneSchema = Object.freeze({ id: 'kagura.scene', version: 1 });
import { createHeadlessEditor } from '../headless/index.mjs';
import { downloadBlob } from '../web/storage.mjs';
/** The generic editor ships in Studio; projects do not need a game extension. */
export const apiVersion = 1;
export const id = 'kagura.scene';
export function validateDocument(document) {
  return createHeadlessEditor(document).snapshot().document;
}
export function activate({ editor, viewport }) {
  return {
    open() {
      viewport?.setActive(true);
    },
    active: () => false,
    frame: () => viewport?.frame(editor.snapshot().selection),
    view: (name) => viewport?.view(name),
    validateDocument,
    readDocument: () => editor.snapshot().document,
    async importScene(document, expectedRevision) {
      const reply = editor.dispatch({
        expectedRevision,
        commands: [{ op: 'document.replace', document: validateDocument(document) }],
      });
      if (!reply.ok) throw Error(reply.error.message);
    },
    exportScene() {
      downloadBlob(
        new Blob([JSON.stringify(editor.snapshot().document, null, 2)], { type: 'application/json' }),
        'scene.kagura.json',
      );
    },
    closeView() {},
    dispose() {},
  };
}
