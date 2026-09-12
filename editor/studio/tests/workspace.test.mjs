import { test } from 'node:test';
import assert from 'node:assert/strict';
import { WORKSPACE_SLOTS, resolveSlotSelector } from '../web/workspace.mjs';

test('workspace slots are a closed set and resolve without scraping ad-hoc class names', () => {
  assert.deepEqual(WORKSPACE_SLOTS, [
    'hierarchy',
    'resources',
    'viewport',
    'timeline',
    'inspector',
    'tools',
  ]);
  assert.equal(resolveSlotSelector('hierarchy'), '[data-slot="hierarchy"], .hierarchy');
  assert.equal(resolveSlotSelector('resources'), '[data-slot="resources"], .assets');
  assert.equal(resolveSlotSelector('tools'), '[data-slot="tools"], .agent');
  assert.throws(() => resolveSlotSelector('sidebar'), /Unknown workspace slot/);
});

test('viewport and tools stay shell-owned so extensions cannot scrape them away', () => {
  assert.equal(resolveSlotSelector('viewport').includes('.viewport'), true);
  assert.equal(resolveSlotSelector('tools').includes('.agent'), true);
});
