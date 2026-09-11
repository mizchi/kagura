import { spawnSync } from 'node:child_process';
import { cp, mkdir, rm, readdir, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';

const modelViewer = spawnSync(process.execPath, [fileURLToPath(new URL('build-model-viewer.mjs', import.meta.url))], { stdio: 'inherit' });
if (modelViewer.status !== 0) process.exit(modelViewer.status ?? 1);

// Package the same production renderer under Studio's origin (also works on static/Worker hosting).
const root = fileURLToPath(new URL('../../../', import.meta.url));
const build = spawnSync('just', ['iron-yard-build'], { cwd: root, stdio: 'inherit' });
if (build.status !== 0) process.exit(build.status ?? 1);
const extension = spawnSync('pnpm', ['exec', 'vite', 'build', '--config', fileURLToPath(new URL('../../../examples/games/iron_yard/editor/ui/vite.config.mjs', import.meta.url))], { cwd: fileURLToPath(new URL('../', import.meta.url)), stdio: 'inherit' });
if (extension.status !== 0) process.exit(extension.status ?? 1);
const destination = new URL('../public/games/iron-yard/', import.meta.url);
await rm(destination, { recursive: true, force: true });
await mkdir(destination, { recursive: true });
await cp(new URL('../../../examples/games/iron_yard/dist/', import.meta.url), destination, { recursive: true });
await mkdir(new URL('editor/', destination), { recursive: true });
for (const name of ['strix', 'bastion']) await cp(new URL(`../../../examples/games/iron_yard/assets/source/${name}.glb`, import.meta.url), new URL(`editor/${name}.glb`, destination));
const files = await readdir(new URL('assets/', destination));
await writeFile(new URL('editor/audio.json', destination), JSON.stringify(Object.fromEntries(['rifle', 'hit', 'explosion', 'confirm', 'cancel'].map(name => [name, '../assets/' + files.find(file => file.startsWith(name + '-') && file.endsWith('.wav'))]))));
const examples = spawnSync(process.execPath, [fileURLToPath(new URL('build-examples.mjs', import.meta.url))], { cwd: root, stdio: 'inherit', env: { ...process.env, STUDIO_IRON_YARD_BUILT: '1' } });
if (examples.status !== 0) process.exit(examples.status ?? 1);
