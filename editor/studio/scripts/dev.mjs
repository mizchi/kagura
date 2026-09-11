import { spawn, spawnSync } from 'node:child_process';
const initial = spawnSync('moon', ['build', '--target', 'js', '--release'], { stdio: 'inherit' });
if (initial.status !== 0) process.exit(initial.status ?? 1);
const plugins = spawnSync(process.execPath, ['scripts/build-plugins.mjs'], { stdio: 'inherit' });
if (plugins.status !== 0) process.exit(plugins.status ?? 1);
const games = spawnSync(process.execPath, ['scripts/build-games.mjs'], { stdio: 'inherit' });
if (games.status !== 0) process.exit(games.status ?? 1);
const children = [
  spawn('moon', ['build', '--target', 'js', '--release', '--watch'], { stdio: 'inherit' }),
  spawn(process.execPath, ['node_modules/vite/bin/vite.js', '--host', '127.0.0.1', '--port', '5190', '--strictPort'], { stdio: 'inherit' }),
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
