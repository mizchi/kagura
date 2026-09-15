import test from 'node:test';
import assert from 'node:assert/strict';
import {parseCli} from '../cmd/kagura/cli.generated.js';
import {loadChromium, validateBrowserOptions, captureWeb} from '../cmd/kagura/browser.mjs';
import {mkdtempSync, readFileSync, rmSync, existsSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join, resolve} from 'node:path';
import {spawnSync} from 'node:child_process';
import {webRuntimeSourceHash} from './web-runtime-source.mjs';
import {readModuleManifest} from './moon-mod-manifest.mjs';
import {summarizeNumericSamples, summarizeCpuProfile} from '../cmd/kagura/performance.mjs';

test('browser tools validate their contract before loading a browser', () => {
  const capture = JSON.parse(parseCli(['capture', 'http://localhost:9000/game/', '--output', 'a frame.png', '--width', '390', '--height', '844', '--headed']));
  assert.equal(capture.ok, true);
  assert.equal(capture.command, 'capture');
  assert.equal(capture.url, 'http://localhost:9000/game/');
  assert.equal(capture.output, 'a frame.png');
  assert.deepEqual(capture.viewport, {width:390,height:844});
  assert.equal(capture.headed, true);
  const profile = JSON.parse(parseCli(['profile', '--samples', '12', '--profile-ms', '100', '--warmup-ms', '0']));
  assert.equal(profile.command, 'profile');
  assert.equal(profile.samples, 12);
  assert.equal(profile.profileMs, 100);
  assert.equal(profile.warmupMs, 0);
  for (const args of [
    ['capture', '--width', '0'], ['capture', '--height', '1.5'], ['capture', '--width', '999999999999999'],
    ['capture', '--samples', '1'], ['profile', '--samples', '3601'], ['profile', '--profile-ms', '-1'],
    ['profile', '--warmup-ms', 'bad'], ['capture', '--output'], ['capture', '--timeout', '0'],
    ['capture', '--headed', '--headed'], ['capture', '--url', 'file:///tmp/a'],
    ['profile', '--url', 'http://localhost/', 'http://elsewhere/'], ['profile', '--output', 'a.png'],
  ]) assert.equal(JSON.parse(parseCli(args)).ok, false, JSON.stringify(args));
});

test('diagnostics generated code tracks its transitive MoonBit sources', () => {
  const root = resolve(import.meta.dirname, '..');
  const hash = webRuntimeSourceHash({moduleDir:'.', moduleName:readModuleManifest(root).name, package:'cmd/diagnostics'});
  assert.ok(readFileSync(join(root,'cmd/diagnostics/performance.generated.js'),'utf8').includes(`Source SHA-256: ${hash}`));
  assert.throws(() => summarizeNumericSamples([NaN]), /finite/);
  assert.deepEqual(summarizeCpuProfile({nodes:[],samples:[]}), []);
});

test('help works without optional browser dependencies; capture explains installation', async t => {
  const directory = mkdtempSync(join(tmpdir(), 'kagura-tools-dependency-'));
  t.after(() => rmSync(directory, {recursive:true,force:true}));
  const cli = resolve(import.meta.dirname, '../cmd/kagura/main.mjs');
  const result = spawnSync(process.execPath, [cli, 'capture', '--help'], {cwd:directory,encoding:'utf8'});
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /kagura capture/);
  await assert.rejects(loadChromium(directory), /pnpm add -D @playwright\/test/);
  const output = join(directory, 'frame.png');
  await assert.rejects(captureWeb({url:'file:///tmp/game.html',output,dependencyRoot:directory}), /http/);
  assert.equal(existsSync(output), false);
  assert.throws(() => validateBrowserOptions({url:'http://localhost/',viewport:{width:NaN,height:900}}), /width/);
  assert.equal(typeof (await loadChromium(resolve(import.meta.dirname, '..'))).launch, 'function');
});
