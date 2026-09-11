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
