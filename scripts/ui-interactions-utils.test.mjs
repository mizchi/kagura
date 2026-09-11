import { test } from 'node:test';
import assert from 'node:assert/strict';
import { analyzeInteractions, outsideRegions, validateNavigationProfile } from './ui-interactions-utils.mjs';

const snapshot = {
  screen: { width: 100, height: 100, dpr: 1 }, focus_order: ['a', 'b'],
  nodes: ['a', 'b'].map((id, i) => ({ id, path: `root>button[${i}]`, role: 'button',
    left: i * 50, top: 0, width: 40, height: 30, visible: true, focusable: true,
    focus_index: i, hit_rect: { left: i * 50, top: 0, width: 40, height: 30 } })),
};
function probes() {
  return ['keyboard', 'gamepad'].flatMap(device => [
    { device, direction: 'next', targets: ['a', 'b', 'a'], visible: [true, true] },
    { device, direction: 'previous', targets: ['b', 'a', 'b'], visible: [true, true] },
  ]);
}
test('actual traversal must reach all controls, wrap, reverse and change pixels', () => {
  assert.deepEqual(analyzeInteractions(snapshot, probes(), { a: 'a', b: 'b' }), []);
  const broken = probes();
  broken[0].targets = ['a', 'a', 'a'];
  broken[1].visible[0] = false;
  const findings = analyzeInteractions(snapshot, broken, { a: 'b', b: 'b' });
  assert.ok(findings.some(f => f.kind === 'focus-traversal'));
  assert.ok(findings.some(f => f.kind === 'invisible-focus'));
  assert.ok(findings.some(f => f.kind === 'hit-test-mismatch'));
});
test('missing device evidence and contradictory declarations fail', () => {
  assert.ok(analyzeInteractions(snapshot, [], {}).some(f => f.kind === 'missing-probe'));
  const reversed = { ...snapshot, focus_order: ['b', 'a'], nodes: snapshot.nodes.map(n => ({ ...n, focus_index: 1 - n.focus_index })) };
  assert.ok(analyzeInteractions(reversed, probes(), {}).some(f => f.kind === 'focus-visual-order'));
  assert.ok(analyzeInteractions({ ...snapshot, nodes: [] }, probes(), {}).some(f => f.kind === 'focus-declaration'));
});
test('a gamepad profile cannot claim coverage by replaying keyboard input', () => {
  const keyboard = { next: { keys: [9] }, previous: { keys: [9, 16] } };
  assert.throws(() => validateNavigationProfile({ keyboard, gamepad: keyboard }), /gamepad/);
});
test('focus pixel probes mask everything outside the target, including unrelated animation', () => {
  assert.deepEqual(outsideRegions({ left: 20, top: 10, width: 30, height: 40 }, 100, 80),
    [[0, 0, 100, 10], [0, 50, 100, 30], [0, 10, 20, 40], [50, 10, 50, 40]]);
  assert.throws(() => outsideRegions({ left: 150, top: 0, width: 10, height: 10 }, 100, 80), /outside/);
});
