import test from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {mkdtempSync, mkdirSync, writeFileSync, readFileSync, rmSync, existsSync, realpathSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join, resolve} from 'node:path';
import {parseCli} from '../cmd/kagura/cli.generated.js';
import {resolveWebProject, resolveProjectArtifact} from './web-project.mjs';
import {buildGame} from './build-game.mjs';
import {sourceHash} from '../cmd/kagura/build.mjs';
import {runProcess} from '../cmd/kagura/process.mjs';

const root = resolve(import.meta.dirname, '..');
const cli = join(root, 'cmd/kagura/main.mjs');

test('checked-in CLI matches its MoonBit sources and preserves subprocess failures', async () => {
  assert.ok(readFileSync(join(root, 'cmd/kagura/cli.generated.js'), 'utf8').includes(`Source SHA-256: ${sourceHash()}`));
  assert.equal(await runProcess(process.execPath, ['-e', 'process.exit(7)']), 7);
  await assert.rejects(runProcess('kagura-missing-test-executable', []), /ENOENT/);
});

function fixture(t) {
  const directory = mkdtempSync(join(tmpdir(), 'kagura cli 日本語 '));
  t.after(() => rmSync(directory, {recursive: true, force: true}));
  const project = join(directory, 'my game');
  mkdirSync(join(project, 'assets'), {recursive: true});
  writeFileSync(join(project, 'moon.mod'), 'name = "test/game"\n');
  writeFileSync(join(project, 'moon.pkg'), 'options(is_main: true)\n');
  return {directory, project};
}

test('compiled CLI contract and executable help work without starting MoonBit', () => {
  assert.deepEqual(JSON.parse(parseCli(['dev', 'ui_demo', '--port', '8189'])),
    {ok: true, command: 'dev', project: 'ui_demo', port: 8189, host: '127.0.0.1'});
  const result = spawnSync(process.execPath, [cli, '--help'], {cwd: tmpdir(), encoding: 'utf8', env: {...process.env, PATH: ''}});
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /kagura dev/);
  assert.match(result.stdout, /kagura build/);
  assert.match(result.stdout, /kagura studio/);
  assert.match(result.stdout, /kagura new/);
  assert.doesNotMatch(result.stdout, /kaguya/i);
  const manifest = JSON.parse(readFileSync(join(root, 'package.json'), 'utf8'));
  assert.deepEqual(manifest.bin, {kagura: 'cmd/kagura/main.mjs'});
  const invalid = spawnSync(process.execPath, [cli, 'dev', '--port', 'bad'], {encoding: 'utf8'});
  assert.equal(invalid.status, 2);
  assert.match(invalid.stderr, /port/);
});

test('resolve a named example, explicit path, or current project; reject the facade', t => {
  const {project} = fixture(t);
  assert.equal(resolveWebProject('ui_demo').directory, join(root, 'examples/demos-2d/ui_demo'));
  assert.equal(resolveWebProject(project).directory, project);
  assert.equal(resolveWebProject(null, project).directory, project);
  assert.throws(() => resolveWebProject(null, root), /project|example/i);
  assert.throws(() => resolveWebProject('not-a-real-game'), /not found/i);
});

test('standalone src artifacts do not require a workspace module prefix', t => {
  const {project} = fixture(t);
  rmSync(join(project, 'moon.pkg'));
  mkdirSync(join(project, 'src'));
  writeFileSync(join(project, 'src/moon.pkg'), 'pkgtype(kind: "executable")\n');
  const artifact = join(project, '_build/js/release/build/src/src.js');
  mkdirSync(join(project, '_build/js/release/build/src'), {recursive: true});
  writeFileSync(artifact, 'globalThis.ready = true;');
  const resolved = resolveWebProject(null, join(project, 'src'));
  assert.equal(resolved.entry, 'src');
  assert.equal(resolveProjectArtifact(resolved, 'release'), artifact);
});

test('release output is independently serveable, replaces only owned output, and preserves it on failure', t => {
  const {directory, project} = fixture(t);
  const outDir = join(directory, 'site');
  writeFileSync(join(project, 'assets/picture.png'), 'picture');
  const buildDir = join(project, '_build/js/release/build/test/game');
  const calls = [];
  const compile = (command, args, options) => {
    calls.push({command, args, cwd: options.cwd});
    mkdirSync(buildDir, {recursive: true});
    writeFileSync(join(buildDir, 'game.js'), 'globalThis.ready = true;');
    return {status: 0};
  };
  const options = {project: resolveWebProject(project), outDir, compile, buildRuntime() {}};
  buildGame(options);
  assert.deepEqual(calls[0], {command: 'moon', args: ['build', '.', '--target', 'js', '--release'], cwd: realpathSync(project)});
  assert.match(readFileSync(join(outDir, 'index.html'), 'utf8'), /\.\/lib\//);
  assert.match(readFileSync(join(outDir, 'loader.js'), 'utf8'), /\.\/game.js/);
  assert.equal(readFileSync(join(outDir, 'assets/picture.png'), 'utf8'), 'picture');
  assert.ok(existsSync(join(outDir, 'lib/kagura-init.js')));
  writeFileSync(join(outDir, 'obsolete.js'), 'old');
  buildGame(options);
  assert.equal(existsSync(join(outDir, 'obsolete.js')), false);
  assert.throws(() => buildGame({...options, compile: () => ({status: 7})}), /7/);
  assert.equal(readFileSync(join(outDir, 'game.js'), 'utf8'), 'globalThis.ready = true;');
  assert.throws(() => buildGame({...options, outDir: project}), /output/i);
  assert.throws(() => buildGame({...options, outDir: join(project, 'assets/site')}), /output/i);
  const existing = join(directory, 'unrelated');
  mkdirSync(existing);
  writeFileSync(join(existing, 'keep'), 'keep');
  assert.throws(() => buildGame({...options, outDir: existing}), /output/i);
  assert.equal(readFileSync(join(existing, 'keep'), 'utf8'), 'keep');
});
