#!/usr/bin/env node
// Scores reply files ("<id>: <answer>" lines) against a hypercube dataset.
//
//   node score.mjs [--dataset v1|v2] results/<dataset>/<label>.answers.txt [more.txt ...]
//
// The dataset defaults to the results/<dataset>/ directory a file sits in.

import { readFileSync } from "node:fs";
import { basename, dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

import { grade } from "./lib/check.mjs";

const here = dirname(fileURLToPath(import.meta.url));
const args = process.argv.slice(2);
const forced = args[0] === "--dataset" ? (args.shift(), args.shift()) : null;

for (const file of args) {
  const dataset = forced ?? basename(dirname(file));
  const rd = (f) => readFileSync(join(here, "data", dataset, f), "utf8").trim().split("\n").map(JSON.parse);
  const problems = new Map(rd("problems.jsonl").map((p) => [p.id, p]));
  const answers = new Map(rd("answers.jsonl").map((a) => [a.id, a]));
  const replies = new Map();
  for (const line of readFileSync(file, "utf8").split(/\r?\n/)) {
    const m = line.replace(/[*`]/g, "").match(/^\s*((?:track|solve|commute)-\d{3})\s*:\s*(.+?)\s*$/);
    if (m) replies.set(m[1], m[2]);
  }
  const groups = new Map();
  const add = (key, ok) => {
    const g = groups.get(key) ?? { ok: 0, all: 0 };
    g.all++;
    if (ok) g.ok++;
    groups.set(key, g);
  };
  const misses = [];
  for (const [id, p] of problems) {
    const a = answers.get(id);
    const r = grade(p, a, replies.get(id));
    add(`${p.task} all`, r.ok);
    add(`${p.task} n=${p.n}`, r.ok);
    add(`${p.task} n=${p.n} depth=${a.depth}`, r.ok);
    if (p.task === "commute") add(`commute answer=${a.commute ? "yes" : "no"} kind=${a.kind}`, r.ok);
    if (!r.ok) misses.push(`${id} (n=${p.n}, depth=${a.depth}): ${r.reason}`);
  }
  console.log(`## ${basename(file)} (${dataset}): answered ${replies.size}/${problems.size}\n`);
  console.log("| group | correct |\n|---|---|");
  for (const [k, g] of [...groups].sort()) console.log(`| ${k} | ${g.ok}/${g.all} |`);
  if (misses.length) console.log(`\nmisses:\n${misses.map((m) => `- ${m}`).join("\n")}`);
  console.log();
}
