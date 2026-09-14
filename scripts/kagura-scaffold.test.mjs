import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync, readFileSync, writeFileSync, readdirSync, rmSync, existsSync, statSync} from 'node:fs';
import {join, resolve} from 'node:path';
import {tmpdir} from 'node:os';
import {spawnSync} from 'node:child_process';
import {parseCli, scaffoldFiles} from '../cmd/kagura/cli.generated.js';
import {createWebProject} from '../cmd/kagura/host.mjs';
import {generatedSources} from '../cmd/kagura/generate.mjs';

const root = resolve(import.meta.dirname, '..');
const runtime = Object.fromEntries(readdirSync(join(root, 'assets/web')).filter(name => name.endsWith('.js'))
  .map(name => [`runtime/${name}`, readFileSync(join(root, 'assets/web', name), 'utf8')]));

test('native installer embeds the current host, templates and browser distribution', () => {
  for (const [name, source] of Object.entries(generatedSources())) {
    assert.equal(readFileSync(join(root, 'cmd/kagura', name), 'utf8'), source, name);
    if (name === 'embedded_host_native.mbt') {
      const prefix = 'let node_host : String = ';
      const script = JSON.parse(source.split('\n').find(line => line.startsWith(prefix)).slice(prefix.length));
      const checked = spawnSync(process.execPath, ['--input-type=module', '--check'], {input: script, encoding: 'utf8'});
      assert.equal(checked.status, 0, checked.stderr);
    }
  }
});

test('new --web writes a released-dependency project without a checkout reference', t => {
  const temporary = mkdtempSync(join(tmpdir(), 'kagura-scaffold-'));
  t.after(() => rmSync(temporary, {recursive: true, force: true}));
  const destination = join(temporary, 'my-game');
  assert.deepEqual(JSON.parse(parseCli(['new', '--web'])), {ok: true, command: 'new', directory: '.'});
  createWebProject(destination, JSON.parse(scaffoldFiles('my-game')), runtime);
  const manifest = readFileSync(join(destination, 'moon.mod'), 'utf8');
  assert.match(manifest, /username\/my_game/);
  assert.match(manifest, /mizchi\/kagura_engine@0\.2\.0/);
  assert.equal(existsSync(join(destination, 'moon.work')), false);
  assert.ok(existsSync(join(destination, 'runtime/kagura-runtime.generated.js')));
  assert.match(readFileSync(join(destination, 'main.mbt'), 'utf8'), /@engine\.run/);
  assert.match(readFileSync(join(destination, 'vite.config.mjs'), 'utf8'), /vite-plugin-moonbit/);
  for (const file of ['moon.mod', 'package.json', 'justfile', 'vite.config.mjs', 'kagura.json']) {
    assert.ok(!readFileSync(join(destination, file), 'utf8').includes(root));
  }
  writeFileSync(join(destination, 'keep.txt'), 'keep');
  assert.throws(() => createWebProject(destination, JSON.parse(scaffoldFiles('other')), runtime), /not empty/);
  assert.equal(readFileSync(join(destination, 'keep.txt'), 'utf8'), 'keep');
});

test('scaffolding accepts an empty current directory and rejects unsafe template paths before writing', t => {
  const temporary = mkdtempSync(join(tmpdir(), 'kagura-empty-'));
  t.after(() => rmSync(temporary, {recursive: true, force: true}));
  assert.throws(() => createWebProject(temporary, {'../escape.txt': 'bad'}, {}), /path/);
  assert.deepEqual(readdirSync(temporary), []);
  const inode = statSync(temporary).ino;
  createWebProject(temporary, JSON.parse(scaffoldFiles('game')), runtime);
  assert.equal(statSync(temporary).ino, inode, 'preserve the shell current directory');
  assert.ok(existsSync(join(temporary, 'moon.mod')));
});
