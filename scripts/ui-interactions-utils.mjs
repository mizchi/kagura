/** Deterministic evidence checks; declarations alone cannot prove reachability. */
export function validateNavigationProfile(profile) {
  for (const device of ['keyboard', 'gamepad']) {
    for (const direction of ['next', 'previous']) {
      const step = profile?.[device]?.[direction];
      if (!step || step.mouseButtons?.length ||
          (device === 'keyboard' && (!step.keys?.length || step.gamepads?.length)) ||
          (device === 'gamepad' && (!step.gamepads?.length || step.keys?.length))) {
        throw Error(`${device}.${direction} must use only the declared input device`);
      }
    }
  }
  return profile;
}

export function analyzeInteractions(snapshot, probes, hits) {
  const findings = [];
  const add = (kind, detail, node_id = null, device = null) => findings.push({ kind, node_id, device, detail });
  const nodes = snapshot.nodes.filter(n => n.visible !== false && n.focusable);
  const order = snapshot.focus_order;
  if (!Array.isArray(order) || !order.length || new Set(order).size !== order.length ||
      nodes.length !== order.length || new Set(nodes.map(n => n.id)).size !== nodes.length ||
      nodes.some(n => !order.includes(n.id) || order[n.focus_index] !== n.id)) {
    add('focus-declaration', 'focus_order, focus_index and visible focusable nodes must agree');
    return findings;
  }
  const visual = [...nodes].sort((a, b) => a.top - b.top || a.left - b.left).map(n => n.id);
  if (JSON.stringify(visual) !== JSON.stringify(order)) add('focus-visual-order', `Expected top-to-bottom, left-to-right order: ${visual.join(', ')}`);
  for (const device of ['keyboard', 'gamepad']) {
    for (const direction of ['next', 'previous']) {
      const probe = probes.find(p => p.device === device && p.direction === direction);
      if (!probe) { add('missing-probe', `No ${direction} traversal evidence`, null, device); continue; }
      const expected = direction === 'next' ? order : [...order].reverse();
      const cycle = [...expected, expected[0]];
      if (JSON.stringify(probe.targets) !== JSON.stringify(cycle)) {
        add('focus-traversal', `${direction}: expected ${cycle.join(' -> ')}, observed ${probe.targets.join(' -> ')}`, null, device);
      }
      expected.forEach((id, index) => {
        if (probe.visible[index] !== true) add('invisible-focus', `No pixel change inside focused control (${direction})`, id, device);
      });
    }
  }
  for (const id of order) {
    if (hits[id] !== id) add('hit-test-mismatch', `Clicking drawn center focused ${hits[id] ?? 'nothing'}`, id, 'pointer');
  }
  return findings;
}

/** Complement of a clipped target rectangle; used as vlmkit ignore regions. */
export function outsideRegions(rect, width, height) {
  const x = Math.max(0, Math.floor(rect.left)), y = Math.max(0, Math.floor(rect.top));
  const right = Math.min(width, Math.ceil(rect.left + rect.width));
  const bottom = Math.min(height, Math.ceil(rect.top + rect.height));
  if (![x, y, right, bottom].every(Number.isFinite) || right <= x || bottom <= y) throw Error('Focus rectangle is outside the frame');
  return [[0, 0, width, y], [0, bottom, width, height - bottom],
    [0, y, x, bottom - y], [right, y, width - right, bottom - y]].filter(r => r[2] > 0 && r[3] > 0);
}
