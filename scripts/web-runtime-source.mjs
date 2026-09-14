import {createHash} from 'node:crypto';
import {readFileSync,readdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {loadReleaseModules, readMoonWorkMembers} from './moon-release-utils.mjs';
import {parseMoonPkgImports} from './moon-boundary-utils.mjs';

export const WEB_RUNTIME_BUILDS = Object.freeze([
  {moduleDir:'platform_web', moduleName:'mizchi/kagura_platform_web', package:'web_core', output:'kagura-runtime.generated.js'},
  {moduleDir:'game', moduleName:'mizchi/kagura_game', package:'inventory_web', output:'kagura-inventory.generated.js'},
]);

export const WEB_HOST_SOURCE_DIR = resolve(import.meta.dirname,'../platform_web/host');
export function webHostFiles() {
  return readdirSync(WEB_HOST_SOURCE_DIR).filter(file=>file.endsWith('.js')).sort();
}

/** Local transitive source closure: extracting a dependency must not make its
 * edits invisible to freshness checks or the dev server's watcher. */
export function webRuntimeSourceFiles(build = WEB_RUNTIME_BUILDS[0]) {
  const root=resolve(import.meta.dirname,'..');
  const {modules}=loadReleaseModules({repoRoot:root,moduleDirs:readMoonWorkMembers(root)});
  modules.sort((a,b)=>b.name.length-a.name.length);
  const sources=new Set(), visited=new Set();
  function visit(packageName) {
    if(visited.has(packageName)) return;
    visited.add(packageName);
    const owner=modules.find(mod=>packageName===mod.name||packageName.startsWith(mod.name+'/'));
    if(!owner) return; // External code is pinned by its importing module manifest.
    const directory=owner.dir+packageName.slice(owner.name.length);
    sources.add(owner.dir+'/moon.mod');
    for(const name of readdirSync(resolve(root,directory))) {
      if(name==='moon.pkg'||name==='exports.d.ts'||(name.endsWith('.mbt')&&!/_(?:test|wbtest|bench)\.mbt$/.test(name)))
        sources.add(directory+'/'+name);
    }
    for(const entry of parseMoonPkgImports(readFileSync(resolve(root,directory,'moon.pkg'),'utf8')))
      visit(entry.path);
  }
  visit(build.moduleName+'/'+build.package);
  return [...sources].sort();
}

/** Compiler-independent freshness check, also usable by Node-only CI jobs. */
export function webRuntimeSourceHash(build = WEB_RUNTIME_BUILDS[0]) {
  const root=resolve(import.meta.dirname,'..');
  const hash=createHash('sha256');
  for(const source of webRuntimeSourceFiles(build)) hash.update(source+'\0').update(readFileSync(resolve(root,source))).update('\0');
  return hash.digest('hex');
}
