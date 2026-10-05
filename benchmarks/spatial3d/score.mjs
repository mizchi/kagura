#!/usr/bin/env node
// Scores spatial3d replies against the answer key.
//
//   node score.mjs results/v2/<model>.responses.jsonl [more.jsonl ...] [--split lite] [--json] [--dataset v2]
//
// The dataset is taken from the rows' prompt_version unless --dataset is
// given; files from different datasets cannot be scored together.
//
// A response row needs {id, response} (raw text) or {id, parsed}. The
// answer is re-parsed from `response` when present, so rows written by any
// harness score the same way. Missing or unparsable answers count as wrong.

import { readFileSync } from "node:fs";
import { basename, dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { parseArgs } from "node:util";

import { DATASETS, parseAnswer } from "./lib/prompt.mjs";

const TOLERANCE = 0.001;

const here = dirname(fileURLToPath(import.meta.url));
const { values: opt, positionals } = parseArgs({
  allowPositionals: true,
  options: { split: { type: "string", default: "all" }, json: { type: "boolean", default: false }, dataset: { type: "string" } },
});

const readJsonl = (p) =>
  readFileSync(p, "utf8")
    .split("\n")
    .filter(Boolean)
    .map((l) => JSON.parse(l));

function datasetOfRows(rows) {
  const pv = rows.find((r) => r.prompt_version)?.prompt_version ?? "";
  return Object.entries(DATASETS).find(([, spec]) => pv === spec.promptVersion || pv.startsWith(`${spec.promptVersion}+`))?.[0];
}
let answers = null;
let datasetName = opt.dataset;
function loadAnswers(name) {
  if (datasetName && datasetName !== name) throw new Error(`cannot mix datasets ${datasetName} and ${name}`);
  datasetName = name;
  answers ??= readJsonl(join(here, "data", name, "answers.jsonl")).filter((a) => opt.split === "all" || a.split === opt.split);
}

// Wilson score interval, 95%.
function wilson(k, n) {
  if (n === 0) return [0, 0];
  const z = 1.96;
  const p = k / n;
  const d = 1 + (z * z) / n;
  const c = p + (z * z) / (2 * n);
  const m = z * Math.sqrt((p * (1 - p)) / n + (z * z) / (4 * n * n));
  return [(c - m) / d, (c + m) / d];
}

function tally() {
  return { k: 0, n: 0 };
}
function bump(map, key, ok) {
  const t = (map[key] ??= tally());
  t.n++;
  if (ok) t.k++;
}

export function score(rows) {
  const byId = new Map(rows.map((r) => [r.id, r]));
  const groups = { overall: {}, category: {}, difficulty: {}, label: {}, feature: {}, shape: {}, tag: {} };
  const scene = { exact: tally(), pairs: tally(), tp: 0, fp: 0, fn: 0, byDifficulty: {} };
  // v3: absolute errors of numeric answers (Infinity when missing).
  const dist = { errors: [], signed: [], within01: tally(), within1pct: tally(), zero: tally() };
  let answered = 0;
  let unparsed = 0;
  for (const a of answers) {
    const row = byId.get(a.id);
    const parsed = row ? (typeof row.response === "string" ? parseAnswer(a.task, row.response) : row.parsed ?? null) : null;
    if (row) answered++;
    if (row && parsed === null) unparsed++;
    if (a.task === "distance") {
      const has = typeof parsed === "number" && Number.isFinite(parsed);
      const err = has ? Math.abs(parsed - a.answer) : Infinity;
      const ok = err <= TOLERANCE + 1e-12;
      bump(groups.overall, `distance within ${TOLERANCE}`, ok);
      bump(groups.category, a.category, ok);
      bump(groups.difficulty, `${a.category}/${a.difficulty}`, ok);
      bump(groups.difficulty, `all/${a.difficulty}`, ok);
      bump(groups.feature, a.feature, ok);
      for (const t of new Set(a.types)) bump(groups.shape, t, ok);
      for (const t of a.tags) bump(groups.tag, t, ok);
      dist.errors.push(err);
      if (has) dist.signed.push(parsed - a.answer);
      dist.within01.n++;
      if (err <= 0.01) dist.within01.k++;
      if (a.answer > 0) {
        dist.within1pct.n++;
        if (err <= 0.01 * a.answer) dist.within1pct.k++;
      } else {
        dist.zero.n++;
        if (ok) dist.zero.k++;
      }
    } else if (a.task === "pair") {
      const ok = parsed === a.answer;
      bump(groups.overall, "pair tasks", ok);
      bump(groups.category, a.category, ok);
      bump(groups.difficulty, `${a.category}/${a.difficulty}`, ok);
      bump(groups.label, `${a.category}/${a.answer ? "intersecting" : "separated"}`, ok);
      for (const t of new Set(a.types)) bump(groups.shape, t, ok);
      for (const t of a.tags) bump(groups.tag, t, ok);
    } else {
      const truth = new Set(a.answer);
      const said = new Set(Array.isArray(parsed) ? parsed : []);
      const exact = Array.isArray(parsed) && truth.size === said.size && [...truth].every((p) => said.has(p));
      scene.exact.n++;
      if (exact) scene.exact.k++;
      bump(scene.byDifficulty, a.difficulty, exact);
      for (const p of a.pairs) {
        const s = Array.isArray(parsed) && said.has(p.pair);
        scene.pairs.n++;
        if (Array.isArray(parsed) && s === p.intersects) scene.pairs.k++;
        if (s && p.intersects) scene.tp++;
        else if (s) scene.fp++;
        else if (p.intersects) scene.fn++;
      }
    }
  }
  const f1 = (2 * scene.tp) / (2 * scene.tp + scene.fp + scene.fn || 1);
  return { answered, total: answers.length, unparsed, groups, scene: { ...scene, f1 }, dist };
}

const pct = (t) => (t.n ? `${((100 * t.k) / t.n).toFixed(1)}%` : "-");
const ci = (t) => {
  const [lo, hi] = wilson(t.k, t.n);
  return t.n ? `${Math.max(0, 100 * lo).toFixed(0)}–${Math.min(100, 100 * hi).toFixed(0)}` : "";
};

function report(name, meta, s) {
  const out = [];
  out.push(`## ${name} (dataset ${datasetName}${opt.split === "all" ? "" : `, split ${opt.split}`})`);
  if (meta) out.push(`model: ${meta.model ?? "?"} / provider: ${meta.provider ?? "?"} / prompt: ${meta.prompt_version ?? "?"} / settings: ${JSON.stringify(meta.settings ?? {})}`);
  out.push(`answered ${s.answered}/${s.total}, unparsable ${s.unparsed} (missing and unparsable count as wrong)`);
  out.push("");
  out.push("| group | key | correct | accuracy | 95% CI |");
  out.push("|---|---|---|---|---|");
  for (const [g, map] of Object.entries(s.groups)) {
    for (const k of Object.keys(map).sort()) out.push(`| ${g} | ${k} | ${map[k].k}/${map[k].n} | ${pct(map[k])} | ${ci(map[k])} |`);
  }
  if (s.dist.errors.length) {
    const e = [...s.dist.errors].sort((x, y) => x - y);
    const q = (p) => e[Math.min(e.length - 1, Math.floor(p * e.length))];
    const fmt = (x) => (Number.isFinite(x) ? x.toFixed(4) : "missing");
    const bias = s.dist.signed.length ? s.dist.signed.reduce((x, y) => x + y, 0) / s.dist.signed.length : NaN;
    out.push(`| distance | within 0.01 | ${s.dist.within01.k}/${s.dist.within01.n} | ${pct(s.dist.within01)} | ${ci(s.dist.within01)} |`);
    out.push(`| distance | within 1% (nonzero answers) | ${s.dist.within1pct.k}/${s.dist.within1pct.n} | ${pct(s.dist.within1pct)} | ${ci(s.dist.within1pct)} |`);
    out.push(`| distance | zero answers within ${TOLERANCE} | ${s.dist.zero.k}/${s.dist.zero.n} | ${pct(s.dist.zero)} | ${ci(s.dist.zero)} |`);
    out.push(`| distance | abs error p50 / p90 / max | | ${fmt(q(0.5))} / ${fmt(q(0.9))} / ${fmt(e[e.length - 1])} | |`);
    out.push(`| distance | mean signed error | | ${Number.isFinite(bias) ? bias.toFixed(4) : "-"} | |`);
    return out.join("\n");
  }
  out.push(`| scene | exact set | ${s.scene.exact.k}/${s.scene.exact.n} | ${pct(s.scene.exact)} | ${ci(s.scene.exact)} |`);
  for (const k of Object.keys(s.scene.byDifficulty).sort()) {
    const t = s.scene.byDifficulty[k];
    out.push(`| scene | exact set / ${k} | ${t.k}/${t.n} | ${pct(t)} | ${ci(t)} |`);
  }
  out.push(`| scene | per-pair | ${s.scene.pairs.k}/${s.scene.pairs.n} | ${pct(s.scene.pairs)} | ${ci(s.scene.pairs)} |`);
  out.push(`| scene | intersecting-pair F1 | | ${(100 * s.scene.f1).toFixed(1)}% | |`);
  return out.join("\n");
}

if (positionals.length === 0) {
  console.error("usage: node score.mjs <responses.jsonl>... [--split lite|full|all] [--json]");
  process.exit(2);
}
const results = positionals.map((p) => {
  const rows = readJsonl(p);
  const name = opt.dataset ?? datasetOfRows(rows);
  if (!name) throw new Error(`${p}: no prompt_version; pass --dataset`);
  loadAnswers(name);
  return { file: p, meta: rows[0], score: score(rows) };
});
if (opt.json) {
  console.log(JSON.stringify(results.map((r) => ({ file: r.file, model: r.meta?.model, ...r.score })), null, 2));
} else {
  console.log(results.map((r) => report(basename(r.file), r.meta, r.score)).join("\n\n"));
}
