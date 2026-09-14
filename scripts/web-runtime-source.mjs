import {createHash} from 'node:crypto';
import {readFileSync,readdirSync} from 'node:fs';
import {resolve} from 'node:path';

/** Compiler-independent freshness check, also usable by Node-only CI jobs. */
export function webRuntimeSourceHash() {
  const root=resolve(import.meta.dirname,'../platform_js');
  const sources=['moon.mod', ...readdirSync(resolve(root,'web_core'))
    .filter(name=>name==='moon.pkg'||(name.endsWith('.mbt')&&!name.endsWith('test.mbt')))
    .map(name=>'web_core/'+name)].sort();
  const hash=createHash('sha256');
  for(const source of sources) hash.update(source+'\0').update(readFileSync(resolve(root,source))).update('\0');
  return hash.digest('hex');
}
