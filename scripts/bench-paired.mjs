#!/usr/bin/env node
// Keep the workspace compilation regime used by bench-gate. Filtering is done
// after measurement; package-local whitebox timings are not interchangeable.
import { spawnSync } from 'node:child_process';
import { mkdirSync, writeFileSync, realpathSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';
import { cpus, platform, arch } from 'node:os';
import { parseBenchOutput, comparePairedRuns } from './bench-gate-utils.mjs';

const { values } = parseArgs({ options: {
  'baseline-dir': { type: 'string' },
  runs: { type: 'string', default: '3' },
  target: { type: 'string', default: 'js' },
  prefix: { type: 'string', default: 'landscape/' },
  'out-dir': { type: 'string', default: `output/bench-paired-${Date.now()}` },
  help: { type: 'boolean' },
} });
if (values.help) {
  console.log('Usage: just bench-paired --baseline-dir /path/to/before [--runs 3] [--prefix landscape/] [--out-dir output/results]');
  process.exit(0);
}
const current = realpathSync(resolve(dirname(fileURLToPath(import.meta.url)), '..'));
if (!values['baseline-dir']) throw new Error('--baseline-dir is required (include identical benchmark fixtures in both trees)');
const baseline = realpathSync(values['baseline-dir']);
if (baseline === current) throw new Error('Baseline must be a separate checkout');
const runs = Number(values.runs);
if (!Number.isInteger(runs) || runs < 3) throw new Error('--runs must be an integer >= 3');
if (!['js', 'native', 'wasm', 'wasm-gc'].includes(values.target)) throw new Error('Invalid target');
const out = resolve(values['out-dir']);
mkdirSync(out, { recursive: true });
const command = ['bench', '--target', values.target];
const samples = { before: [], after: [] };
const metadata = {
  command: ['moon', ...command], baseline, current, runs, prefix: values.prefix,
  platform: platform(), arch: arch(), cpu: cpus()[0]?.model, node: process.version,
  moon: spawnSync('moon', ['version'], { encoding: 'utf8' }).stdout?.trim(),
};
for (let i = 1; i <= runs; i++) {
  for (const [side, cwd] of [['before', baseline], ['after', current]]) {
    console.log(`[${i}/${runs}] ${side}: moon ${command.join(' ')}`);
    const result = spawnSync('moon', command, { cwd, encoding: 'utf8', maxBuffer: 32 * 1024 * 1024 });
    const log = `${result.stdout ?? ''}\n${result.stderr ?? ''}`;
    writeFileSync(resolve(out, `${side}-${i}.log`), log);
    if (result.error || result.status !== 0) throw new Error(`${side} benchmark failed: ${result.error ?? result.status}; see ${out}`);
    const parsed = parseBenchOutput(log).filter(({ name }) => name.startsWith(values.prefix));
    if (!parsed.length) throw new Error(`No benchmarks matched ${values.prefix}`);
    samples[side].push(parsed);
    writeFileSync(resolve(out, 'samples.json'), JSON.stringify({ ...metadata, samples }, null, 2) + '\n');
  }
}
const comparison = comparePairedRuns(samples.before, samples.after);
writeFileSync(resolve(out, 'summary.json'), JSON.stringify({ ...metadata, comparison }, null, 2) + '\n');
for (const { name, before, after, ratio, separation } of comparison) {
  const band = (x) => `${x.medianUs.toFixed(2)} [${x.minUs.toFixed(2)}, ${x.maxUs.toFixed(2)}]`;
  console.log(`${name}: ${band(before)} -> ${band(after)} us; ${(ratio * 100).toFixed(1)}%, ${separation}`);
}
console.log(`Saved logs and samples: ${out}`);
