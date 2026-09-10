import { test } from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, readFileSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { createHeadlessEditor } from '../headless/index.mjs';

const rename = { expectedRevision: 0, commands: [{ op: 'node.rename', id: 'hero', name: 'Headless actor' }] };
test('independent editor instances run without a browser and share normal history/context semantics', () => {
  assert.equal(typeof globalThis.document, 'undefined');
  assert.equal(typeof globalThis.window, 'undefined');
  const a = createHeadlessEditor(), b = createHeadlessEditor();
  const before = b.snapshot();
  let calls = 0;
  const unsubscribe = a.subscribe(() => { calls++; });
  assert.equal(a.dispatch(rename).ok, true);
  assert.equal(a.snapshot().document.nodes[1].name, 'Headless actor');
  assert.deepEqual(b.snapshot(), before);
  assert.equal(a.dispatch(rename).error.code, 'conflict');
  assert.equal(calls, 1);
  assert.equal(a.seek(0.03).ok, true);
  assert.equal(a.snapshot().preview.flash, true);
  assert.equal(a.select('block').ok, true);
  assert.equal(a.select('missing').ok, false);
  assert.equal(a.undo(1).ok, true);
  assert.deepEqual(a.snapshot().document, before.document);
  assert.equal(a.snapshot().preview.time, 0);
  assert.equal(a.redo(2).ok, true);
  const snapshot = a.snapshot();
  snapshot.document.nodes[0].name = 'External mutation';
  assert.notEqual(a.snapshot().document.nodes[0].name, 'External mutation');
  unsubscribe();
  const count = calls;
  a.seek(0.05);
  assert.equal(calls, count);
});

test('initial documents validate at revision zero and rejected batches preserve all state', () => {
  const doc = createHeadlessEditor().snapshot().document;
  doc.name = 'Imported';
  const editor = createHeadlessEditor(doc);
  assert.equal(editor.snapshot().revision, 0);
  assert.equal(editor.snapshot().canUndo, false);
  assert.equal(editor.snapshot().document.name, 'Imported');
  assert.throws(() => createHeadlessEditor({ ...doc, version: 99 }));
  editor.seek(0.03);
  const before = editor.snapshot();
  const bad = { ...rename, commands: [...rename.commands, { op: 'node.remove', id: 'missing' }] };
  assert.equal(editor.dispatch(bad).ok, false);
  assert.deepEqual(editor.snapshot(), before);
  assert.equal(editor.undo(0.5).ok, false);
  assert.equal(editor.seek(NaN).ok, false);
});

function cli(input, args = []) {
  return spawnSync(process.execPath, ['headless/cli.mjs', ...args], {
    cwd: new URL('..', import.meta.url), input, encoding: 'utf8', timeout: 10000,
  });
}
const lines = requests => requests.map(r => JSON.stringify(r)).join('\n') + '\n';

test('JSONL CLI edits, seeks, undoes and saves a reusable document', () => {
  const dir = mkdtempSync(join(tmpdir(), 'kagura-headless-'));
  try {
    const output = join(dir, 'scene.json');
    const run = cli(lines([
      { method: 'snapshot' }, { method: 'dispatch', transaction: rename },
      { method: 'seek', time: 0.03 }, { method: 'undo', expectedRevision: 1 },
      { method: 'redo', expectedRevision: 2 },
    ]), ['--output', output]);
    assert.equal(run.status, 0, run.stderr);
    const replies = run.stdout.trim().split('\n').map(JSON.parse);
    assert.equal(replies.length, 5);
    assert.ok(replies.every(r => r.ok));
    assert.equal(replies[2].snapshot.preview.flash, true);
    const saved = JSON.parse(readFileSync(output, 'utf8'));
    assert.equal(saved.nodes[1].name, 'Headless actor');
    const restored = cli(lines([{ method: 'snapshot' }]), ['--document', output]);
    const result = JSON.parse(restored.stdout);
    assert.equal(restored.status, 0, restored.stderr);
    assert.deepEqual(result.snapshot.document, saved);
    assert.equal(result.snapshot.revision, 0);
  } finally { rmSync(dir, { recursive: true }); }
});

test('CLI rejects malformed and unknown requests, continues the session and never saves a failed run', () => {
  const dir = mkdtempSync(join(tmpdir(), 'kagura-headless-'));
  try {
    const output = join(dir, 'scene.json');
    writeFileSync(output, 'keep this');
    const run = cli('{invalid}\n' + lines([
      { method: 'snapshot', typo: true }, { method: 'undo', expectedRevision: 0.5 },
      { method: 'unknown' }, { method: 'snapshot' },
    ]), ['--output', output]);
    assert.equal(run.status, 1);
    const replies = run.stdout.trim().split('\n').map(JSON.parse);
    assert.deepEqual(replies.map(r => r.ok), [false, false, false, false, true]);
    assert.equal(replies.at(-1).snapshot.revision, 0);
    assert.equal(readFileSync(output, 'utf8'), 'keep this');
    assert.notEqual(cli('', ['--unknown']).status, 0);
  } finally { rmSync(dir, { recursive: true }); }
});
