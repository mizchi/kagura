import {
  activate as activateExample,
  validateDocument as validateExample,
} from '../examples/extension.mjs';
import { defineJSPlugin } from '../plugins/adapters.mjs';
import { readScene2D, editObject, compileScene2D } from './model.mjs';
import { createPlaneEditor } from './view.mjs';

/** Games add constraints and runtime conversion; the plane, inspector and commands remain shared. */
export function define2DEditor(profile) {
  const validateDocument = (input, manifest) => {
    const doc = validateExample(input, manifest);
    if (doc.nodes.length) throw Error('2D projects store layout in kagura.scene2d, not 3D nodes');
    if (profile) compileScene2D(doc, profile);
    else if (readScene2D(doc))
      throw Error('This game needs a 2D scene adapter to accept layout data');
    return doc;
  };
  return {
    apiVersion: 1,
    id: profile ? profile.game.replaceAll('_', '-') : 'kagura.example2d',
    game: profile?.game,
    sceneSchema: { id: profile ? profile.game + '.scene2d' : 'kagura.example', version: 1 },
    validateDocument,
    activate(context) {
      const { editor, panes, viewport, project, base, setStatus } = context;
      let ui,
        disposed = false;
      const common = activateExample(
        {
          ...context,
          viewport: {
            ...viewport,
            setActive(value) {
              viewport?.setActive(false);
              ui?.setActive(value);
            },
          },
        },
        profile ? { compileScene: (doc) => compileScene2D(doc, profile) } : {},
      );
      function edit(id, changes, revision = editor.snapshot().revision) {
        const commands = editObject(editor.snapshot().document, id, changes, profile);
        const reply = editor.dispatch({ expectedRevision: revision, commands });
        if (!reply.ok) throw Error(reply.error.message);
      }
      function open() {
        if (disposed) throw Error('2D editor is unloaded');
        if (!ui) ui = createPlaneEditor({ editor, project, profile, edit, setStatus });
        ui.setActive(!common.playing());
        viewport?.setActive(false);
      }
      if (profile)
        panes.registerPlugin(
          defineJSPlugin({
            manifest: {
              apiVersion: 1,
              id: 'studio.scene2d',
              title: '2D scene',
              tools: [
                {
                  name: 'scene_read',
                  description: 'Read the authored 2D layout in pixels with downward Y.',
                  effect: 'read',
                  inputSchema: { type: 'object', properties: {}, additionalProperties: false },
                },
                {
                  name: 'object_edit',
                  description: 'Edit an object position, size or color. Applied on next Play.',
                  effect: 'transaction',
                  inputSchema: {
                    type: 'object',
                    properties: {
                      id: { type: 'string' },
                      changes: {
                        type: 'object',
                        properties: {
                          x: { type: 'number' },
                          y: { type: 'number' },
                          width: { type: 'number', exclusiveMinimum: 0 },
                          height: { type: 'number', exclusiveMinimum: 0 },
                          color: { type: 'integer', minimum: 0, maximum: 16777215 },
                          name: { type: 'string' },
                        },
                        additionalProperties: false,
                        minProperties: 1,
                      },
                    },
                    required: ['id', 'changes'],
                    additionalProperties: false,
                  },
                },
              ],
            },
            invoke: (request) =>
              request.tool === 'scene_read'
                ? { result: compileScene2D(request.snapshot.document, profile).data }
                : {
                    result: { id: request.arguments.id },
                    commands: editObject(
                      request.snapshot.document,
                      request.arguments.id,
                      request.arguments.changes,
                      profile,
                    ),
                  },
            mount({ element }) {
              const note = document.createElement('p');
              note.textContent =
                'キャンバスで選択・移動・右下ハンドルでサイズ変更。Inspector と AI は同じ配置データを編集します。';
              element.append(note);
            },
          }),
        );
      open();
      return {
        ...common,
        active: () => !!ui,
        open() {
          common.stop();
          open();
        },
        play: common.play
          ? async () => {
              open();
              await common.play();
            }
          : undefined,
        frame: () => ui?.fit(),
        view: () => ui?.fit(),
        async importScene(doc, revision) {
          await base.importScene(validateDocument(doc, project.manifest), revision);
          open();
        },
        closeView() {
          common.stop();
          ui?.dispose();
          ui = undefined;
          viewport?.setActive(true);
        },
        dispose() {
          disposed = true;
          common.dispose();
          ui?.dispose();
          ui = undefined;
          if (profile) panes.unregister('studio.scene2d');
          viewport?.setActive(true);
        },
      };
    },
  };
}
export const { apiVersion, id, sceneSchema, validateDocument, activate } = define2DEditor();
