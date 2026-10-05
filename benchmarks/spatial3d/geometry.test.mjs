// Cross-checks the GJK ground truth against closed-form tests and brute-force
// sampling. Run: node --test benchmarks/spatial3d/
import assert from "node:assert/strict";
import test from "node:test";

import { dot, gjk, intersects, norm, scale, signedClearance, sub, support, translate } from "./lib/geometry.mjs";
import { CONVEX_TYPES, Rng, makeShape } from "./lib/shapes.mjs";
import { certify, contains } from "./lib/verify.mjs";

const clamp = (x, lo, hi) => Math.max(lo, Math.min(hi, x));

test("sphere/sphere distance is exact", () => {
  const rng = new Rng(1);
  for (let i = 0; i < 500; i++) {
    const a = { type: "sphere", center: rng.vec(-3, 3), radius: rng.range(0.2, 2) };
    const b = { type: "sphere", center: rng.vec(-3, 3), radius: rng.range(0.2, 2) };
    const expected = norm(sub(a.center, b.center)) - a.radius - b.radius;
    const r = gjk(a, b);
    assert.equal(r.intersecting, expected < 0);
    if (expected > 1e-3) assert.ok(Math.abs(r.distance - expected) < 1e-5, `${r.distance} vs ${expected}`);
  }
});

test("aabb/aabb and sphere/aabb match closed form", () => {
  const rng = new Rng(2);
  for (let i = 0; i < 500; i++) {
    const c1 = rng.vec(-2, 2);
    const h1 = rng.vec(0.2, 1.5);
    const c2 = rng.vec(-2, 2);
    const h2 = rng.vec(0.2, 1.5);
    const a = { type: "aabb", min: sub(c1, h1), max: [0, 1, 2].map((k) => c1[k] + h1[k]) };
    const b = { type: "aabb", min: sub(c2, h2), max: [0, 1, 2].map((k) => c2[k] + h2[k]) };
    const overlap = [0, 1, 2].every((k) => a.min[k] < b.max[k] && b.min[k] < a.max[k]);
    const gap = Math.hypot(...[0, 1, 2].map((k) => Math.max(0, a.min[k] - b.max[k], b.min[k] - a.max[k])));
    if (gap > 1e-6 || overlap) assert.equal(intersects(a, b), overlap);
    if (!overlap && gap > 1e-3) assert.ok(Math.abs(gjk(a, b).distance - gap) < 1e-6);

    const s = { type: "sphere", center: rng.vec(-3, 3), radius: rng.range(0.2, 1.5) };
    const closest = [0, 1, 2].map((k) => clamp(s.center[k], a.min[k], a.max[k]));
    const d = norm(sub(closest, s.center)) - s.radius;
    if (Math.abs(d) > 1e-6) assert.equal(intersects(a, s), d < 0);
  }
});

test("torus clearance handles the hole", () => {
  const torus = { type: "torus", center: [0, 0, 0], axis: [0, 0, 1], major_radius: 2, minor_radius: 0.5 };
  assert.ok(signedClearance(torus, { type: "sphere", center: [0, 0, 0], radius: 1.4 }) > 0);
  assert.ok(signedClearance(torus, { type: "sphere", center: [0, 0, 0], radius: 1.6 }) < 0);
  assert.ok(signedClearance(torus, { type: "point", position: [2, 0, 0.4] }) < 0);
  assert.ok(signedClearance(torus, { type: "point", position: [0, 0, 0] }) > 0);
  assert.ok(Math.abs(signedClearance(torus, { type: "point", position: [0, 0, 3] }) - (Math.hypot(2, 3) - 0.5)) < 1e-12);
});

// Certificate check for every convex pair:
// - intersecting: the witness points coincide and lie in both shapes.
// - separated: the witnesses lie in their shapes (so distance is an upper
//   bound) and the plane normal to their difference separates the shapes
//   by the same distance (a lower bound). Upper == lower proves it.
test("GJK verdicts carry a verifiable certificate for all convex pairs", () => {
  const rng = new Rng(3);
  const counts = { yes: 0, no: 0 };
  for (let i = 0; i < 3000; i++) {
    const ta = rng.pick(CONVEX_TYPES);
    const tb = rng.pick(CONVEX_TYPES);
    const a = translate(makeShape(ta, rng), rng.vec(-1.8, 1.8));
    const b = translate(makeShape(tb, rng), rng.vec(-1.8, 1.8));
    const r = certify(a, b);
    if (r.intersecting) counts.yes++;
    else counts.no++;
    // The certificate's membership test must reject points clearly outside.
    if (!r.intersecting && r.distance > 0.05) assert.equal(contains(b, r.witnessA), false);
  }
  assert.ok(counts.yes > 500 && counts.no > 500, JSON.stringify(counts));
});

test("signed clearance sign matches GJK and grows with separation", () => {
  const rng = new Rng(4);
  for (let i = 0; i < 150; i++) {
    const a = makeShape(rng.pick(CONVEX_TYPES.filter((t) => t !== "point")), rng);
    const b0 = makeShape(rng.pick(CONVEX_TYPES.filter((t) => t !== "point")), rng);
    const dir = rng.unit();
    const near = signedClearance(a, translate(b0, scale(dir, 0.3)));
    const far = signedClearance(a, translate(b0, scale(dir, 6)));
    assert.equal(near < 0, intersects(a, translate(b0, scale(dir, 0.3))));
    assert.ok(far > near, `${far} <= ${near}`);
  }
});
