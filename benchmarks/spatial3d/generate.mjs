#!/usr/bin/env node
// Generates the spatial3d dataset.
//
//   node benchmarks/spatial3d/generate.mjs [--seed 20261005] [--out benchmarks/spatial3d/data]
//
// The committed data/ is the canonical dataset; regenerating on another
// machine is expected to reproduce it but the scorer only trusts the files.

import { createHash } from "node:crypto";
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { parseArgs } from "node:util";

import { add, characteristicSize, cross, interiorPoint, intersects, normalize, scale, signedClearance, translate } from "./lib/geometry.mjs";
import { PROMPT_VERSION } from "./lib/prompt.mjs";
import { CONVEX_TYPES, Rng, makeShape, pairIsMeaningful, roundShape, withId } from "./lib/shapes.mjs";
import { certify } from "./lib/verify.mjs";

export const DATASET_VERSION = "spatial3d-v1";

// Relative margin = |clearance| / size of the smaller object.
export const BUCKETS = [
  { name: "hard", lo: 0.02, hi: 0.1 },
  { name: "medium", lo: 0.1, hi: 0.3 },
  { name: "easy", lo: 0.3, hi: 1.0 },
];
const MIN_ABS_CLEARANCE = 0.01;

const PLAN = { pair: 40, torus: 6, scene: 24 }; // pair/torus: per (label, bucket) cell
const LITE_FRACTION = 4; // every 4th item of each cell is in the "lite" split

function bucketOf(rel) {
  return BUCKETS.find((b) => rel >= b.lo && rel < b.hi)?.name ?? null;
}

function measure(a, b) {
  const clearance = signedClearance(a, b);
  const size = Math.min(characteristicSize(a), characteristicSize(b));
  const rel = Math.abs(clearance) / size;
  return { clearance, rel, bucket: Math.abs(clearance) < MIN_ABS_CLEARANCE ? null : bucketOf(rel) };
}

const round6 = (x) => Number(x.toFixed(6));

function shapeSize(s) {
  return characteristicSize(s);
}

// Places b along a random direction from a so that the result lands near the
// requested signed relative margin, then rounds and re-measures.
function placePair(rng, ta, tb, wantIntersect, bucket) {
  const a0 = makeShape(ta, rng);
  const a = translate(a0, rng.vec(-1.5, 1.5));
  const b0 = makeShape(tb, rng);
  const u = rng.unit();
  const ca = interiorPoint(a);
  const at = (s) => translate(b0, add(ca, scale(u, s)));
  let lo = 0;
  let hi = 8;
  if (intersects(a, at(hi))) return null;
  for (let i = 0; i < 40; i++) {
    const mid = (lo + hi) / 2;
    if (intersects(a, at(mid))) lo = mid;
    else hi = mid;
  }
  const size = Math.min(shapeSize(a), shapeSize(b0));
  const target = rng.range(bucket.lo, bucket.hi) * size;
  const s = Math.max(0, wantIntersect ? hi - target * rng.range(1, 2.5) : hi + target);
  return [roundShape(a), roundShape(at(s))];
}

function placeTorus(rng, wantIntersect, bucket) {
  const torus = roundShape(translate(makeShape("torus", rng), rng.vec(-1, 1)));
  const n = normalize(torus.axis);
  const e1 = normalize(cross(n, Math.abs(n[0]) < 0.9 ? [1, 0, 0] : [0, 1, 0]));
  const e2 = cross(n, e1);
  const R = torus.major_radius;
  const r = torus.minor_radius;
  const isPoint = rng.next() < 0.25;
  const radius = isPoint ? 0 : rng.range(0.15, Math.min(1.2, R));
  // Half the samples sit in the hole's cylinder, where a bounding-box or
  // "is it near the centre" heuristic gives the wrong answer.
  const hole = rng.next() < 0.5;
  const rho = hole ? rng.range(0, Math.max(0.05, R - r)) : rng.range(0, R + r + radius + 1);
  const h = rng.range(-1, 1) * (r + radius + 0.8);
  const phi = rng.range(0, 2 * Math.PI);
  const p = add(torus.center, add(scale(add(scale(e1, Math.cos(phi)), scale(e2, Math.sin(phi))), rho), scale(n, h)));
  const other = roundShape(isPoint ? { type: "point", position: p } : { type: "sphere", center: p, radius });
  return [torus, other, hole];
}

function* cells() {
  for (const bucket of BUCKETS) for (const label of [true, false]) yield { bucket, label };
}

function generatePairs(rng) {
  const combos = [];
  for (let i = 0; i < CONVEX_TYPES.length; i++) {
    for (let j = i; j < CONVEX_TYPES.length; j++) {
      if (pairIsMeaningful(CONVEX_TYPES[i], CONVEX_TYPES[j])) combos.push([CONVEX_TYPES[i], CONVEX_TYPES[j]]);
    }
  }
  const items = [];
  for (const { bucket, label } of cells()) {
    let made = 0;
    while (made < PLAN.pair) {
      let [ta, tb] = rng.pick(combos);
      if (rng.next() < 0.5) [ta, tb] = [tb, ta];
      const placed = placePair(rng, ta, tb, label, bucket);
      if (!placed) continue;
      const [a, b] = placed;
      const m = measure(a, b);
      const truth = certify(a, b).intersecting;
      if (truth !== label || m.bucket !== bucket.name || truth !== m.clearance < 0) continue;
      items.push({ kind: "pair", objects: [withId("A", a), withId("B", b)], truth, m, types: [ta, tb], tags: [], lite: made % LITE_FRACTION === 0 });
      made++;
    }
  }
  return items;
}

function generateTorus(rng) {
  const items = [];
  for (const { bucket, label } of cells()) {
    let made = 0;
    while (made < PLAN.torus) {
      const [torus, other, hole] = placeTorus(rng, label, bucket);
      const m = measure(torus, other);
      if (m.bucket !== bucket.name || m.clearance < 0 !== label) continue;
      const objects = rng.next() < 0.5 ? [torus, other] : [other, torus];
      items.push({
        kind: "torus",
        objects: objects.map((o, i) => withId("AB"[i], o)),
        truth: label,
        m,
        types: objects.map((o) => o.type),
        tags: hole ? ["through_hole"] : [],
        lite: made % LITE_FRACTION === 0,
      });
      made++;
    }
  }
  return items;
}

function generateScenes(rng) {
  const ids = ["A", "B", "C", "D", "E"];
  const items = [];
  while (items.length < PLAN.scene) {
    const objects = ids.map((id) => withId(id, roundShape(translate(makeShape(rng.pick(CONVEX_TYPES), rng), rng.vec(-2, 2)))));
    const pairs = [];
    let ok = true;
    for (let i = 0; i < ids.length && ok; i++) {
      for (let j = i + 1; j < ids.length && ok; j++) {
        const m = measure(objects[i], objects[j]);
        if (!m.bucket || certify(objects[i], objects[j]).intersecting !== m.clearance < 0) ok = false;
        else pairs.push({ pair: `${ids[i]}-${ids[j]}`, intersects: m.clearance < 0, clearance: round6(m.clearance), relative_margin: round6(m.rel) });
      }
    }
    if (!ok) continue;
    const hits = pairs.filter((p) => p.intersects).length;
    if (hits < 1 || hits > 6) continue;
    const minRel = Math.min(...pairs.map((p) => p.relative_margin));
    items.push({ kind: "scene", objects, pairs, minRel, lite: items.length % LITE_FRACTION === 0 });
  }
  return items;
}

function toRecords(items) {
  const problems = [];
  const answers = [];
  const counter = { pair: 0, torus: 0, scene: 0 };
  for (const it of items) {
    counter[it.kind]++;
    const id = `${it.kind}-${String(counter[it.kind]).padStart(3, "0")}`;
    const split = it.lite ? "lite" : "full";
    const task = it.kind === "scene" ? "scene" : "pair";
    problems.push({ id, task, objects: it.objects });
    if (task === "pair") {
      answers.push({
        id,
        task,
        category: it.kind,
        split,
        answer: it.truth,
        clearance: round6(it.m.clearance),
        relative_margin: round6(it.m.rel),
        difficulty: it.m.bucket,
        types: it.types,
        tags: it.tags,
      });
    } else {
      answers.push({
        id,
        task,
        category: "scene",
        split,
        answer: it.pairs.filter((p) => p.intersects).map((p) => p.pair),
        difficulty: bucketOf(it.minRel) ?? "easy",
        min_relative_margin: it.minRel,
        types: it.objects.map((o) => o.type),
        pairs: it.pairs,
      });
    }
  }
  return { problems, answers };
}

// Interleave so that the file order does not leak the label or bucket.
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
  const { values } = parseArgs({ options: { seed: { type: "string", default: "20261005" }, out: { type: "string", default: join(here, "data") } } });
  const seed = Number(values.seed);
  const rng = new Rng(seed);
  const pairs = shuffle(rng, generatePairs(rng));
  const tori = shuffle(rng, generateTorus(rng));
  const scenes = generateScenes(rng);
  const { problems, answers } = toRecords([...pairs, ...tori, ...scenes]);
  const out = resolve(values.out);
  mkdirSync(out, { recursive: true });
  const jsonl = (rows) => rows.map((r) => JSON.stringify(r)).join("\n") + "\n";
  const files = { "problems.jsonl": jsonl(problems), "answers.jsonl": jsonl(answers) };
  for (const [name, body] of Object.entries(files)) writeFileSync(join(out, name), body);
  const manifest = {
    dataset_version: DATASET_VERSION,
    prompt_version: PROMPT_VERSION,
    seed,
    counts: Object.fromEntries(["pair", "torus", "scene"].map((k) => [k, answers.filter((a) => a.category === k).length])),
    lite_count: answers.filter((a) => a.split === "lite").length,
    buckets: BUCKETS,
    sha256: Object.fromEntries(Object.entries(files).map(([n, b]) => [n, createHash("sha256").update(b).digest("hex")])),
  };
  writeFileSync(join(out, "manifest.json"), JSON.stringify(manifest, null, 2) + "\n");
  console.log(JSON.stringify(manifest, null, 2));
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main();
