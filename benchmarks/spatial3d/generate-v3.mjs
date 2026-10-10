#!/usr/bin/env node
// Generates the spatial3d-v3 dataset: report the minimum distance between
// two solids (0 when they intersect), scored within +-0.001.
//
//   node benchmarks/spatial3d/generate-v3.mjs [--seed 20261007] [--out benchmarks/spatial3d/data/v3]
//
// Shapes, rounding and rotation conventions are those of v2. Distances are
// exact (certified GJK per convex piece; torus in closed form).

import { createHash } from "node:crypto";
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { parseArgs } from "node:util";

import { add, bounds, closestFeatures, cross, distance, interiorPoint, intersects, norm, normalize, rotate, scale, signedClearance, sub, translate } from "./lib/geometry.mjs";
import { datasetSpec } from "./lib/prompt.mjs";
import { CONVEX_TYPES, Rng, makeShapeV2, roundShape, withId } from "./lib/shapes.mjs";
import { certify } from "./lib/verify.mjs";
import { convexParts } from "./lib/geometry.mjs";

export const DATASET_VERSION = "spatial3d-v3";
export const TOLERANCE = 0.001;
const ROUND = { pos: 3, axis: 4 };
const MIN_DEPTH = 0.002; // intersecting problems overlap at least this much

// Distance buckets (absolute; objects are ~0.3-2.5 units across).
export const BUCKETS = [
  { name: "zero", lo: 0, hi: 0 },
  { name: "near", lo: 0.005, hi: 0.1 },
  { name: "mid", lo: 0.1, hi: 0.5 },
  { name: "far", lo: 0.5, hi: 1.5 },
];
const PLAN = {
  pair: { zero: 16, near: 40, mid: 40, far: 40 },
  compound: { zero: 6, near: 14, mid: 14, far: 14 },
  frame: { zero: 6, near: 14, mid: 14, far: 14 },
  torus: { zero: 6, near: 14, mid: 14, far: 14 },
};
const LITE_FRACTION = 4;
const round6 = (x) => Number(x.toFixed(6));

const bucketOf = (d) => (d === 0 ? "zero" : BUCKETS.find((b) => b.name !== "zero" && d >= b.lo && d < b.hi)?.name ?? null);

function reach(s) {
  const b = bounds(s);
  return norm(sub(b.max, b.min)) / 2;
}

function jitter(rng, u, maxAngle) {
  const n = normalize(u);
  const t = normalize(cross(n, rng.unit()));
  const ang = rng.range(0, maxAngle);
  return normalize(add(scale(n, Math.cos(ang)), scale(t, Math.sin(ang))));
}

function aim(rng, A, meta, concave) {
  if (concave && meta?.concavity) {
    const tag = A.type === "compound" ? "in_concavity" : "through_hole";
    const u = A.type === "compound" ? rng.unit() : jitter(rng, meta.normal, 0.5);
    return { anchor: add(meta.concavity, rng.vec(-0.05, 0.05)), u, tag };
  }
  const base = A.type === "torus" ? A.center : interiorPoint(A);
  return { anchor: add(base, rng.vec(-0.3, 0.3)), u: rng.unit(), tag: null };
}

// Certifies the reported distance: every convex piece pair is certified and
// the minimum over them must equal distance(). Torus pairs are closed form.
function certifiedDistance(A, B) {
  const d = distance(A, B);
  if (A.type === "torus" || B.type === "torus") return d;
  let best = Infinity;
  for (const pa of convexParts(A)) for (const pb of convexParts(B)) {
    const r = certify(pa, pb);
    best = Math.min(best, r.intersecting ? 0 : r.distance);
  }
  if (Math.abs(best - d) > 1e-9) throw new Error("distance not certified");
  return d;
}

function place(rng, A, b0, anchor, u, bucket) {
  const c0 = interiorPoint(b0);
  const at = (s) => translate(b0, sub(add(anchor, scale(u, s)), c0));
  const R = reach(A) + reach(b0) + 0.3;
  const steps = 48;
  const grid = Array.from({ length: steps + 1 }, (_, k) => -R + (2 * R * k) / steps);
  const labels = grid.map((s) => intersects(A, at(s)));
  const transitions = [];
  for (let k = 0; k < steps; k++) if (labels[k] !== labels[k + 1]) transitions.push(k);
  if (transitions.length === 0) return null;
  const k = rng.pick(transitions);
  let sIn = labels[k] ? grid[k] : grid[k + 1];
  let sOut = labels[k] ? grid[k + 1] : grid[k];
  for (let i = 0; i < 40; i++) {
    const mid = (sIn + sOut) / 2;
    if (intersects(A, at(mid))) sIn = mid;
    else sOut = mid;
  }
  const outward = Math.sign(sOut - sIn);
  const want0 = bucket.name === "zero";
  // near: log-uniform so small distances are well represented.
  const target = want0 ? rng.range(0.01, 0.15) : bucket.name === "near" ? Math.exp(rng.range(Math.log(bucket.lo), Math.log(bucket.hi))) : rng.range(bucket.lo, bucket.hi);
  let delta = target;
  for (let iter = 0; iter < 12; iter++) {
    const s = want0 ? sIn - outward * delta : sOut + outward * delta;
    const B = roundShape(at(s), ROUND);
    const d = distance(A, B);
    if (want0) {
      if (d === 0 && signedClearance(A, B) <= -MIN_DEPTH) return { B, d };
      delta *= 0.6;
      continue;
    }
    if (bucketOf(d) === bucket.name) return { B, d };
    if (d === 0) delta *= 1.5;
    else delta *= Math.min(4, Math.max(0.25, target / d));
  }
  return null;
}

const PARTNERS = {
  compound: ["point", "sphere", "aabb", "obb", "segment", "capsule", "cylinder", "cone", "tetrahedron", "triangle"],
  frame: ["point", "sphere", "obb", "segment", "capsule", "cylinder", "cone", "tetrahedron"],
  torus: ["sphere", "sphere", "sphere", "point"],
};

function pairCombos() {
  const low = { point: 0, segment: 1, triangle: 2 };
  const out = [];
  for (let i = 0; i < CONVEX_TYPES.length; i++) {
    for (let j = i; j < CONVEX_TYPES.length; j++) {
      // A distance question is meaningful for every pair, but zero-distance
      // problems need a pair that can overlap with positive depth.
      out.push({ types: [CONVEX_TYPES[i], CONVEX_TYPES[j]], canOverlap: (low[CONVEX_TYPES[i]] ?? 3) + (low[CONVEX_TYPES[j]] ?? 3) >= 3 });
    }
  }
  return out;
}

function generate(rng, category) {
  const combos = pairCombos();
  const items = [];
  for (const bucket of BUCKETS) {
    let made = 0;
    let tries = 0;
    while (made < PLAN[category][bucket.name]) {
      if (++tries > 20000) throw new Error(`cannot fill ${category}/${bucket.name}`);
      let ta;
      let tb;
      if (category === "pair") {
        const pool = bucket.name === "zero" ? combos.filter((c) => c.canOverlap) : combos;
        [ta, tb] = rng.pick(pool).types;
      } else {
        ta = category;
        tb = rng.pick(PARTNERS[category]);
        if (bucket.name === "zero" && ["point", "segment", "triangle"].includes(tb)) continue;
      }
      if (bucket.name === "zero" && (ta === "point" || tb === "point")) continue;
      const ga = makeShapeV2(ta, rng, rotate);
      const offset = rng.vec(-1, 1);
      const A = roundShape(translate(ga.shape, offset), ROUND);
      const meta = ga.meta && { ...ga.meta, concavity: add(ga.meta.concavity, offset) };
      const concave = category !== "pair" && made % 2 === 0;
      const { anchor, u, tag } = aim(rng, A, meta, concave);
      let b0 = makeShapeV2(tb, rng, rotate).shape;
      if (category === "torus" && b0.type === "sphere") b0 = { ...b0, radius: Math.min(b0.radius, A.major_radius) };
      const placed = place(rng, A, b0, anchor, u, bucket);
      if (!placed) continue;
      const { B } = placed;
      const d = certifiedDistance(A, B);
      const swap = rng.next() < 0.5;
      const objects = swap ? [B, A] : [A, B];
      items.push({
        category,
        objects: objects.map((o, i) => withId("AB"[i], o)),
        distance: d,
        bucket: bucket.name,
        types: objects.map((o) => o.type),
        feature: closestFeatures(objects[0], objects[1]),
        tags: [tag, ga.meta?.kind && `${ga.meta.kind}_shape`].filter(Boolean),
        lite: made % LITE_FRACTION === 0,
      });
      made++;
    }
  }
  return items;
}

function shuffle(rng, list) {
  const a = [...list];
  for (let i = a.length - 1; i > 0; i--) {
    const j = rng.int(i + 1);
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

function main() {
  const here = dirname(fileURLToPath(import.meta.url));
  const { values } = parseArgs({ options: { seed: { type: "string", default: "20261007" }, out: { type: "string", default: join(here, "data", "v3") } } });
  const seed = Number(values.seed);
  const rng = new Rng(seed);
  const items = [];
  for (const category of Object.keys(PLAN)) {
    items.push(...shuffle(rng, generate(rng, category)));
    process.stderr.write(`${category} done\n`);
  }
  const problems = [];
  const answers = [];
  const counter = {};
  for (const it of items) {
    counter[it.category] = (counter[it.category] ?? 0) + 1;
    const id = `${it.category}-${String(counter[it.category]).padStart(3, "0")}`;
    problems.push({ id, task: "distance", objects: it.objects });
    answers.push({
      id,
      task: "distance",
      category: it.category,
      split: it.lite ? "lite" : "full",
      answer: round6(it.distance),
      difficulty: it.bucket,
      feature: it.feature,
      types: it.types,
      tags: it.tags,
    });
  }
  const out = resolve(values.out);
  mkdirSync(out, { recursive: true });
  const jsonl = (rows) => rows.map((r) => JSON.stringify(r)).join("\n") + "\n";
  const files = { "problems.jsonl": jsonl(problems), "answers.jsonl": jsonl(answers) };
  for (const [name, body] of Object.entries(files)) writeFileSync(join(out, name), body);
  const manifest = {
    dataset_version: DATASET_VERSION,
    prompt_version: datasetSpec("v3").promptVersion,
    seed,
    tolerance: TOLERANCE,
    counts: Object.fromEntries(Object.keys(PLAN).map((k) => [k, answers.filter((a) => a.category === k).length])),
    lite_count: answers.filter((a) => a.split === "lite").length,
    buckets: BUCKETS,
    min_overlap_depth: MIN_DEPTH,
    sha256: Object.fromEntries(Object.entries(files).map(([n, b]) => [n, createHash("sha256").update(b).digest("hex")])),
  };
  writeFileSync(join(out, "manifest.json"), JSON.stringify(manifest, null, 2) + "\n");
  console.log(JSON.stringify(manifest, null, 2));
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main();
