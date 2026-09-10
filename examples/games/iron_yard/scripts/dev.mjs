import {spawn,spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {watch} from 'node:fs';
const root=fileURLToPath(new URL('../',import.meta.url));
for(const [bin,args] of [[process.execPath,['../../../engine/kagura_engine/draw3d/scripts/embed-wgsl.mjs']],['moon',['build','--target','js','--release']],[process.execPath,['scripts/convert-assets.mjs']]]){
 const result=spawnSync(bin,args,{cwd:root,stdio:'inherit'});if(result.status!==0)process.exit(result.status??1);
}
const children=[spawn('moon',['build','--target','js','--release','--watch'],{cwd:root,stdio:'inherit'}),spawn(process.execPath,['../../../node_modules/vite/bin/vite.js','--config','vite.config.mjs'],{cwd:root,stdio:'inherit'})];
const shaderWatcher=watch(new URL('../../../../engine/kagura_engine/draw3d/shaders/',import.meta.url),()=>{spawnSync(process.execPath,['../../../engine/kagura_engine/draw3d/scripts/embed-wgsl.mjs'],{cwd:root,stdio:'inherit'})});
let stopping=false;function stop(code=0){if(stopping)return;stopping=true;shaderWatcher.close();children.forEach(child=>child.kill('SIGTERM'));process.exitCode=code;}
for(const child of children){child.on('error',error=>{console.error(error);stop(1)});child.on('exit',code=>stop(code??0));}
process.on('SIGINT',()=>stop());process.on('SIGTERM',()=>stop());
