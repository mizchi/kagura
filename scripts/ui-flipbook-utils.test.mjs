import { test } from 'node:test';
import assert from 'node:assert/strict';
import { validateTransition, analyzeTransition } from './ui-flipbook-utils.mjs';

const spec = { frames: 5, settleFrame: 3, inputs: [{}, { keys: [9] }] };
test('a transition must visibly respond and then settle at the declared deadline', () => {
  assert.deepEqual(analyzeTransition(spec, [100, 20, 0, 0]), []);
  assert.equal(analyzeTransition(spec, [0, 0, 0, 0])[0].kind, 'no-motion');
  assert.ok(analyzeTransition(spec, [100, 20, 1, 0]).some(f => f.kind === 'not-settled'));
});
test('missing observations, impossible deadlines and excessive capture requests fail closed', () => {
  assert.throws(() => analyzeTransition(spec, [100]), /measurement/);
  assert.throws(() => analyzeTransition(spec, [100, null, 0, 0]), /measurement/);
  for (const bad of [{ ...spec, frames: 1 }, { ...spec, settleFrame: 5 },
    { ...spec, frames: 10001 }, { ...spec, inputs: 'Tab' }]) assert.throws(() => validateTransition(bad));
});
