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

test('scene flow declarations reference a bundled JSON resource', () => {
  const project = {...manifest, resources:{...manifest.resources, flow:'editor/flow.json'}, sceneFlow:{resource:'flow'}};
  assert.equal(validateProject(project).sceneFlow.resource,'flow');
  for (const patch of [
    {sceneFlow:{resource:'missing'}},
    {sceneFlow:{resource:'flow', unexpected:true}},
    {sceneFlow:{resource:5}},
    {resources:{flow:'editor/flow.mjs'}},
  ]) assert.throws(() => validateProject({...project,...patch}));
});
test('the built-in generic editor requires no extension declaration', () => {
  const { editor, ...generic } = manifest;
  assert.equal(validateProject(generic).editor, undefined);
});

test('resource drafts survive reopen of the pane, invalidate future URLs and detect stale edits and external saves',async()=>{
  const files=store(),p=await openProject(files,'game/iron.kgrprj');
  const original=await p.readResource('note'),url=await p.url('assets/note.txt');
  await p.stageResource('note',new Blob(['updated']),original.revision);
  assert.equal(await (await p.resource('note')).text(),'updated');
  assert.notEqual(await p.url('assets/note.txt'),url);
  await assert.rejects(p.stageResource('note',new Blob(['stale']),original.revision),/stale/i);
  await p.saveResources();assert.equal(await (await files.read('game/assets/note.txt')).blob.text(),'updated');
  const next=await p.readResource('note');await p.stageResource('note',new Blob(['local']),next.revision);
  await files.write('game/assets/note.txt',new Blob(['external']));
  await assert.rejects(p.saveResources(),/changed/i);
  assert.equal(await (await files.read('game/assets/note.txt')).blob.text(),'external');p.dispose();
});
test('concurrent first-time resource edits cannot reset optimistic revisions',async()=>{
  const p=await openProject(store(),'game/iron.kgrprj');
  const results=await Promise.allSettled([p.stageResource('note',new Blob(['first']),0),p.stageResource('note',new Blob(['second']),0)]);
  assert.equal(results.filter(r=>r.status==='fulfilled').length,1);
  assert.equal((await p.readResource('note')).revision,1);p.dispose();
});
test('a resource edit during URL resolution cannot poison the next Play cache',async()=>{
  const backing=store();let resume,started;
  const waiting=new Promise(resolve=>{started=resolve;});
  const delayed={...backing,async read(key){const result=await backing.read(key);if(key.endsWith('note.txt')&&resume===undefined){await new Promise(resolve=>{resume=resolve;started();});}return result;}};
  const p=await openProject(delayed,'game/iron.kgrprj');
  const oldURL=p.url('assets/note.txt');await waiting;
  await p.stageResource('note',new Blob(['new']),0);resume();
  await oldURL;
  const url=await p.url('assets/note.txt');assert.equal(await (await fetch(url)).text(),'new');p.dispose();
});
test('folder-upload fallback scopes nested project files and reports read-only storage',async()=>{
 const {filesStore}=await import('../projects/browser.mjs');
 const file=(path,text)=>{const f=new File([text],path.split('/').at(-1));Object.defineProperty(f,'webkitRelativePath',{value:path});return f;};
 const project=await openProject(filesStore([file('upload/nested/demo.kgrprj',JSON.stringify(manifest)),file('upload/nested/scenes/main.json','{"value":1}')]),'upload/nested/demo.kgrprj');
 assert.deepEqual(await project.readScene(),{value:1});assert.equal(project.writable,false);await assert.rejects(project.saveScene({value:2}),/read-only/);project.dispose();
});
