import { readFile, writeFile, copyFile, mkdir } from 'node:fs/promises';
import wabtFactory from 'wabt';
const root = new URL('../', import.meta.url);
const manifest = Buffer.from(JSON.stringify(JSON.parse(await readFile(new URL('examples/plugins/wasm-demo.manifest.json', root), 'utf8'))));
if (manifest.length >= 2048) throw Error('Demo manifest exceeds its reserved buffer');
const template = await readFile(new URL('examples/plugins/wasm-demo.wat.in', root), 'utf8');
const wat = template.replace('{{MANIFEST}}', [...manifest].map(byte => '\\' + byte.toString(16).padStart(2, '0')).join('')).replace('{{MANIFEST_LENGTH}}', String(manifest.length));
const wabt = await wabtFactory(), module = wabt.parseWat('wasm-demo.wat', wat);
try {
  module.validate(); const { buffer } = module.toBinary({});
  await mkdir(new URL('public/plugins/', root), { recursive: true });
  await writeFile(new URL('public/plugins/wasm-demo.wasm', root), buffer);
  await copyFile(new URL('_build/js/release/build/plugin_demo/plugin_demo.js', root), new URL('public/plugins/moonbit-demo.mjs', root));
} finally { module.destroy(); }
