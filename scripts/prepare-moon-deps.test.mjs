import {test} from 'node:test';
import assert from 'node:assert/strict';
import {resolve} from 'node:path';
import {prepareMoonDeps} from './prepare-moon-deps.mjs';

const project = resolve('/tmp/kagura-moon-deps-test');
const dep = resolve(project, '.mooncakes/mizchi/audio');
const legacy = {status: 255, stdout: '', stderr: `Error: \`moon.mod.json\` at '${dep}' is no longer supported. Run \`moon fmt\` to migrate to \`moon.mod\`.`};
const ok = {status: 0, stdout: '', stderr: ''};

test('migrates a legacy dependency and resolves the graph again', () => {
  const calls = [];
  const results = [legacy, ok, ok];
  prepareMoonDeps(project, {run(command, args, options) {
    calls.push({command, args, cwd: options.cwd});
    return results.shift();
  }});
  assert.deepEqual(calls, [
    {command: 'moon', args: ['check', '--dry-run'], cwd: project},
    {command: 'moon', args: ['-C', dep, 'fmt'], cwd: project},
    {command: 'moon', args: ['check', '--dry-run'], cwd: project},
  ]);
});

test('propagates resolution failures instead of treating them as success', () => {
  assert.throws(() => prepareMoonDeps(project, {run: () => ({status: 1, stderr: 'unavailable dependency'})}), /unavailable dependency/);
});

test('stops if migration fails or makes no progress', () => {
  const results = [legacy, ok, legacy];
  assert.throws(() => prepareMoonDeps(project, {run: () => results.shift()}), /already migrated/);
  const failed = [legacy, {status: 1, stderr: 'format failed'}];
  assert.throws(() => prepareMoonDeps(project, {run: () => failed.shift()}), /format failed/);
});

test('does not migrate a project manifest in response to a dependency error', () => {
  assert.throws(() => prepareMoonDeps(project, {run: () => ({...legacy, stderr: legacy.stderr.replace(dep, project)})}), /is no longer supported/);
});
