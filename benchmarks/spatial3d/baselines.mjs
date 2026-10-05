#!/usr/bin/env node
// Writes reference replies from simple non-reasoning heuristics, so a model's
// score can be read against "what a bounding volume test already gets".
//
//   node baselines.mjs [--dataset v2]  ->  results/<dataset>/baseline-{bsphere,aabb,always-no}.responses.jsonl

import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { parseArgs } from "node:util";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

import { boundingRadius, bounds, interiorPoint, norm, scale, add, sub } from "./lib/geometry.mjs";
import { datasetSpec } from "./lib/prompt.mjs";

const here = dirname(fileURLToPath(import.meta.url));
const { values: opt } = parseArgs({ options: { dataset: { type: "string", default: "v2" } } });
const PROMPT_VERSION = datasetSpec(opt.dataset).promptVersion;
const resultsDir = join(here, "results", opt.dataset);
const problems = readFileSync(join(here, "data", opt.dataset, "problems.jsonl"), "utf8")
  .split("\n")
  .filter(Boolean)
  .map((l) => JSON.parse(l));

function sphereOf(s) {
  if (s.type === "torus") return { c: s.center, r: s.major_radius + s.minor_radius };
  if (s.type === "point") return { c: s.position, r: 0 };
  if (s.type === "compound" || s.type === "frame") {
    const b = bounds(s);
    return { c: scale(add(b.min, b.max), 0.5), r: norm(sub(b.max, b.min)) / 2 };
  }
  return { c: interiorPoint(s), r: boundingRadius(s) / 1.05 };
}

const boxOf = bounds;

const heuristics = {
  bsphere: (a, b) => {
    const x = sphereOf(a);
    const y = sphereOf(b);
    return norm(sub(x.c, y.c)) < x.r + y.r;
  },
  aabb: (a, b) => {
    const x = boxOf(a);
    const y = boxOf(b);
    return [0, 1, 2].every((k) => x.min[k] < y.max[k] && y.min[k] < x.max[k]);
  },
  "always-no": () => false,
};

mkdirSync(resultsDir, { recursive: true });
for (const [name, test] of Object.entries(heuristics)) {
  const rows = problems.map((p) => {
    let answer;
    if (p.task === "pair") {
      answer = test(p.objects[0], p.objects[1]) ? "YES" : "NO";
    } else {
      const hits = [];
      for (let i = 0; i < p.objects.length; i++) {
        for (let j = i + 1; j < p.objects.length; j++) {
          if (test(p.objects[i], p.objects[j])) hits.push(`${p.objects[i].id}-${p.objects[j].id}`);
        }
      }
      answer = hits.join(", ") || "NONE";
    }
    return JSON.stringify({ id: p.id, model: `baseline-${name}`, provider: "heuristic", prompt_version: PROMPT_VERSION, response: `ANSWER: ${answer}` });
  });
  writeFileSync(join(resultsDir, `baseline-${name}.responses.jsonl`), rows.join("\n") + "\n");
}
console.log("wrote", Object.keys(heuristics).map((n) => join(resultsDir, `baseline-${n}.responses.jsonl`)).join(", "));
