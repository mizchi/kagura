import { test } from 'node:test';
import assert from 'node:assert/strict';
import { validateProject, openProject } from '../projects/project.mjs';
const manifest = {
  format: 'kagura.project',
  version: 1,
  name: 'IRON YARD',
  editor: { id: 'iron-yard', entry: 'editor/extension.mjs' },
  scene: 'scenes/main.json',
  resources: { note: 'assets/note.txt' },
};
function store() {
  const files = new Map([
    ['game/iron.kgrprj', new Blob([JSON.stringify(manifest)])],
    ['game/scenes/main.json', new Blob(['{"value":1}'])],
    ['game/editor/extension.mjs', new Blob(['export const apiVersion=1'])],
    ['game/assets/note.txt', new Blob(['hello'])],
    ['outside.txt', new Blob(['secret'])],
  ]);
  return {
    async read(key) {
      if (!files.has(key)) throw Error('Not found: ' + key);
      return { blob: files.get(key) };
    },
    async write(key, blob) {
      files.set(key, blob);
    },
    async list() {
      return { objects: [...files.keys()].map((key) => ({ key })), cursor: null };
    },
  };
}
test('project paths are relative to the manifest directory and resources remain scoped', async () => {
  const project = await openProject(store(), 'game/iron.kgrprj');
  assert.equal(await (await project.read('assets/note.txt')).text(), 'hello');
  assert.deepEqual(await project.readScene(), { value: 1 });
  await project.saveScene({ value: 2 });
  assert.deepEqual(await project.readScene(), { value: 2 });
  assert.equal(
    (await project.list()).some((p) => p.includes('outside')),
    false,
  );
  for (const path of [
    '../outside.txt',
    '/outside.txt',
    'assets/../../outside.txt',
    'https://example.com/a',
    'assets/%2e%2e/a',
    'assets\\x',
    '',
  ])
    await assert.rejects(project.read(path));
  project.dispose();
  await assert.rejects(project.read('assets/note.txt'), /closed/);
});
test('invalid manifests and unsupported versions never become projects', () => {
  assert.equal(validateProject(manifest).editor.id, 'iron-yard');
  for (const patch of [
    { version: 2 },
    { scene: '../escape' },
    { editor: { id: 'iron-yard', entry: 'https://example.com/plugin.js' } },
    { resources: { x: '/absolute' } },
    { unexpected: 1 },
  ])
    assert.throws(() => validateProject({ ...manifest, ...patch }));
});
test('the built-in generic editor requires no extension declaration', () => {
  const { editor, ...generic } = manifest;
  assert.equal(validateProject(generic).editor, undefined);
});
test('folder-upload fallback scopes nested project files and reports read-only storage',async()=>{
 const {filesStore}=await import('../projects/browser.mjs');
 const file=(path,text)=>{const f=new File([text],path.split('/').at(-1));Object.defineProperty(f,'webkitRelativePath',{value:path});return f;};
 const project=await openProject(filesStore([file('upload/nested/demo.kgrprj',JSON.stringify(manifest)),file('upload/nested/scenes/main.json','{"value":1}')]),'upload/nested/demo.kgrprj');
 assert.deepEqual(await project.readScene(),{value:1});assert.equal(project.writable,false);await assert.rejects(project.saveScene({value:2}),/read-only/);project.dispose();
});
