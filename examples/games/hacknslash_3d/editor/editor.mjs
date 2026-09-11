export const game = 'hacknslash_3d';
export const sceneSchema = Object.freeze({ id: 'hacknslash_3d.scene', version: 1 });
// Game-owned controls use the same launch parameters as snapshot.mbt.
// Domain editors add to Studio's shared editor; they need not reimplement its document or runtime host.
import {
  activate as activateExample,
  validateDocument as validateExample,
} from '../../../../editor/studio/examples/extension.mjs';
import { compileScene, sceneCommands } from './scene.mjs';
import { defineJSPlugin } from '../../../../editor/studio/plugins/adapters.mjs';
import { downloadBlob } from '../../../../editor/studio/web/storage.mjs';
export function validateDocument(input, manifest) {
  const doc = validateExample(input, manifest);
  compileScene(doc);
  return doc;
}
export const apiVersion = 1;
export const id = 'hacknslash-3d';
export function activate(context) {
  const { editor, panes, base, viewport, setStatus } = context;
  const common = activateExample(context, {
    compileScene,
    toggles: {
      mute: 'ミュート',
      autoplay: '自動操作',
      profiler: 'Profiler',
      fxaa: 'FXAA',
      shadows: '影',
      ssao: 'SSAO',
    },
  });
  const schema = (properties) => ({
    type: 'object',
    properties,
    required: Object.keys(properties),
    additionalProperties: false,
  });
  panes.registerPlugin(
    defineJSPlugin({
      manifest: {
        apiVersion: 1,
        id: 'hacknslash.scene',
        title: 'Game scene',
        tools: [
          {
            name: 'scene_read',
            description: 'Read the shared game scene and its compiled runtime layout.',
            effect: 'read',
            inputSchema: schema({}),
          },
          {
            name: 'scene_add',
            description: 'Add a floor, wall or enemy with its scene component.',
            effect: 'transaction',
            inputSchema: schema({ kind: { enum: ['floor', 'wall', 'enemy'] } }),
          },
          {
            name: 'scene_remove',
            description: 'Remove a scene node and its component atomically.',
            effect: 'transaction',
            inputSchema: schema({ id: { type: 'string' } }),
          },
          {
            name: 'scene_properties',
            description: 'Edit an enemy component in the game scene.',
            effect: 'transaction',
            inputSchema: schema({
              id: { type: 'string' },
              properties: schema({
                kind: { enum: ['basic', 'fast', 'tank', 'ranged'] },
                hp: { type: 'integer', minimum: 1, maximum: 10000 },
              }),
            }),
          },
        ],
      },
      invoke: (request) =>
        request.tool === 'scene_read'
          ? {
              result: {
                document: request.snapshot.document,
                recipe: compileScene(request.snapshot.document),
              },
            }
          : {
              result: {},
              commands: sceneCommands(request.tool, request.arguments, request.snapshot),
            },
      mount({ element, subscribe }) {
        const heading = document.createElement('h2');
        heading.textContent = 'Hack & Slash 3D Scene';
        const note = document.createElement('p');
        note.textContent =
          '床・壁・開始位置・敵をHierarchyで選び、InspectorでX/Z位置とサイズを編集します。1mが1タイルです。床をくり抜き、壁で通路を塞ぎます。高さ・色は編集用マーカーで、ゲームの見た目はKagura側が描画します。';
        const status = document.createElement('p');
        status.setAttribute('aria-label', 'Scene validation');
        const row = document.createElement('div');
        row.className = 'game-transport';
        async function invoke(tool, args) {
          const reply = await panes.invokeTool('hacknslash.scene', tool, args, {
            expectedRevision: editor.snapshot().revision,
          });
          if (!reply.ok) status.textContent = reply.error.message;
        }
        for (const [kind, label] of [
          ['floor', '床を追加'],
          ['wall', '壁を追加'],
          ['enemy', '敵を追加'],
        ]) {
          const button = document.createElement('button');
          button.textContent = label;
          button.addEventListener('click', () => invoke('scene_add', { kind }));
          row.append(button);
        }
        const remove = document.createElement('button');
        remove.textContent = '選択ノードを削除';
        remove.addEventListener('click', () =>
          invoke('scene_remove', { id: editor.snapshot().selection }),
        );
        row.append(remove);
        const validate = () => {
          try {
            const recipe = compileScene(editor.snapshot().document);
            status.textContent = `床・壁 ${recipe.data.rectangles.length} / 敵 ${recipe.data.enemies.length} · Playに反映可能`;
          } catch (error) {
            status.textContent = error.message;
          }
        };
        const enemyFields = document.createElement('fieldset'),
          legend = document.createElement('legend');
        legend.textContent = '選択した敵';
        const hpLabel = document.createElement('label');
        hpLabel.textContent = 'HP';
        const hp = document.createElement('input');
        hp.type = 'number';
        hp.min = '1';
        hp.max = '10000';
        hp.setAttribute('aria-label', 'Enemy HP');
        hpLabel.append(hp);
        const kindLabel = document.createElement('label');
        kindLabel.textContent = '種類';
        const kind = document.createElement('select');
        kind.setAttribute('aria-label', 'Enemy kind');
        for (const name of ['basic', 'fast', 'tank', 'ranged']) {
          const option = document.createElement('option');
          option.value = name;
          option.textContent = name;
          kind.append(option);
        }
        kindLabel.append(kind);
        const change = () =>
          invoke('scene_properties', {
            id: editor.snapshot().selection,
            properties: { hp: Number(hp.value), kind: kind.value },
          });
        hp.addEventListener('change', change);
        kind.addEventListener('change', change);
        enemyFields.append(legend, hpLabel, kindLabel);
        const refresh = () => {
          validate();
          const snap = editor.snapshot(),
            binding = snap.document.resources
              .find((r) => r.id === 'kagura.scene')
              ?.data.bindings.find((b) => b.node === snap.selection);
          enemyFields.hidden = binding?.component !== 'enemy';
          if (!enemyFields.hidden) {
            hp.value = String(binding.properties.hp);
            kind.value = binding.properties.kind;
          }
        };
        element.append(heading, note, row, enemyFields, status);
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
        'hacknslash-3d.kgrscene',
      );
    },
    async importScene(doc, revision) {
      await common.importScene(validateDocument(doc), revision);
      viewport?.frame(doc.nodes.find((n) => n.id === 'floor')?.id ?? doc.nodes[0]?.id);
      panes.open('hacknslash.scene');
      setStatus('Game scene loaded');
    },
    open: () => panes.open('hacknslash.scene'),
    dispose() {
      common.dispose();
      panes.unregister('hacknslash.scene');
    },
  };
}
