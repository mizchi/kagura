import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdirSync, mkdtempSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { standardMatrixCells } from './ui-matrix-gates.mjs';

test('standardMatrixCells walks only *.standard captures', () => {
  const root = mkdtempSync(join(tmpdir(), 'kagura-matrix-gates-'));
  mkdirSync(join(root, 'flappy_bird', 'title.standard'), { recursive: true });
  mkdirSync(join(root, 'flappy_bird', 'title.portrait'), { recursive: true });
  writeFileSync(join(root, 'flappy_bird', 'title.standard', 'frame.png'), 'png');
  writeFileSync(join(root, 'flappy_bird', 'title.standard', 'snapshot.json'), '{}');
  writeFileSync(join(root, 'flappy_bird', 'title.portrait', 'frame.png'), 'png');
  const cells = standardMatrixCells(root, 'flappy_bird');
  assert.deepEqual(cells.map((cell) => cell.cell), ['title.standard']);
  assert.ok(cells[0].png.endsWith('title.standard/frame.png'));
  assert.ok(cells[0].snapshot.endsWith('title.standard/snapshot.json'));
});
