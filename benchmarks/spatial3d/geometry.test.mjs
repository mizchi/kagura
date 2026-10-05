// Cross-checks the GJK ground truth against closed-form tests and brute-force
// sampling. Run: node --test benchmarks/spatial3d/*.test.mjs
import assert from "node:assert/strict";
import test from "node:test";

import { bounds, convexParts, distance, gjk, intersects, norm, quatToAxes, rotate, scale, signedClearance, sub, translate } from "./lib/geometry.mjs";
import { CONVEX_TYPES, Rng, makeShape, makeShapeV2, roundShape } from "./lib/shapes.mjs";
import { certify, certifyAll, contains } from "./lib/verify.mjs";

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

// ---------------------------------------------------------------- v2

test("quaternion convention: 90deg about z maps x to y", () => {
  const s = Math.SQRT1_2;
  const ax = quatToAxes([s, 0, 0, s]);
  assert.ok(norm(sub(ax[0], [0, 1, 0])) < 1e-12);
  assert.ok(norm(sub(ax[1], [-1, 0, 0])) < 1e-12);
  assert.ok(norm(sub(rotate([s, s, 0, 0], [0, 1, 0]), [0, 0, 1])) < 1e-12);
});

test("frame decomposition matches the direct plate-minus-hole test", () => {
  const rng = new Rng(11);
  for (let i = 0; i < 40; i++) {
    const frame = translate(makeShapeV2("frame", rng, rotate).shape, rng.vec(-1, 1));
    const parts = convexParts(frame);
    const b = bounds(frame);
    for (let k = 0; k < 400; k++) {
      const p = [0, 1, 2].map((c) => rng.range(b.min[c] - 0.2, b.max[c] + 0.2));
      const direct = contains(frame, p, 0);
      const viaParts = parts.some((part) => contains(part, p, 0));
      assert.equal(viaParts, direct, `frame ${i} point ${p}`);
    }
    // The hole centre is empty.
    assert.equal(contains(frame, frame.center, 0), false);
  }
});

test("v2 shapes certify against every other v2 shape", () => {
  const rng = new Rng(12);
  const types = [...CONVEX_TYPES, "compound", "frame"];
  let yes = 0;
  let no = 0;
  for (let i = 0; i < 800; i++) {
    const a = roundShape(translate(makeShapeV2(rng.pick(types), rng, rotate).shape, rng.vec(-1.5, 1.5)), { pos: 3, axis: 4 });
    const b = roundShape(translate(makeShapeV2(rng.pick(types), rng, rotate).shape, rng.vec(-1.5, 1.5)), { pos: 3, axis: 4 });
    const hit = certifyAll(a, b);
    assert.equal(hit, intersects(a, b));
    assert.equal(hit, signedClearance(a, b) < 0);
    if (hit) yes++;
    else no++;
  }
  assert.ok(yes > 150 && no > 150, `${yes}/${no}`);
});

test("an object through a frame's hole does not touch it", () => {
  const frame = { type: "frame", center: [0, 0, 0], rotation: [1, 0, 0, 0], outer_half_extents: [1.5, 1.5], inner_half_extents: [1, 1], half_thickness: 0.2 };
  const rod = { type: "capsule", a: [0, 0, -2], b: [0, 0, 2], radius: 0.9 };
  assert.equal(intersects(frame, rod), false);
  assert.ok(Math.abs(signedClearance(frame, rod) - 0.1) < 1e-6);
  assert.equal(intersects(frame, { ...rod, radius: 1.1 }), true);
});

test("committed datasets match their manifests and answer keys", async () => {
  const { createHash } = await import("node:crypto");
  const { readFileSync } = await import("node:fs");
  for (const v of ["v1", "v2", "v3"]) {
    const dir = new URL(`./data/${v}/`, import.meta.url);
    const manifest = JSON.parse(readFileSync(new URL("manifest.json", dir), "utf8"));
    for (const [name, sha] of Object.entries(manifest.sha256)) {
      assert.equal(createHash("sha256").update(readFileSync(new URL(name, dir))).digest("hex"), sha, `${v}/${name}`);
    }
    const problems = readFileSync(new URL("problems.jsonl", dir), "utf8").trim().split("\n").map(JSON.parse);
    const answers = new Map(readFileSync(new URL("answers.jsonl", dir), "utf8").trim().split("\n").map((l) => [JSON.parse(l).id, JSON.parse(l)]));
    // Re-derive every pair answer from the shapes shown to the model.
    for (const p of problems) {
      const a = answers.get(p.id);
      if (p.task === "distance") assert.ok(Math.abs(distance(p.objects[0], p.objects[1]) - a.answer) < 1e-6, p.id);
      else if (p.task === "pair") assert.equal(intersects(p.objects[0], p.objects[1]), a.answer, p.id);
      else {
        const hits = [];
        for (let i = 0; i < p.objects.length; i++)
          for (let j = i + 1; j < p.objects.length; j++) if (intersects(p.objects[i], p.objects[j])) hits.push(`${p.objects[i].id}-${p.objects[j].id}`);
        assert.deepEqual(hits, a.answer, p.id);
      }
    }
  }
});

test("distance agrees with the closed forms and is 0 exactly when intersecting", () => {
  const rng = new Rng(13);
  for (let i = 0; i < 300; i++) {
    const a = { type: "sphere", center: rng.vec(-2, 2), radius: rng.range(0.2, 1) };
    const b = { type: "sphere", center: rng.vec(-2, 2), radius: rng.range(0.2, 1) };
    const exact = Math.max(0, norm(sub(a.center, b.center)) - a.radius - b.radius);
    assert.ok(Math.abs(distance(a, b) - exact) < 1e-7);
  }
  const types = [...CONVEX_TYPES, "compound", "frame"];
  for (let i = 0; i < 300; i++) {
    const a = roundShape(translate(makeShapeV2(rng.pick(types), rng, rotate).shape, rng.vec(-1.5, 1.5)), { pos: 3, axis: 4 });
    const b = roundShape(translate(makeShapeV2(rng.pick(types), rng, rotate).shape, rng.vec(-1.5, 1.5)), { pos: 3, axis: 4 });
    assert.equal(distance(a, b) === 0, intersects(a, b));
  }
});
