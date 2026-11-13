import {spawnSync} from 'node:child_process';
import {existsSync} from 'node:fs';
import {join} from 'node:path';
import {sceneFlowExamples} from './scene-flow-examples.mjs';
import {catalogProjectDir} from './example-catalog.mjs';

let failed=false;
for (const item of sceneFlowExamples) {
  const dir=catalogProjectDir(item);
  const packageName=['sim','lib','game'].find(p=>existsSync(join(dir,p,'moon.pkg'))) ?? '.';
  const packages=[packageName,'flow'];
  if (existsSync(join(dir,'app/moon.pkg'))) packages.push('app');
  for (const target of ['js','native']) {
    console.log(`Testing scene flow: ${item.id} (${target})`);
    const r=spawnSync('moon',['test',...packages,'--target',target],{cwd:dir,stdio:'inherit'});
    if (r.error) throw r.error;
    if (r.status !== 0) failed=true;
  }
}
process.exitCode=failed?1:0;
