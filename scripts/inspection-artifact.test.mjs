import { test } from 'node:test';
import assert from 'node:assert/strict';
import { assertInspectionArtifact } from './inspection-artifact.mjs';

test('release gate rejects dormant registration code and requires a populated debug control', () => {
  assertInspectionArtifact('function update() {}', 'release');
  assert.throws(
    () =>
      assertInspectionArtifact(
        'function dormant() { globalThis.kaguraDebugAdapter = {}; }',
        'release',
      ),
    /leaked/,
  );
  assert.throws(() => assertInspectionArtifact('function update() {}', 'debug'), /lacks/);
  assert.throws(() => assertInspectionArtifact('function update() {}', 'other'), /Invalid/);
});
