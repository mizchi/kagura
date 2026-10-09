// node --test benchmarks/hypercube/*.test.mjs
import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import test from "node:test";

import { grade, scrambleOf } from "./lib/check.mjs";
import { Rng, allStickers, applyMoves, applyToSticker, facingName, formatPos, isSolved, parseMoves, randomMove, visibleDifferences } from "./lib/puzzle.mjs";

test("sticker counts are 2n * 3^(n-1)", () => {
  for (const n of [2, 3, 4, 5]) assert.equal(allStickers(n).length, 2 * n * 3 ** (n - 1));
});

test("the rules text example holds", () => {
  const [m] = parseMoves("+z:x>y", 3);
  const s = applyToSticker({ p: [1, 0, 1], f: [1, 0, 0] }, m);
  assert.deepEqual([formatPos(s.p), facingName(s.f)], ["(0,1,1)", "+y"]);
});

test("a move has order 4, its written inverse undoes it, and centres never move", () => {
  const rng = new Rng(1);
  for (const n of [3, 4, 5]) {
    const all = allStickers(n);
    for (let k = 0; k < 30; k++) {
      const m = randomMove(rng, n);
      assert.ok(!isSolved(applyMoves(all, [m])));
      assert.ok(isSolved(applyMoves(all, [m, m, m, m])));
      assert.ok(isSolved(applyMoves(all, [m, { ...m, i: m.j, j: m.i }])));
    }
  }
});

test("n = 3 matches the Rubik's cube: a face turn changes 12 visible stickers, sexy move has order 6", () => {
  const all = allStickers(3);
  assert.equal(visibleDifferences(applyMoves(all, parseMoves("+x:y>z", 3))).length, 12);
  const sexy = parseMoves("+x:y>z, +z:x>y, +x:z>y, +z:y>x", 3);
  let s = all;
  const orders = [];
  for (let k = 1; k <= 6; k++) {
    s = applyMoves(s, sexy);
    if (isSolved(s)) orders.push(k);
  }
  assert.deepEqual(orders, [6]);
});

test("committed data re-derives from the answer key", () => {
  const dir = new URL("./data/v1/", import.meta.url);
  const manifest = JSON.parse(readFileSync(new URL("manifest.json", dir), "utf8"));
  for (const [name, sha] of Object.entries(manifest.sha256)) assert.equal(createHash("sha256").update(readFileSync(new URL(name, dir))).digest("hex"), sha, name);
  const rows = (f) => readFileSync(new URL(f, dir), "utf8").trim().split("\n").map(JSON.parse);
  const answers = new Map(rows("answers.jsonl").map((a) => [a.id, a]));
  for (const p of rows("problems.jsonl")) {
    const a = answers.get(p.id);
    if (p.task === "track") {
      const all = allStickers(p.n).filter((s) => formatPos(s.p) === p.start.at && facingName(s.f) === p.start.facing);
      assert.equal(all.length, 1, p.id);
      const end = applyMoves(all, parseMoves(p.moves.join(","), p.n))[0];
      assert.deepEqual([formatPos(end.p), facingName(end.f)], [a.at, a.facing], p.id);
      assert.ok(grade(p, a, `${a.at} ${a.facing}`).ok, p.id);
    } else {
      assert.deepEqual(visibleDifferences(applyMoves(allStickers(p.n), scrambleOf(a))), p.state, p.id);
      assert.ok(grade(p, a, a.reference.join(", ")).ok, p.id);
      // One extra move after a solution leaves it unsolved.
      assert.ok(!grade(p, a, [...a.reference, a.reference[0]].join(", ")).ok, p.id);
    }
  }
});
