import { spawn, spawnSync } from 'node:child_process';
import {existsSync} from 'node:fs';
const port = process.env.PORT ?? '5190';
const host = process.env.HOST ?? '127.0.0.1';
if (!/^\d+$/.test(port) || Number(port) < 1 || Number(port) > 65535) throw new Error('Invalid Studio port');
if (!existsSync('node_modules/vite/bin/vite.js')) throw new Error('Studio dependencies are missing. Run just studio-install.');
const initial = spawnSync('moon', ['build', '--target', 'js', '--release'], { stdio: 'inherit' });
if (initial.status !== 0) process.exit(initial.status ?? 1);
const plugins = spawnSync(process.execPath, ['scripts/build-plugins.mjs'], { stdio: 'inherit' });
if (plugins.status !== 0) process.exit(plugins.status ?? 1);
const games = spawnSync(process.execPath, ['scripts/build-games.mjs'], { stdio: 'inherit' });
if (games.status !== 0) process.exit(games.status ?? 1);
const children = [
  spawn('moon', ['build', '--target', 'js', '--release', '--watch'], { stdio: 'inherit' }),
  spawn(process.execPath, ['node_modules/vite/bin/vite.js', '--host', host, '--port', port, '--strictPort'], { stdio: 'inherit' }),
];
let stopping = false;
function stop(code = 0) {
  if (stopping) return;
  stopping = true;
  for (const child of children) child.kill('SIGTERM');
  process.exitCode = code;
}
for (const child of children) {
  child.on('error', error => { console.error(error.message); stop(1); });
  child.on('exit', code => stop(code ?? 0));
}
process.on('SIGINT', () => stop());
process.on('SIGTERM', () => stop());
