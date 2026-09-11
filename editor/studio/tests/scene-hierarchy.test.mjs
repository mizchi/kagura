import { test } from 'node:test';
import assert from 'node:assert/strict';
import { validateHierarchy } from '../runtime/hierarchy.mjs';

test('scene hierarchy carries source nesting and rejects ambiguous node IDs', () => {
  const bird = { id: 'world/bird', name: 'bird', kind: 'rect', generated: false, children: [] };
  const input = [{ id: 'world', name: 'world', kind: 'group', generated: false, children: [bird] }];
  const copy = validateHierarchy(input);
  input[0].children.length = 0;
  assert.equal(copy[0].children[0].id, 'world/bird');
  assert.throws(() => validateHierarchy([{ ...copy[0], children: [bird, bird] }]), /Duplicate/);
  assert.throws(() => validateHierarchy([{ ...bird, generated: 'false' }]), /Invalid/);
  assert.throws(
    () => validateHierarchy([{ ...copy[0], children: [{ ...bird, id: 'other/bird' }] }]),
    /parent/,
  );
});

test('render paths retain explicit logical subjects without requiring one visual per subject', () => {
  const node = { id: 'body', name: 'Body', kind: 'mesh', generated: true, children: [], subject: 'enemy:42:3' };
  const result = validateHierarchy([node, { ...node, id: 'minimap' }]);
  assert.equal(result[0].subject, result[1].subject);
  assert.deepEqual(validateHierarchy([{ ...node, subject: null }]), [{ id: 'body', name: 'Body', kind: 'mesh', generated: true, children: [] }]);
  assert.throws(() => validateHierarchy([{ ...node, subject: 'invalid/path' }]), /Invalid/);
});
