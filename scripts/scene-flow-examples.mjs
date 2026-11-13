import {readFile, writeFile, mkdir} from 'node:fs/promises';
import {existsSync} from 'node:fs';
import {spawnSync} from 'node:child_process';
import {join, dirname, resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {catalog, catalogProjectDir} from './example-catalog.mjs';
import {validateProject} from '../editor/studio/projects/project.mjs';
import {inspectSceneFlow} from '../game/scene_flow/inspect.mjs';

export const sceneFlowExamples = catalog.filter(item => existsSync(join(catalogProjectDir(item),'flow/moon.pkg')));

/** Execute the exact declaration imported by the game; never maintain a second transition table. */
export async function buildExampleSceneFlow(item, {check = false} = {}) {
  const dir = catalogProjectDir(item);
  const result = spawnSync('moon',['build','flow','--target','js','--release','--deny-warn'],{cwd:dir,stdio:'inherit'});
  if (result.error) throw result.error;
  if (result.status !== 0) throw Error('Scene flow build failed: '+item.id);
  const moduleName = /\bname\s*=\s*"([^"]+)"/.exec(await readFile(join(dir,'moon.mod'),'utf8'))?.[1];
  const artifact = [
    join(dir,'_build/js/release/build',moduleName,'flow/flow.js'),
    join(dir,'_build/js/release/build/flow/flow.js'),
  ].find(existsSync);
  if (!artifact) throw Error('Missing scene flow artifact: '+item.id);
  const compiled = await import(pathToFileURL(artifact).href+'?build='+Date.now());
  const definition = JSON.parse(compiled.definition_json());
  const inspection = inspectSceneFlow(definition);
  if (inspection.report.issues.length) throw Error(item.id+': '+JSON.stringify(inspection.report.issues));
  const manifest = validateProject(JSON.parse(await readFile(join(dir,item.manifest),'utf8')));
  // Arena derives its live graph from editable portals; it needs no persisted copy.
  const destination = manifest.sceneFlow && join(dir,manifest.resources[manifest.sceneFlow.resource]);
  if (destination) {
    const output = JSON.stringify(definition,null,2)+'\n';
    if (check) {
      if (await readFile(destination,'utf8') !== output) throw Error('Stale scene flow: '+item.id+'; run just scene-flow-examples-build');
    } else {
      await mkdir(dirname(destination),{recursive:true});
      await writeFile(destination,output);
    }
  }
  return inspection;
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  const args = process.argv.slice(2), check = args.includes('--check'), ids = args.filter(a => a !== '--check');
  for (const id of ids)
    if (!sceneFlowExamples.some(item => item.id === id)) throw Error('Unknown scene flow example: '+id);
  for (const item of sceneFlowExamples.filter(item => !ids.length || ids.includes(item.id))) {
    const {definition:d} = await buildExampleSceneFlow(item,{check});
    console.log(`${item.id}: ${d.scenes.length} scenes / ${d.transitions.length} transitions / 0 issues`);
  }
}
