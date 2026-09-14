import { test } from 'node:test';
import assert from 'node:assert/strict';
import { comparePairedRuns } from './bench-gate-utils.mjs';

const run = (value) => [{ name: 'landscape/work', meanUs: value }];
test('paired report uses medians and strict separation of all samples', () => {
  const [gain] = comparePairedRuns([run(100), run(120), run(110)], [run(50), run(60), run(55)]);
  assert.equal(gain.before.medianUs, 110);
  assert.equal(gain.after.medianUs, 55);
  assert.equal(gain.ratio, 0.5);
  assert.equal(gain.separation, 'faster');
  assert.deepEqual(gain.before.samplesUs, [100, 120, 110]);
  assert.equal(comparePairedRuns([run(1), run(3)], [run(2), run(4)])[0].separation, 'overlap');
  assert.equal(comparePairedRuns([run(1)], [run(2)])[0].separation, 'slower');
  assert.equal(comparePairedRuns([run(1)], [run(1)])[0].separation, 'overlap');
});
test('missing workloads, empty results and invalid samples fail instead of reporting a gain', () => {
  for (const pair of [[[], []], [[run(1)], []], [[run(1)], [[]]], [[run(1)], [run(NaN)]], [[run(1)], [run(-1)]]]) {
    assert.throws(() => comparePairedRuns(...pair));
  }
  assert.throws(() => comparePairedRuns([run(1), []], [run(1), run(1)]));
  assert.throws(() => comparePairedRuns([run(1)], [[...run(1), ...run(2)]]));
});
