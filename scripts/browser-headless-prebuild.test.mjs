import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync, mkdirSync, writeFileSync, rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join, resolve} from 'node:path';
import {resolveV8ModuleRoot} from '../examples/smoke/browser_headless/scripts/mizchi-v8-consumer-prebuild.mjs';
import {combinePrebuild} from '../examples/smoke/browser_headless/scripts/prebuild.mjs';

test('V8 lookup accepts current manifests in the workspace dependency cache', t => {
  const root = mkdtempSync(join(tmpdir(), 'kagura v8 prebuild '));
  t.after(() => rmSync(root, {recursive: true, force: true}));
  const module = join(root, 'examples/smoke/browser_headless');
  const v8 = join(root, '.mooncakes/mizchi/v8');
  mkdirSync(module, {recursive: true});
  mkdirSync(v8, {recursive: true});
  writeFileSync(join(v8, 'moon.mod'), 'name = "mizchi/v8"\nversion = "0.3.0"\n');
  assert.equal(resolveV8ModuleRoot(module), v8);
});

test('combined prebuild resolves the repository script and forwards host input without a shell', () => {
  const moduleRoot = resolve('/tmp/kagura build/repo/examples/smoke/browser_headless');
  const input = {paths: {module_root: moduleRoot}};
  const calls = [];
  const result = combinePrebuild(input, {moduleRoot, run(command, args, options) {
    calls.push({command, args, options});
    return JSON.stringify({vars: calls.length === 1 ? {KAGURA_NATIVE_CC: 'clang'} : {MIZCHI_V8_CC_LINK_FLAGS: 'v8.a'}});
  }});
  assert.equal(calls[0].command, process.execPath);
  assert.equal(calls[0].args[0], resolve(moduleRoot, '../../../scripts/moon-prebuild-native-link-flags.cjs'));
  assert.equal(calls[1].args[0], join(moduleRoot, 'scripts/mizchi-v8-consumer-prebuild.mjs'));
  assert.deepEqual(JSON.parse(calls[1].options.input), input);
  assert.deepEqual(result, {vars: {KAGURA_NATIVE_CC: 'clang', MIZCHI_V8_CC_LINK_FLAGS: 'v8.a'}});
});
