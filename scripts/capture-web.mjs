// Compatibility entry; parsing and implementation are owned by the CLI.
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
export {captureGameFrame, captureWeb} from '../cmd/kagura/browser.mjs';

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  process.argv.splice(2, 0, 'capture');
  await import('../cmd/kagura/main.mjs');
}
