#!/usr/bin/env node
// Writes reference replies from simple non-reasoning heuristics, so a model's
// score can be read against "what a bounding volume test already gets".
//
//   node baselines.mjs   ->  results/baseline-{bsphere,aabb,always-no}.responses.jsonl

import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

import { boundingRadius, interiorPoint, norm, normalize, sub, support } from "./lib/geometry.mjs";
import { PROMPT_VERSION } from "./lib/prompt.mjs";

const here = dirname(fileURLToPath(import.meta.url));
const problems = readFileSync(join(here, "data", "problems.jsonl"), "utf8")
  .split("\n")
  .filter(Boolean)
  .map((l) => JSON.parse(l));

function sphereOf(s) {
  if (s.type === "torus") return { c: s.center, r: s.major_radius + s.minor_radius };
  if (s.type === "point") return { c: s.position, r: 0 };
  return { c: interiorPoint(s), r: boundingRadius(s) / 1.05 };
}

function boxOf(s) {
  if (s.type === "torus") {
    const n = normalize(s.axis);
    const e = n.map((x) => s.major_radius * Math.sqrt(Math.max(0, 1 - x * x)) + s.minor_radius);
    return { min: s.center.map((c, k) => c - e[k]), max: s.center.map((c, k) => c + e[k]) };
  }
  const axis = (k, sign) => [0, 1, 2].map((i) => (i === k ? sign : 0));
  return {
    min: [0, 1, 2].map((k) => support(s, axis(k, -1))[k]),
    max: [0, 1, 2].map((k) => support(s, axis(k, 1))[k]),
  };
}

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

mkdirSync(join(here, "results"), { recursive: true });
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
  writeFileSync(join(here, "results", `baseline-${name}.responses.jsonl`), rows.join("\n") + "\n");
}
console.log("wrote", Object.keys(heuristics).map((n) => `results/baseline-${n}.responses.jsonl`).join(", "));
