#!/usr/bin/env node
// Generates hypercube-v2: harder than v1 on every axis v1 saturated.
//   track   - 12 or 24 moves in 4 to 6 dimensions
//   commute - do two move sequences give the same picture in either order?
//   solve   - scrambles of up to 6 moves, length not given, up to 6 dimensions
//
//   node benchmarks/hypercube/generate-v2.mjs   (writes data/v2 and batches/v2)

import { createHash } from "node:crypto";
import { mkdirSync, rmSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

import { PROMPT_VERSION_V2, batchPromptV2, movesText } from "./lib/prompt.mjs";
import { Rng, allStickers, applyMoves, applyToSticker, facingName, formatPos, inverseMove, randomMove, visibleDifferences, visibleState } from "./lib/puzzle.mjs";

const SEED = 20261017;
const TRACK = { dims: [4, 5, 6], depths: [12, 24], per: 3, batch: 6 };
const COMMUTE = { dims: [4, 5, 6], perAnswer: 4, batch: 8 };
const SOLVE = { cells: [[3, 5], [3, 6], [4, 4], [4, 5], [5, 3], [6, 1], [6, 2]], per: 3, batch: 3, limit: 6, maxMoves: 12 };
const FOLLOW = 0.75;

function shuffle(rng, a) {
  const r = [...a];
  for (let i = r.length - 1; i > 0; i--) {
    const j = rng.int(i + 1);
    [r[i], r[j]] = [r[j], r[i]];
  }
  return r;
}

function trackItem(rng, n, depth) {
  const all = allStickers(n);
  let s = all[rng.int(all.length)];
  const start = { at: formatPos(s.p), facing: facingName(s.f) };
  const moves = [];
  let turned = 0;
  let prev;
  while (moves.length < depth) {
    let m = randomMove(rng, n, prev);
    if (rng.next() < FOLLOW) {
      const axes = s.p.map((c, a) => (c ? a : -1)).filter((a) => a >= 0);
      const axis = axes[rng.int(axes.length)];
      if (prev && prev.axis === axis && prev.sign === s.p[axis]) continue;
      const rest = [...Array(n).keys()].filter((k) => k !== axis);
      const i = rest.splice(rng.int(rest.length), 1)[0];
      m = { sign: s.p[axis], axis, i, j: rest[rng.int(rest.length)] };
    }
    const next = applyToSticker(s, m);
    if (next !== s) turned++;
    s = next;
    moves.push(m);
    prev = m;
  }
  return { problem: { task: "track", n, moves: movesText(moves), start }, answer: { at: formatPos(s.p), facing: facingName(s.f), depth, turned } };
}

// How a commuting pair commutes, for the breakdown: opposite layers of one
// axis never share a piece; same-plane turns of different layers do share
// pieces and still commute; anything else is "other".
function commuteKind(a, b) {
  if (a.length !== 1 || b.length !== 1) return "sequence";
  const [x, y] = [a[0], b[0]];
  if (x.axis === y.axis && x.sign !== y.sign) return "opposite_layers";
  if (new Set([x.i, x.j]).size === 2 && [x.i, x.j].sort().join() === [y.i, y.j].sort().join()) return "same_plane";
  return "other";
}

function commuteCandidate(rng, n) {
  const seq = () => {
    const len = 1 + (rng.next() < 0.35 ? 1 : 0);
    const out = [];
    let prev;
    for (let k = 0; k < len; k++) out.push((prev = randomMove(rng, n, prev)));
    return out;
  };
  const a = seq();
  let b;
  const roll = rng.next();
  if (a.length === 1 && roll < 0.45) {
    // Same plane, another layer axis outside the plane: shares pieces with a.
    const plane = [a[0].i, a[0].j];
    const axes = [...Array(n).keys()].filter((k) => !plane.includes(k));
    const axis = axes[rng.int(axes.length)];
    const sign = axis === a[0].axis ? -a[0].sign : rng.next() < 0.5 ? -1 : 1;
    const flip = rng.next() < 0.5;
    b = [{ sign, axis, i: flip ? plane[1] : plane[0], j: flip ? plane[0] : plane[1] }];
  } else if (a.length === 1 && roll < 0.55) {
    // The opposite layer of the same axis: shares no piece with a.
    const rest = [...Array(n).keys()].filter((k) => k !== a[0].axis);
    const i = rest.splice(rng.int(rest.length), 1)[0];
    b = [{ sign: -a[0].sign, axis: a[0].axis, i, j: rest[rng.int(rest.length)] }];
  } else {
    b = seq();
  }
  const all = allStickers(n);
  const ab = visibleState(applyMoves(all, [...a, ...b]));
  const ba = visibleState(applyMoves(all, [...b, ...a]));
  return { a, b, commute: ab === ba };
}

function solveItem(rng, n, depth) {
  for (;;) {
    const moves = [];
    let prev;
    for (let k = 0; k < depth; k++) moves.push((prev = randomMove(rng, n, prev)));
    const state = visibleDifferences(applyMoves(allStickers(n), moves));
    if (state.length === 0) continue;
    const reference = moves.map(inverseMove).reverse();
    return {
      problem: { task: "solve", n, scramble_limit: SOLVE.limit, max_moves: SOLVE.maxMoves, state },
      answer: { reference: movesText(reference), depth, visible: state.length },
    };
  }
}

const here = dirname(fileURLToPath(import.meta.url));
const rng = new Rng(SEED);
const items = { track: [], commute: [], solve: [] };
for (const n of TRACK.dims) for (const d of TRACK.depths) for (let k = 0; k < TRACK.per; k++) items.track.push(trackItem(rng, n, d));
for (const n of COMMUTE.dims) {
  const want = { true: COMMUTE.perAnswer, false: COMMUTE.perAnswer };
  // Opposite layers commute for the obvious reason (no shared piece); keep one
  // per dimension so most YES answers share pieces and commute anyway.
  let obvious = 1;
  while (want.true + want.false > 0) {
    const c = commuteCandidate(rng, n);
    if (want[c.commute] === 0) continue;
    if (c.commute && commuteKind(c.a, c.b) === "opposite_layers") {
      if (obvious === 0) continue;
      obvious--;
    }
    want[c.commute]--;
    items.commute.push({
      problem: { task: "commute", n, a: movesText(c.a), b: movesText(c.b) },
      answer: { commute: c.commute, depth: c.a.length + c.b.length, kind: c.commute ? commuteKind(c.a, c.b) : "no" },
    });
  }
}
for (const [n, d] of SOLVE.cells) for (let k = 0; k < SOLVE.per; k++) items.solve.push(solveItem(rng, n, d));

const problems = [];
const answers = [];
for (const task of ["track", "commute", "solve"]) {
  shuffle(rng, items[task]).forEach((it, k) => {
    const id = `${task}-${String(k).padStart(3, "0")}`;
    problems.push({ id, ...it.problem });
    answers.push({ id, task, n: it.problem.n, ...it.answer });
  });
}

const dataDir = join(here, "data", "v2");
const batchDir = join(here, "batches", "v2");
mkdirSync(dataDir, { recursive: true });
rmSync(batchDir, { recursive: true, force: true });
mkdirSync(batchDir, { recursive: true });
const jsonl = (rows) => rows.map((r) => JSON.stringify(r)).join("\n") + "\n";
const files = { "problems.jsonl": jsonl(problems), "answers.jsonl": jsonl(answers) };
for (const [name, body] of Object.entries(files)) writeFileSync(join(dataDir, name), body);
writeFileSync(
  join(dataDir, "manifest.json"),
  JSON.stringify(
    {
      dataset_version: "hypercube-v2",
      prompt_version: PROMPT_VERSION_V2,
      seed: SEED,
      counts: Object.fromEntries(Object.entries(items).map(([k, v]) => [k, v.length])),
      sha256: Object.fromEntries(Object.entries(files).map(([n, b]) => [n, createHash("sha256").update(b).digest("hex")])),
    },
    null,
    2,
  ) + "\n",
);
let b = 0;
for (const [task, size] of [["track", TRACK.batch], ["commute", COMMUTE.batch], ["solve", SOLVE.batch]]) {
  const list = problems.filter((p) => p.task === task);
  for (let i = 0; i < list.length; i += size) writeFileSync(join(batchDir, `batch-${String(b++).padStart(2, "0")}-${task}.txt`), batchPromptV2(task, list.slice(i, i + size)) + "\n");
}
console.log(`wrote ${problems.length} problems and ${b} batches`);
