import { test } from 'node:test';
import assert from 'node:assert/strict';
import { toVlmkitIntegrityElements } from './ui-snapshot-utils.mjs';
test('integrity preserves zero-size nodes and scales text, clip and geometry together', () => {
  const snapshot = { screen: { dpr: 2 }, nodes: [{ path: 'root>label', id: 'hp', role: 'label',
    left: 1, top: 2, width: 0, height: 10, z: 4, text: 'HP',
    text_measured: { width: 30, height: 8 }, clip: { left: 0, top: 0, width: 20, height: 20 } }] };
  assert.deepEqual(toVlmkitIntegrityElements(snapshot).elements[0], {
    path: 'root>label', id: 'hp', tag: 'label', classes: '', left: 2, top: 4, width: 0, height: 20,
    text: 'HP', text_measured: { width: 60, height: 16 }, clip: { left: 0, top: 0, width: 40, height: 40 }, z_index: 4,
  });
});
test('malformed or missing geometry must not silently disappear from verification', () => {
  for (const node of [{ path: 'x', left: NaN }, { left: 0, top: 0, width: 10, height: 10 }]) {
    assert.throws(() => toVlmkitIntegrityElements({ nodes: [node] }));
  }
  const node = { path: 'x', left: 0, top: 0, width: 10, height: 10 };
  assert.throws(() => toVlmkitIntegrityElements({ nodes: [node, node] }), /Duplicate/);
  assert.throws(() => toVlmkitIntegrityElements({ screen: { dpr: 0 }, nodes: [node] }), /DPR/);
});
