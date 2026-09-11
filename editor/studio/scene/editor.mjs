import {
  activate as activateExample,
  validateDocument as validateExample,
} from '../examples/extension.mjs';
import { compileProfile, profileCommands } from './profile.mjs';
import { defineJSPlugin } from '../plugins/adapters.mjs';
import { downloadBlob } from '../web/storage.mjs';
/** Shared editor plumbing; each game supplies its own component profile. */
export function defineProfileEditor(profile) {
  const id = profile.game.replaceAll('_', '-'),
    paneId = id + '.scene';
  const compileScene = (doc) => compileProfile(doc, profile);
  const validateDocument = (doc, manifest) => {
    const valid = validateExample(doc, manifest);
    compileScene(valid);
    return valid;
  };
  return {
    apiVersion: 1,
    game: profile.game,
    sceneSchema: Object.freeze({ id: profile.game + '.scene', version: 1 }),
    id,
    validateDocument,
    activate(context) {
      const { editor, panes, base, viewport, setStatus, project } = context;
      const common = activateExample(context, { compileScene });
      const schema = (properties) => ({
        type: 'object',
        properties,
        required: Object.keys(properties),
        additionalProperties: false,
      });
      const kinds = Object.keys(profile.components).filter((k) => k !== 'spawn');
      panes.registerPlugin(
        defineJSPlugin({
          manifest: {
            apiVersion: 1,
            id: paneId,
            title: 'Game scene',
            tools: [
              {
                name: 'scene_read',
                description: 'Read the compiled game scene.',
                effect: 'read',
                inputSchema: schema({}),
              },
              {
                name: 'scene_add',
                description: 'Add a game component and its node.',
                effect: 'transaction',
                inputSchema: {
                  ...schema({ kind: { enum: kinds }, target: { type: 'string' } }),
                  required: ['kind'],
                },
              },
              {
                name: 'scene_remove',
                description: 'Remove a game entity.',
                effect: 'transaction',
                inputSchema: schema({ id: { type: 'string' } }),
              },
              {
                name: 'scene_target',
                description: 'Change a portal destination.',
                effect: 'transaction',
                inputSchema: schema({ id: { type: 'string' }, target: { type: 'string' } }),
              },
            ],
          },
          invoke(request) {
            if (request.tool === 'scene_read')
              return { result: compileScene(request.snapshot.document) };
            if (
              (request.tool === 'scene_target' || request.arguments.kind === 'portal') &&
              !Object.hasOwn(project.manifest.scenes ?? {}, request.arguments.target)
            )
              throw Error('Unknown portal destination');
            return {
              result: {},
              commands: profileCommands(request.tool, request.arguments, request.snapshot, profile),
            };
          },
          mount({ element, subscribe }) {
            const heading = document.createElement('h2');
            heading.textContent = profile.title + ' Scene';
            const note = document.createElement('p');
            note.textContent =
              '配置・床・壁・色をInspectorで編集します。床面はY=0、回転なし。キャラクターのサイズは固定です。';
            const status = document.createElement('p');
            status.setAttribute('aria-label', 'Scene validation');
            const row = document.createElement('div');
            row.className = 'game-transport';
            async function invoke(tool, args) {
              const reply = await panes.invokeTool(paneId, tool, args, {
                expectedRevision: editor.snapshot().revision,
              });
              if (!reply.ok) status.textContent = reply.error.message;
            }
            const destination = document.createElement('select');
            destination.setAttribute('aria-label', 'Portal destination');
            for (const id of Object.keys(project.manifest.scenes ?? {})) {
              const option = document.createElement('option');
              option.value = id;
              option.textContent = id;
              destination.append(option);
            }
            destination.value =
              Object.keys(project.manifest.scenes ?? {}).find(
                (id) => id !== context.getSceneId?.(),
              ) ?? '';
            for (const kind of kinds) {
              const button = document.createElement('button');
              button.textContent = 'Add ' + kind;
              button.addEventListener('click', () =>
                invoke('scene_add', {
                  kind,
                  ...(kind === 'portal' ? { target: destination.value } : {}),
                }),
              );
              row.append(button);
            }
            const remove = document.createElement('button');
            remove.textContent = '選択ノードを削除';
            remove.addEventListener('click', () =>
              invoke('scene_remove', { id: editor.snapshot().selection }),
            );
            row.append(remove);
            destination.addEventListener('change', () => {
              const snap = editor.snapshot(),
                binding = snap.document.resources
                  .find((r) => r.id === 'kagura.scene')
                  .data.bindings.find((b) => b.node === snap.selection);
              if (binding?.component === 'portal')
                invoke('scene_target', { id: snap.selection, target: destination.value });
            });
            const refresh = () => {
              try {
                const scene = compileScene(editor.snapshot().document);
                status.textContent = scene.data.entities.length + ' entities · Playに反映可能';
                const portal = scene.data.entities.find(
                  (e) => e.id === editor.snapshot().selection && e.kind === 'portal',
                );
                if (portal) destination.value = portal.target;
              } catch (error) {
                status.textContent = error.message;
              }
            };
            element.append(heading, note, row);
            if (profile.components.portal) element.append(destination);
            element.append(status);
            refresh();
            subscribe(refresh);
          },
        }),
      );
      return {
        ...common,
        readDocument: () => validateDocument(base.readDocument()),
        exportScene() {
          downloadBlob(
            new Blob([JSON.stringify(validateDocument(base.readDocument()), null, 2)], {
              type: 'application/json',
            }),
            profile.game + '.kgrscene',
          );
        },
        async importScene(doc, revision) {
          await common.importScene(validateDocument(doc), revision);
          viewport?.frame(doc.nodes.find((n) => n.id === 'floor')?.id ?? doc.nodes[0]?.id);
          panes.open(paneId);
          setStatus('Game scene loaded');
        },
        open: () => panes.open(paneId),
        dispose() {
          common.dispose();
          panes.unregister(paneId);
        },
      };
    },
  };
}
