// MoonBit is the source of truth; the checked-in ESM also works in plain static
// hosts, Node and Workers without a compiler or a bundler at runtime.
import {spawnSync} from 'node:child_process';
import {existsSync, readFileSync, writeFileSync} from 'node:fs';
import {resolve, dirname} from 'node:path';
import {pathToFileURL} from 'node:url';
import {WEB_RUNTIME_BUILDS, webRuntimeSourceHash, webRuntimeSourceFiles, WEB_HOST_SOURCE_DIR, webHostFiles} from './web-runtime-source.mjs';

const root=resolve(import.meta.dirname,'..');

export function buildWebRuntime({check=false}={}) {
  const pending=[];
  function prepare(destination, source) {
    let previous;
    try {previous=readFileSync(destination,'utf8');} catch(error) {if(error.code!=='ENOENT') throw error;}
    if(previous===source) return;
    if(check) throw new Error('Generated web runtime is stale. Run just web-runtime-build and include the generated assets.');
    pending.push({destination,source});
  }
  for (const build of WEB_RUNTIME_BUILDS) {
    const sourceDir=build.moduleDir+'/'+build.package;
    const destination=resolve(root,'assets/web',build.output);
    const result=spawnSync('moon',['build',sourceDir,'--target','js','--release'],{cwd:root,stdio:'inherit'});
    if(result.error) throw result.error;
    if(result.status!==0) throw new Error('MoonBit web runtime build failed');
    // Resolve this module explicitly: a renamed module can leave a stale
    // web_core.js in the same build tree, which a filename-only search would pick.
    const artifact=[
      `_build/js/release/build/${build.moduleName}/${build.package}/${build.package}.js`,
      `_build/js/release/build/${build.package}.js`,
    ].map(path=>resolve(root,path)).find(existsSync);
    if(!artifact) throw new Error('MoonBit web runtime artifact is missing');
    const source=`// Generated from ${sourceDir}/*.mbt by just web-runtime-build. DO NOT EDIT.\n`+
      `// Source SHA-256: ${webRuntimeSourceHash(build)}\n`+readFileSync(artifact,'utf8');
    prepare(destination, source);
    prepare(destination.replace(/\.js$/,'.d.ts'),readFileSync(resolve(root,sourceDir,'exports.d.ts'),'utf8'));
  }
  for(const file of webHostFiles()) prepare(resolve(root,'assets/web',file),readFileSync(resolve(WEB_HOST_SOURCE_DIR,file),'utf8'));
  for (const {destination,source} of pending) writeFileSync(destination,source);
}

const watchedSources=()=>[...new Set(WEB_RUNTIME_BUILDS.flatMap(build=>
  webRuntimeSourceFiles(build).map(file=>dirname(resolve(root,file)))) )];

/** Vite hook shared by standalone games and Studio. Compile before publication;
 * reload only after a successful write so consumers never see half-built ESM. */
export function moonbitWebRuntimePlugin() {
  return {
    name:'kagura-moonbit-web-runtime',
    buildStart() { buildWebRuntime(); },
    configureServer(server) {
      server.watcher.add([...watchedSources(), WEB_HOST_SOURCE_DIR]);
    },
    handleHotUpdate({file,server}) {
      if((watchedSources().some(source=>dirname(file)===source) && /\.(mbt|pkg|mod|ts)$/.test(file)) ||
        (dirname(file)===WEB_HOST_SOURCE_DIR && file.endsWith('.js'))) {
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
