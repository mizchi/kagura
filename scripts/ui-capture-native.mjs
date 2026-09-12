#!/usr/bin/env node
import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { basename, join, resolve } from 'node:path';
import { tmpdir } from 'node:os';
import { findExampleDir, EXAMPLE_ROOT } from './example-dirs.mjs';
import { parseModuleName } from './render-frame-utils.mjs';
import { buildCaptureConfig } from './stage-capture-config.mjs';
import { createHeadlessRequest } from '../assets/web/kagura-headless-frame.js';
import { matrixCells, validateMatrixFrame } from './ui-matrix-utils.mjs';

export function nativeCaptureRequest(cell) {
  // Use the same bounds and input validation as the matrix, before spawning a child.
  const valid = matrixCells({ version: 1, states: { capture: cell }, viewports: [
    { name: 'capture', width: cell.width, height: cell.height },
  ] })[0];
  const request = createHeadlessRequest({ ...valid, inputs: valid.inputs });
  return { width: valid.width, height: valid.height, frames: valid.frames, inputs: request.inputs, ...(request.initial_state === undefined ? {} : { initial_state: request.initial_state }) };
}

export function parseNativeCapture(png, summary, context) {
  const meta = JSON.parse(summary);
  if (!['native-cpu', 'native-gpu'].includes(meta.backend) || meta.skipped_commands !== 0 ||
    !Number.isInteger(meta.frames) || meta.frames < 1 ||
    !Number.isInteger(meta.drawn_triangles) || meta.drawn_triangles < 0 ||
    !Number.isInteger(meta.draw_commands) || meta.draw_commands < 0) throw Error('Invalid or incomplete native capture');
  if (png.length < 24 || !png.subarray(0, 8).equals(Buffer.from([137,80,78,71,13,10,26,10])) ||
    png.toString('ascii', 12, 16) !== 'IHDR' || png.readUInt32BE(16) !== meta.width || png.readUInt32BE(20) !== meta.height) {
    throw Error('Native PNG dimensions do not match capture metadata');
  }
  const snapshot = JSON.parse(context);
  if (!snapshot?.screen || !Array.isArray(snapshot.nodes)) throw Error('Native capture requires a UI snapshot');
  const frame = { png, width: meta.width, height: meta.height, frames: meta.frames,
    skippedCommands: meta.skipped_commands, drawnTriangles: meta.drawn_triangles, drawCommands: meta.draw_commands,
    uiSnapshotJson: context, uiSnapshot: snapshot, backend: meta.backend };
  frame.initialState = meta.initial_state ?? null;
  validateMatrixFrame({ ...meta, initialState: frame.initialState }, frame);
  return frame;
}

export function nativeGpuBinaryPath(exampleDir, moduleName) {
  return join(exampleDir, '_build/native/debug/build', moduleName, 'native', 'native.exe');
}

export function prepareNativeCapture(example, { build = true, backend = 'cpu' } = {}) {
  const exampleDir = findExampleDir(example, [EXAMPLE_ROOT.examples]);
  if (!exampleDir) throw Error(`Example not found: ${example}`);
  const manifest = join(exampleDir, existsSync(join(exampleDir, 'moon.mod')) ? 'moon.mod' : 'moon.mod.json');
  const moduleName = parseModuleName(readFileSync(manifest, 'utf8'));
  if (build) {
    execFileSync('moon', ['build', '.', '--target', 'native', '--debug'], { cwd: exampleDir, stdio: 'inherit' });
    if (backend === 'gpu' && existsSync(join(exampleDir, 'native/moon.pkg'))) {
      execFileSync('moon', ['build', 'native', '--target', 'native', '--debug'], { cwd: exampleDir, stdio: 'inherit' });
    }
  }
  const rootBinary = join(exampleDir, '_build/native/debug/build', moduleName, `${basename(moduleName)}.exe`);
  const gpuBinary = nativeGpuBinaryPath(exampleDir, moduleName);
  const binaryPath = backend === 'gpu' && existsSync(gpuBinary) ? gpuBinary : rootBinary;
  if (!existsSync(binaryPath)) throw Error(`Native executable missing: ${binaryPath}`);
  return { exampleDir, binaryPath };
}

export function renderNativeCapture({ exampleDir, binaryPath }, cell, { timeout = 30000, backend = 'cpu' } = {}) {
  const request = nativeCaptureRequest(cell);
  const staging = mkdtempSync(join(tmpdir(), 'kagura-ui-capture-'));
  try {
    const requestPath = join(staging, 'request.json');
    const configPath = join(staging, 'capture.txt');
    writeFileSync(requestPath, JSON.stringify(request));
    writeFileSync(configPath, buildCaptureConfig({ outDir: staging, name: 'frame', backend }) + `request_path=${requestPath}\n`);
    // No shared file is staged in the game directory. Existing interactive/config state survives.
    try {
      execFileSync(binaryPath, [], { cwd: exampleDir, env: { ...process.env, KAGURA_CAPTURE_CONFIG: configPath }, timeout, stdio: ['ignore', 'pipe', 'pipe'] });
    } catch (error) {
      throw Error(`Native capture failed: ${error.stdout?.toString().trim() || error.message}`);
    }
    const frame = parseNativeCapture(readFileSync(join(staging, 'frame.png')),
      readFileSync(join(staging, 'frame.summary.txt'), 'utf8'), readFileSync(join(staging, 'frame.context.json'), 'utf8'));
    validateMatrixFrame(cell, frame);
    return frame;
  } finally { rmSync(staging, { recursive: true, force: true }); }
}

async function main(args) {
  const [example, state = 'idle', viewport = 'standard', ...extra] = args;
  if (!example || example === '--help') {
    console.log('Usage: just ui-capture <example> [state] [viewport] ["--backend cpu|gpu"]\nNative capture of an editor/verification.json matrix cell. cpu is the portable 2D rasterizer; gpu drives the real wgpu pipeline.');
    return;
  }
  let backend = 'cpu';
  for (let i = 0; i < extra.length; i++) {
    if (extra[i] === '--backend' && extra[i + 1]) backend = extra[++i];
    else throw Error(`Unknown or incomplete option: ${extra[i]}`);
  }
  const prepared = prepareNativeCapture(example, { backend });
  const cells = matrixCells(JSON.parse(readFileSync(join(prepared.exampleDir, 'editor/verification.json'), 'utf8')));
  const cell = cells.find(c => c.name === `${state}.${viewport}`);
  if (!cell) throw Error(`Unknown capture cell ${state}.${viewport}`);
  const frame = renderNativeCapture(prepared, cell, { backend });
  const out = resolve('output/ui-capture', example, cell.name);
  mkdirSync(out, { recursive: true });
  writeFileSync(join(out, 'frame.png'), frame.png);
  writeFileSync(join(out, 'snapshot.json'), frame.uiSnapshotJson);
  console.log(`${example} ${cell.name}: ${frame.width}x${frame.height}, ${frame.frames} ticks (${frame.backend})\n${out}`);
}
if (process.argv[1] === new URL(import.meta.url).pathname) main(process.argv.slice(2)).catch(error => {
  console.error(error.message); process.exitCode = 1;
});
