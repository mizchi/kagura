#!/usr/bin/env node

/**
 * Follow-up gates over the JS matrix output: theme tokens and i18n stress
 * on every example's standard cells.
 *
 * Scene-label snapshots publish rect = measured text, so German inflation
 * always overflows. Those examples run i18n as advisory; ui_demo still gates.
 */

import { execFileSync } from 'node:child_process';
import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { UI_MATRIX_EXAMPLES, matrixThemePath } from './ui-matrix-manifest.mjs';
import { analyzeTheme, formatThemeReport } from './ui-theme-utils.mjs';
import { analyzeI18nStress, formatI18nReport } from './ui-i18n-utils.mjs';

const REPO_ROOT = resolve(import.meta.dirname, '..');
const DEFAULT_OUT = resolve(REPO_ROOT, 'output/ui-matrix');
const I18N_GATING = new Set(['ui_demo']);

export function standardMatrixCells(outRoot, example) {
  const dir = resolve(outRoot, example);
  if (!existsSync(dir)) return [];
  return readdirSync(dir, { withFileTypes: true })
    .filter((entry) => entry.isDirectory() && entry.name.endsWith('.standard'))
    .map((entry) => ({
      cell: entry.name,
      png: resolve(dir, entry.name, 'frame.png'),
      snapshot: resolve(dir, entry.name, 'snapshot.json'),
    }))
    .filter((cell) => existsSync(cell.png))
    .sort((a, b) => a.cell.localeCompare(b.cell));
}

function extractPalette(image) {
  const stdout = execFileSync(
    'pnpm',
    ['exec', 'vlmkit', 'check', 'palette', image, '--json', '--top', '16'],
    { cwd: REPO_ROOT, encoding: 'utf8' },
  );
  const report = JSON.parse(stdout);
  if (!Array.isArray(report.palette)) throw new Error('vlmkit palette report has no palette');
  return report.palette;
}

export function runThemeMatrix({ outRoot = DEFAULT_OUT, examples = UI_MATRIX_EXAMPLES } = {}) {
  const results = [];
  for (const example of examples) {
    const themePath = matrixThemePath(example);
    const theme = JSON.parse(readFileSync(themePath, 'utf8'));
    for (const cell of standardMatrixCells(outRoot, example)) {
      const result = analyzeTheme(extractPalette(cell.png), theme);
      results.push({ example, cell: cell.cell, kind: 'theme', ok: result.ok, report: formatThemeReport(result, { source: cell.png }) });
    }
  }
  return { ok: results.every((entry) => entry.ok), results };
}

export function runI18nMatrix({ outRoot = DEFAULT_OUT, examples = UI_MATRIX_EXAMPLES } = {}) {
  const results = [];
  for (const example of examples) {
    const advisory = !I18N_GATING.has(example);
    for (const cell of standardMatrixCells(outRoot, example)) {
      if (!existsSync(cell.snapshot)) {
        results.push({ example, cell: cell.cell, kind: 'i18n', ok: false, advisory, report: `missing snapshot ${cell.snapshot}` });
        continue;
      }
      const result = analyzeI18nStress(readFileSync(cell.snapshot, 'utf8'));
      results.push({
        example,
        cell: cell.cell,
        kind: 'i18n',
        ok: result.ok,
        advisory,
        report: formatI18nReport(result, { source: cell.snapshot }),
      });
    }
  }
  const gated = results.filter((entry) => !entry.advisory);
  return { ok: gated.every((entry) => entry.ok), results };
}

function printResults(batch) {
  for (const entry of batch.results) {
    const tag = entry.ok ? 'CLEAN' : entry.advisory ? 'ADVISORY' : 'DEFECTS';
    process.stdout.write(`${entry.kind} ${entry.example} ${entry.cell}: ${tag}\n`);
    process.stdout.write(`${entry.report}\n`);
  }
}

function usage() {
  return [
    'Usage: node scripts/ui-matrix-gates.mjs --theme|--i18n|--all [output/ui-matrix]',
    '',
    'Runs per-example theme.json and i18n stress on *.standard matrix cells.',
    'i18n is gating for ui_demo and advisory for scene games (zero-slack label rects).',
  ].join('\n');
}

function main(argv) {
  const flags = new Set();
  let outRoot = DEFAULT_OUT;
  for (const arg of argv) {
    if (arg === '-h' || arg === '--help') {
      process.stdout.write(`${usage()}\n`);
      return 0;
    }
    if (arg === '--theme' || arg === '--i18n' || arg === '--all') flags.add(arg);
    else if (arg.startsWith('--')) throw new Error(`unknown option: ${arg}`);
    else outRoot = resolve(arg);
  }
  if (flags.size === 0) throw new Error(`missing --theme, --i18n, or --all\n\n${usage()}`);
  const runTheme = flags.has('--theme') || flags.has('--all');
  const runI18n = flags.has('--i18n') || flags.has('--all');
  let ok = true;
  if (runTheme) {
    const theme = runThemeMatrix({ outRoot });
    printResults(theme);
    if (!theme.ok) ok = false;
  }
  if (runI18n) {
    const i18n = runI18nMatrix({ outRoot });
    printResults(i18n);
    if (!i18n.ok) ok = false;
  }
  return ok ? 0 : 1;
}

if (process.argv[1] === new URL(import.meta.url).pathname) {
  try {
    process.exitCode = main(process.argv.slice(2));
  } catch (error) {
    process.stderr.write(`ui-matrix-gates: ${error.message}\n`);
    process.exitCode = 2;
  }
}
