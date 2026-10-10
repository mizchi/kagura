#!/usr/bin/env node
// Generates the spatial3d-v2 dataset (harder than v1 on every axis).
//
//   node benchmarks/spatial3d/generate-v2.mjs [--seed 20261006] [--out benchmarks/spatial3d/data/v2]
//
// Differences from v1:
// - margins down to 0.2% of object size (coordinates have 3 decimals)
// - boxes are rotated by quaternion instead of explicit axes
// - non-convex shapes: compound (L/U of boxes), frame (plate with a hole),
//   torus; half of those problems aim the other object into the concavity
// - scenes have 8-10 objects (28-45 pairs)

import { createHash } from "node:crypto";
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { parseArgs } from "node:util";

import { add, bounds, characteristicSize, cross, interiorPoint, intersects, norm, normalize, rotate, scale, signedClearance, sub, translate } from "./lib/geometry.mjs";
import { datasetSpec } from "./lib/prompt.mjs";
import { CONVEX_TYPES, Rng, makeShapeV2, roundShape, withId } from "./lib/shapes.mjs";
import { certifyAll } from "./lib/verify.mjs";

export const DATASET_VERSION = "spatial3d-v2";
const ROUND = { pos: 3, axis: 4 };

// Relative margin = |clearance| / size of the smaller object (for unions,
// the smallest piece).
export const BUCKETS = [
  { name: "extreme", lo: 0.002, hi: 0.01 },
  { name: "hard", lo: 0.01, hi: 0.03 },
  { name: "medium", lo: 0.03, hi: 0.1 },
];
const MIN_ABS_CLEARANCE = 0.002;
const SCENE_MIN_REL = 0.01;

// pair/compound/frame/torus: problems per (label, bucket) cell.
const PLAN = { pair: 30, compound: 8, frame: 8, torus: 8, scene: 24 };
const LITE_FRACTION = 4;

const round6 = (x) => Number(x.toFixed(6));
const bucketOf = (rel) => BUCKETS.find((b) => rel >= b.lo && rel < b.hi)?.name ?? (rel >= 0.1 ? "easy" : null);

function measure(a, b) {
  const clearance = signedClearance(a, b);
  const size = Math.min(characteristicSize(a), characteristicSize(b));
  const rel = Math.abs(clearance) / size;
  return { clearance, rel, bucket: Math.abs(clearance) < MIN_ABS_CLEARANCE ? null : bucketOf(rel) };
}

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

// Moves b0 (centred on its interior point) along the line anchor + s*u.
// Scans for a label change, bisects to the boundary, then steps off it
// until the measured margin lands in the requested bucket.
function placeOnLine(rng, A, b0, anchor, u, wantIntersect, bucket) {
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
  const size = Math.min(characteristicSize(A), characteristicSize(b0));
  const target = rng.range(bucket.lo, bucket.hi) * size;
  let delta = target;
  for (let iter = 0; iter < 10; iter++) {
    const s = wantIntersect ? sIn - outward * delta : sOut + outward * delta;
    const B = roundShape(at(s), ROUND);
    const m = measure(A, B);
    const sideOk = m.clearance < 0 === wantIntersect;
    if (sideOk && m.bucket === bucket.name) return { B, m };
    if (!sideOk || m.rel === 0) delta *= 0.5;
    else delta *= Math.min(4, Math.max(0.25, target / Math.abs(m.clearance)));
  }
  return null;
}

// Where to aim the second object, and from which direction.
function aim(rng, A, meta, concave) {
  if (concave && meta?.concavity) {
    const tag = A.type === "compound" ? "in_concavity" : "through_hole";
    // Through a hole: travel along the hole's axis. Into a notch: any direction.
    const u = A.type === "compound" ? rng.unit() : jitter(rng, meta.normal, 0.5);
    return { anchor: add(meta.concavity, rng.vec(-0.05, 0.05)), u, tag };
  }
  const base = A.type === "torus" ? A.center : interiorPoint(A);
  return { anchor: add(base, rng.vec(-0.3, 0.3)), u: rng.unit(), tag: null };
}

const PARTNERS = {
  pair: CONVEX_TYPES,
  compound: ["point", "sphere", "aabb", "obb", "segment", "capsule", "cylinder", "cone", "tetrahedron", "triangle"],
  frame: ["point", "sphere", "obb", "segment", "capsule", "cylinder", "cone", "tetrahedron"],
  torus: ["sphere", "sphere", "sphere", "point"],
};

function pairCombos() {
  const low = { point: 0, segment: 1, triangle: 2 };
  const out = [];
  for (let i = 0; i < CONVEX_TYPES.length; i++) {
    for (let j = i; j < CONVEX_TYPES.length; j++) {
      if ((low[CONVEX_TYPES[i]] ?? 3) + (low[CONVEX_TYPES[j]] ?? 3) >= 3) out.push([CONVEX_TYPES[i], CONVEX_TYPES[j]]);
    }
  }
  return out;
}

function generatePairs(rng, category) {
  const combos = pairCombos();
  const items = [];
  for (const bucket of BUCKETS) {
    for (const label of [true, false]) {
      let made = 0;
      let tries = 0;
      while (made < PLAN[category]) {
        if (++tries > 5000) throw new Error(`cannot fill ${category}/${bucket.name}/${label}`);
        const [ta, tb] = category === "pair" ? rng.pick(combos) : [category, rng.pick(PARTNERS[category])];
        const ga = makeShapeV2(ta, rng, rotate);
        const offset = rng.vec(-1, 1);
        const A = roundShape(translate(ga.shape, offset), ROUND);
        const meta = ga.meta && { ...ga.meta, concavity: add(ga.meta.concavity, offset) };
        // Half of the non-convex problems aim into the hole or notch.
        const concave = category !== "pair" && made % 2 === 0;
        const { anchor, u, tag } = aim(rng, A, meta, concave);
        let b0 = makeShapeV2(tb, rng, rotate).shape;
        if (category === "torus" && b0.type === "sphere") b0 = { ...b0, radius: Math.min(b0.radius, A.major_radius) };
        const placed = placeOnLine(rng, A, b0, anchor, u, label, bucket);
        if (!placed) continue;
        const { B, m } = placed;
        if (A.type !== "torus" && certifyAll(A, B) !== label) throw new Error("certificate disagrees with clearance");
        const swap = rng.next() < 0.5;
        const objects = swap ? [B, A] : [A, B];
        items.push({
          kind: category,
          objects: objects.map((o, i) => withId("AB"[i], o)),
          truth: label,
          m,
          types: objects.map((o) => o.type),
          tags: [tag, ga.meta?.kind && `${ga.meta.kind}_shape`].filter(Boolean),
          lite: made % LITE_FRACTION === 0,
        });
        made++;
      }
    }
  }
  return items;
}

const SCENE_TYPES = [...CONVEX_TYPES, ...CONVEX_TYPES.filter((t) => t !== "point"), "compound", "compound", "frame", "frame"];

function generateScenes(rng) {
  const items = [];
  let tries = 0;
  while (items.length < PLAN.scene) {
    if (++tries > 20000) throw new Error("cannot fill scenes");
    const count = 8 + rng.int(3);
    const ids = "ABCDEFGHIJ".slice(0, count).split("");
    const objects = ids.map((id) => withId(id, roundShape(translate(makeShapeV2(rng.pick(SCENE_TYPES), rng, rotate).shape, rng.vec(-2.6, 2.6)), ROUND)));
    // Cheap pass first: reject scenes with a near-contact separated pair or
    // the wrong number of hits before paying for depth estimates.
    let hits = 0;
    for (let i = 0; i < count; i++) for (let j = i + 1; j < count; j++) if (intersects(objects[i], objects[j])) hits++;
    if (hits < 4 || hits > 16) continue;
    const pairs = [];
    let ok = true;
    for (let i = 0; i < count && ok; i++) {
      for (let j = i + 1; j < count && ok; j++) {
        const m = measure(objects[i], objects[j]);
        if (Math.abs(m.clearance) < MIN_ABS_CLEARANCE || m.rel < SCENE_MIN_REL) ok = false;
        else if (certifyAll(objects[i], objects[j]) !== m.clearance < 0) throw new Error("scene certificate disagrees");
        else pairs.push({ pair: `${ids[i]}-${ids[j]}`, intersects: m.clearance < 0, clearance: round6(m.clearance), relative_margin: round6(m.rel) });
      }
    }
    if (!ok) continue;
    const minRel = Math.min(...pairs.map((p) => p.relative_margin));
    items.push({ kind: "scene", objects, pairs, minRel, lite: items.length % LITE_FRACTION === 0 });
    process.stderr.write(`scene ${items.length}/${PLAN.scene} (${tries} tries)\n`);
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

function toRecords(items) {
  const problems = [];
  const answers = [];
  const counter = {};
  for (const it of items) {
    counter[it.kind] = (counter[it.kind] ?? 0) + 1;
    const id = `${it.kind}-${String(counter[it.kind]).padStart(3, "0")}`;
    const split = it.lite ? "lite" : "full";
    if (it.kind === "scene") {
      problems.push({ id, task: "scene", objects: it.objects });
      answers.push({
        id,
        task: "scene",
        category: "scene",
        split,
        answer: it.pairs.filter((p) => p.intersects).map((p) => p.pair),
        difficulty: bucketOf(it.minRel),
        min_relative_margin: it.minRel,
        types: it.objects.map((o) => o.type),
        pairs: it.pairs,
      });
    } else {
      problems.push({ id, task: "pair", objects: it.objects });
      answers.push({
        id,
        task: "pair",
        category: it.kind,
        split,
        answer: it.truth,
        clearance: round6(it.m.clearance),
        relative_margin: round6(it.m.rel),
        difficulty: it.m.bucket,
        types: it.types,
        tags: it.tags,
      });
    }
  }
  return { problems, answers };
}

function main() {
  const here = dirname(fileURLToPath(import.meta.url));
  const { values } = parseArgs({ options: { seed: { type: "string", default: "20261006" }, out: { type: "string", default: join(here, "data", "v2") } } });
  const seed = Number(values.seed);
  const rng = new Rng(seed);
  const groups = [];
  for (const category of ["pair", "compound", "frame", "torus"]) {
    groups.push(...shuffle(rng, generatePairs(rng, category)));
    process.stderr.write(`${category} done\n`);
  }
  const scenes = generateScenes(rng);
  const { problems, answers } = toRecords([...groups, ...scenes]);
  const out = resolve(values.out);
  mkdirSync(out, { recursive: true });
  const jsonl = (rows) => rows.map((r) => JSON.stringify(r)).join("\n") + "\n";
  const files = { "problems.jsonl": jsonl(problems), "answers.jsonl": jsonl(answers) };
  for (const [name, body] of Object.entries(files)) writeFileSync(join(out, name), body);
  const manifest = {
    dataset_version: DATASET_VERSION,
    prompt_version: datasetSpec("v2").promptVersion,
    seed,
    counts: Object.fromEntries(["pair", "compound", "frame", "torus", "scene"].map((k) => [k, answers.filter((a) => a.category === k).length])),
    lite_count: answers.filter((a) => a.split === "lite").length,
    buckets: BUCKETS,
    min_abs_clearance: MIN_ABS_CLEARANCE,
    scene_min_relative_margin: SCENE_MIN_REL,
    sha256: Object.fromEntries(Object.entries(files).map(([n, b]) => [n, createHash("sha256").update(b).digest("hex")])),
  };
  writeFileSync(join(out, "manifest.json"), JSON.stringify(manifest, null, 2) + "\n");
  console.log(JSON.stringify(manifest, null, 2));
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main();
