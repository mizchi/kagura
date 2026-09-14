import {createHash} from 'node:crypto';
import {readFileSync,readdirSync} from 'node:fs';
import {resolve} from 'node:path';

export const WEB_RUNTIME_BUILDS = Object.freeze([
  {moduleDir:'platform_web', moduleName:'mizchi/kagura_platform_web', package:'web_core', output:'kagura-runtime.generated.js'},
  {moduleDir:'game', moduleName:'mizchi/kagura_game', package:'inventory_web', output:'kagura-inventory.generated.js'},
]);

/** Compiler-independent freshness check, also usable by Node-only CI jobs. */
export function webRuntimeSourceHash(build = WEB_RUNTIME_BUILDS[0]) {
  const root=resolve(import.meta.dirname,'..',build.moduleDir);
  const sources=['moon.mod', ...readdirSync(resolve(root,build.package))
    .filter(name=>name==='moon.pkg'||(name.endsWith('.mbt')&&!name.endsWith('test.mbt')))
    .map(name=>build.package+'/'+name)].sort();
  const hash=createHash('sha256');
  for(const source of sources) hash.update(source+'\0').update(readFileSync(resolve(root,source))).update('\0');
  return hash.digest('hex');
}
