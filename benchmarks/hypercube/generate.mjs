#!/usr/bin/env node
// Generates hypercube-v1: track a sticker through n-dimensional twists, and
// solve short scrambles from the visible state.
//
//   node benchmarks/hypercube/generate.mjs   (writes data/v1 and batches/v1)

import { createHash } from "node:crypto";
import { mkdirSync, rmSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

import { batchPrompt, movesText, PROMPT_VERSION } from "./lib/prompt.mjs";
import { Rng, allStickers, applyMoves, applyToSticker, facingName, formatPos, inverseMove, randomMove, visibleDifferences } from "./lib/puzzle.mjs";

const SEED = 20261009;
const TRACK = { dims: [3, 4, 5], depths: [1, 3, 6, 10], per: 4, batch: 8 };
const SOLVE = { cells: [[3, 1], [3, 2], [3, 3], [4, 1], [4, 2], [4, 3], [5, 1], [5, 2]], per: 3, batch: 4 };
const FOLLOW = 0.75; // chance a track move turns the tracked sticker's piece

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

function solveItem(rng, n, depth) {
  const moves = [];
  let prev;
  for (let k = 0; k < depth; k++) moves.push((prev = randomMove(rng, n, prev)));
  const state = visibleDifferences(applyMoves(allStickers(n), moves));
  const reference = moves.map(inverseMove).reverse();
  return { problem: { task: "solve", n, depth, max_moves: Math.max(6, 2 * depth), state }, answer: { reference: movesText(reference), depth, visible: state.length } };
}

const here = dirname(fileURLToPath(import.meta.url));
const rng = new Rng(SEED);
const items = { track: [], solve: [] };
for (const n of TRACK.dims) for (const d of TRACK.depths) for (let k = 0; k < TRACK.per; k++) items.track.push(trackItem(rng, n, d));
for (const [n, d] of SOLVE.cells) for (let k = 0; k < SOLVE.per; k++) items.solve.push(solveItem(rng, n, d));

const problems = [];
const answers = [];
for (const task of ["track", "solve"]) {
  shuffle(rng, items[task]).forEach((it, k) => {
    const id = `${task}-${String(k).padStart(3, "0")}`;
    problems.push({ id, ...it.problem });
    answers.push({ id, task, n: it.problem.n, ...it.answer });
  });
}

const dataDir = join(here, "data", "v1");
const batchDir = join(here, "batches", "v1");
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
      dataset_version: "hypercube-v1",
      prompt_version: PROMPT_VERSION,
      seed: SEED,
      counts: { track: items.track.length, solve: items.solve.length },
      sha256: Object.fromEntries(Object.entries(files).map(([n, b]) => [n, createHash("sha256").update(b).digest("hex")])),
    },
    null,
    2,
  ) + "\n",
);
let b = 0;
for (const [task, size] of [["track", TRACK.batch], ["solve", SOLVE.batch]]) {
  const list = problems.filter((p) => p.task === task);
  for (let i = 0; i < list.length; i += size) writeFileSync(join(batchDir, `batch-${String(b++).padStart(2, "0")}-${task}.txt`), batchPrompt(task, list.slice(i, i + size)) + "\n");
}
console.log(`wrote ${problems.length} problems and ${b} batches`);
