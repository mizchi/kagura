// MoonBit is the source of truth; the checked-in ESM also works in plain static
// hosts, Node and Workers without a compiler or a bundler at runtime.
import {spawnSync} from 'node:child_process';
import {existsSync, readFileSync, writeFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {webRuntimeSourceHash} from './web-runtime-source.mjs';

const root=resolve(import.meta.dirname,'..');
const destination=resolve(root,'assets/web/kagura-runtime.generated.js');

export function buildWebRuntime({check=false}={}) {
  const result=spawnSync('moon',['build','platform_js/web_core','--target','js','--release'],{cwd:root,stdio:'inherit'});
  if(result.error) throw result.error;
  if(result.status!==0) throw new Error('MoonBit web runtime build failed');
  // Resolve this module explicitly: a renamed module can leave a stale
  // web_core.js in the same build tree, which a filename-only search would pick.
  const artifact=[
    '_build/js/release/build/mizchi/kagura_platform_js/web_core/web_core.js',
    '_build/js/release/build/web_core.js',
  ].map(path=>resolve(root,path)).find(existsSync);
  if(!artifact) throw new Error('MoonBit web runtime artifact is missing');
  const source='// Generated from platform_js/web_core/*.mbt by just web-runtime-build. DO NOT EDIT.\n'+
    `// Source SHA-256: ${webRuntimeSourceHash()}\n`+readFileSync(artifact,'utf8');
  let previous;
  try {previous=readFileSync(destination,'utf8');} catch(error) {if(error.code!=='ENOENT') throw error;}
  if(previous===source) return;
  if(check) throw new Error('Generated web runtime is stale. Run just web-runtime-build and include the generated ESM.');
  writeFileSync(destination,source);
}

/** Vite hook shared by standalone games and Studio. Compile before publication;
 * reload only after a successful write so consumers never see half-built ESM. */
export function moonbitWebRuntimePlugin() {
  return {
    name:'kagura-moonbit-web-runtime',
    buildStart() { buildWebRuntime(); },
    configureServer(server) {
      server.watcher.add(resolve(root,'platform_js/web_core'));
    },
    handleHotUpdate({file,server}) {
      if(file.startsWith(resolve(root,'platform_js/web_core')+'/') && /\.(mbt|pkg)$/.test(file)) {
        buildWebRuntime();
        server.ws.send({type:'full-reload'});
        return [];
      }
    },
  };
}

if(process.argv[1] && import.meta.url===pathToFileURL(resolve(process.argv[1])).href) {
  buildWebRuntime({check:process.argv.includes('--check')});
}
