// Compatibility entry; parsing and implementation are owned by the CLI.
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
export {measureWebPage, profileWeb} from '../cmd/kagura/browser.mjs';
export {cpuPerFrame, summarizeCpuProfile} from '../cmd/kagura/performance.mjs';

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  process.argv.splice(2, 0, 'profile');
  await import('../cmd/kagura/main.mjs');
}
