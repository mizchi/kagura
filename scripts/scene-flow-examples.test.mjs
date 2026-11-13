import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {join} from 'node:path';
import {catalog, catalogProjectDir} from './example-catalog.mjs';
import {sceneFlowExamples} from './scene-flow-examples.mjs';
import {validateProject} from '../editor/studio/projects/project.mjs';
import {inspectSceneFlow} from '../game/scene_flow/inspect.mjs';

test('every catalog game has an executable flow declaration', () => {
  assert.deepEqual(sceneFlowExamples.map(e=>e.id).sort(),catalog.filter(e=>e.category==='games').map(e=>e.id).sort());
});
for (const item of sceneFlowExamples.filter(e=>e.id!=='arena3d'))
  test(item.id+' ships a valid flow resource readable by Studio without named spatial scenes', async () => {
    const root=catalogProjectDir(item);
    const manifest=validateProject(JSON.parse(await readFile(join(root,item.manifest),'utf8')));
    assert.ok(manifest.sceneFlow);
    const resource=manifest.resources[manifest.sceneFlow.resource];
    const graph=inspectSceneFlow(JSON.parse(await readFile(join(root,resource),'utf8')));
    assert.deepEqual(graph.report.issues,[]);
    assert.ok(graph.definition.scenes.length >= 3);
    assert.ok(graph.definition.transitions.length >= 3);
  });
