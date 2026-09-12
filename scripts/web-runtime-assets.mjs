// One distribution manifest for gallery pages, Studio and standalone consumers.
import {cpSync, mkdirSync} from 'node:fs';
import {join} from 'node:path';
import {fileURLToPath} from 'node:url';

export const WEB_RUNTIME_FILES = Object.freeze([
  'kagura-init.js',
  'kagura-presentation.js',
  'kagura-audio.js',
  'kagura-controls.js',
  'kagura-gfx.js',
]);

/** @param {string | URL} destination */
export function copyWebRuntimeAssets(destination) {
  const path = destination instanceof URL ? fileURLToPath(destination) : destination;
  mkdirSync(path, {recursive: true});
  for (const file of WEB_RUNTIME_FILES) {
    cpSync(new URL('../assets/web/' + file, import.meta.url), join(path, file));
  }
}

/** Declare before game modules; the prefix is relative to the emitted HTML. */
export function renderWebRuntimeImportMap(libPrefix) {
  const imports = {'@kagura-web/': libPrefix.replace(/\/$/, '') + '/'};
  const json = JSON.stringify({imports}).replaceAll('<', '\\u003c');
  return `<script type="importmap">${json}</script>`;
}
