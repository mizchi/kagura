#!/usr/bin/env node
import { readFile, writeFile, rename, rm } from 'node:fs/promises';
import { createInterface } from 'node:readline';
import { parseArgs } from 'node:util';
import { resolve, dirname, basename, join } from 'node:path';
import { randomUUID } from 'node:crypto';
import { createHeadlessEditor } from './index.mjs';

try {
  const { values } = parseArgs({ options: { document: { type: 'string' }, output: { type: 'string' }, help: { type: 'boolean', short: 'h' } } });
  if (values.help) {
    console.log(`Kagura Studio headless editor (Node.js 24+)
Usage: node headless/cli.mjs [--document scene.json] [--output scene.json] < requests.jsonl

One JSON request per line; one JSON reply per line. No browser, GPU or server needed.
Methods: snapshot, dispatch (transaction), undo/redo (expectedRevision), select (id), seek (time), layout (value).
Example: {"method":"dispatch","transaction":{"expectedRevision":0,"commands":[{"op":"node.rename","id":"hero","name":"Player"}]}}
Initial documents start at revision 0. Undo history lasts for this process.
Errors do not end the input stream; any failed request causes exit 1 and suppresses --output.
--output atomically writes the final scene document at EOF, only if every request succeeded.`);
  } else {
    const document = values.document ? JSON.parse(await readFile(values.document, 'utf8')) : undefined;
    const editor = createHeadlessEditor(document);
    let failed = false;
    const input = createInterface({ input: process.stdin, crlfDelay: Infinity });
    for await (const line of input) {
      if (!line.trim()) continue;
      let reply;
      try {
        if (Buffer.byteLength(line) > 4 * 1024 * 1024) throw new Error('Request exceeds 4 MiB');
        reply = editor.request(JSON.parse(line));
      } catch (error) { reply = { ok: false, error: { code: 'invalid', message: error.message } }; }
      if (!reply.ok) failed = true;
      if (!process.stdout.write(JSON.stringify(reply) + '\n')) await new Promise(resolve => process.stdout.once('drain', resolve));
    }
    if (values.output && !failed) {
      const output = resolve(values.output);
      const temporary = join(dirname(output), `.${basename(output)}.${randomUUID()}.tmp`);
      try {
        await writeFile(temporary, JSON.stringify(editor.snapshot().document, null, 2) + '\n', { flag: 'wx' });
        await rename(temporary, output);
      } finally { await rm(temporary, { force: true }); }
    }
    if (failed) process.exitCode = 1;
  }
} catch (error) {
  console.error('kagura-studio: ' + (error.message ?? String(error)));
  process.exitCode = 1;
}
