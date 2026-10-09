#!/usr/bin/env node
// Sums token usage over Claude Code subagent transcripts, one line per file.
//   node harness/usage.mjs <transcript.output>...
import { readFileSync } from "node:fs";
import { basename } from "node:path";

const total = { input: 0, cache_read: 0, cache_write: 0, output: 0 };
for (const file of process.argv.slice(2)) {
  const byId = new Map();
  for (const line of readFileSync(file, "utf8").split("\n")) {
    let j;
    try {
      j = JSON.parse(line);
    } catch {
      continue;
    }
    if (j.type === "assistant" && j.message?.usage) byId.set(j.message.id ?? byId.size, j.message.usage);
  }
  const u = { input: 0, cache_read: 0, cache_write: 0, output: 0 };
  for (const x of byId.values()) {
    u.input += x.input_tokens ?? 0;
    u.cache_read += x.cache_read_input_tokens ?? 0;
    u.cache_write += x.cache_creation_input_tokens ?? 0;
    u.output += x.output_tokens ?? 0;
  }
  for (const k in u) total[k] += u[k];
  console.log(`${basename(file)}\t${JSON.stringify(u)}`);
}
console.log(`total\t${JSON.stringify(total)}`);
