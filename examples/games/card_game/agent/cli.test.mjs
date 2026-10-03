import assert from 'node:assert/strict';
import { test } from 'node:test';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { fileURLToPath } from 'node:url';

const run = promisify(execFile);
const script = fileURLToPath(new URL('../../../../scripts/card-game-agent.mjs', import.meta.url));

test('CLI help works without reading an API key', async () => {
  const { stdout } = await run(process.execPath, [script, '--help']);
  assert.match(stdout, /--dry-run/);
  assert.match(stdout, /--replay/);
  assert.match(stdout, /TYPESAFE_API_KEY/);
});

test('CLI dry run lists real map actions without the API or renderer', async () => {
  const { stdout, stderr } = await run(process.execPath, [script, '--no-build', '--dry-run', '--seed', '19', '--character', 'warden', '--stage', 'ascent']);
  assert.equal(stderr, '');
  const result = JSON.parse(stdout);
  assert.equal(result.observation.phase, 'map');
  assert.equal(result.observation.run.hp, 96);
  assert.deepEqual(Object.keys(result.request.questions.next_action.criteria), result.observation.choices.map(c => c.id));
  assert.equal(result.request.model, 'jev-latest');
});

test('CLI rejects unknown flags and invalid counts before build or key loading', async () => {
  for (const args of [['--unknown'], ['--max-decisions', '0'], ['--seed', '2.5'], ['--stage', 'ascent'], ['--character', 'bad', '--stage', 'ascent']]) {
    await assert.rejects(run(process.execPath, [script, ...args]), error => {
      assert.equal(error.code, 1);
      assert.match(error.stderr, /invalid_input/);
      return true;
    });
  }
});
