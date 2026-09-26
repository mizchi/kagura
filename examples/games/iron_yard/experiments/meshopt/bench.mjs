// Encode Iron Yard's converted batch geometry with meshoptimizer and report
// payload size, decode time and round-trip error. Report only: nothing here
// is shipped, and the production loader still reads assets/generated/*.json.
import { readFile } from 'node:fs/promises';
import { gzipSync, brotliCompressSync, constants } from 'node:zlib';
import { performance } from 'node:perf_hooks';
import { MeshoptEncoder, MeshoptDecoder } from 'meshoptimizer';
import { convertGLB } from '../../scripts/convert-assets.mjs';

const STRIDE = 8; // position3 normal3 uv2, as emitted by convertGLB
const RUNS = 9;
const json = process.argv.includes('--json');

await MeshoptEncoder.ready;
await MeshoptDecoder.ready;

const gz = bytes => gzipSync(bytes, { level: 9 }).length;
const br = bytes => brotliCompressSync(bytes, { params: { [constants.BROTLI_PARAM_QUALITY]: 11 } }).length;
const sizes = bytes => ({ raw: bytes.length, gzip: gz(bytes), brotli: br(bytes) });
const concat = parts => {
  const out = new Uint8Array(parts.reduce((n, p) => n + p.length, 0));
  let o = 0;
  for (const p of parts) { out.set(p, o); o += p.length; }
  return out;
};
const u8 = view => new Uint8Array(view.buffer, view.byteOffset, view.byteLength);
const median = values => [...values].sort((a, b) => a - b)[values.length >> 1];
function time(fn) {
  const samples = [];
  for (let i = 0; i < RUNS; i++) { const t = performance.now(); fn(); samples.push(performance.now() - t); }
  return median(samples);
}
// Same number formatting as scripts/convert-assets.mjs.
const stringify = value => JSON.stringify(value, (_, v) => typeof v === 'number' ? Number(v.toPrecision(9)) : v);

// Vertex-cache + vertex-fetch order. Also drops unreferenced vertices.
function reorder(batch) {
  const source = Float32Array.from(batch.vertices);
  const indices = Uint32Array.from(batch.indices);
  const [remap, unique] = MeshoptEncoder.reorderMesh(indices, true, false);
  const vertices = new Float32Array(unique * STRIDE);
  for (let i = 0; i < remap.length; i++) {
    if (remap[i] !== 0xffffffff) vertices.set(source.subarray(i * STRIDE, (i + 1) * STRIDE), remap[i] * STRIDE);
  }
  return { source, sourceIndices: Uint32Array.from(batch.indices), vertices, indices, count: unique };
}

function bounds(vertices, count, offset, dims) {
  const min = Array(dims).fill(Infinity), max = Array(dims).fill(-Infinity);
  for (let i = 0; i < count; i++) for (let d = 0; d < dims; d++) {
    const v = vertices[i * STRIDE + offset + d];
    if (v < min[d]) min[d] = v;
    if (v > max[d]) max[d] = v;
  }
  return { min, scale: max.map((m, d) => (m - min[d]) || 1) };
}

// Lossless: the float32 vertex stream as-is (32 bytes/vertex).
function encodeLossless(r, level, version) {
  return {
    vertex: MeshoptEncoder.encodeVertexBufferLevel(u8(r.vertices), r.count, STRIDE * 4, level, version),
    index: MeshoptEncoder.encodeIndexBuffer(u8(r.indices), r.indices.length, 4),
  };
}
function decodeLossless(r, e) {
  const vertices = new Float32Array(r.count * STRIDE);
  const indices = new Uint32Array(r.indices.length);
  MeshoptDecoder.decodeVertexBuffer(u8(vertices), r.count, STRIDE * 4, e.vertex);
  MeshoptDecoder.decodeIndexBuffer(u8(indices), indices.length, 4, e.index);
  return { vertices, indices };
}

// Quantized: position uint16 over the batch AABB (8 bytes incl. padding),
// normal octahedral (4 bytes at 8 bits, 8 at 16), uv uint16 over its range.
// Same attribute split as gltfpack; the dequantization parameters are what a
// glTF file would carry in accessor min/max or KHR_mesh_quantization.
function encodeQuantized(r, normalBits) {
  const n = r.count, v = r.vertices;
  const pos = bounds(v, n, 0, 3), uv = bounds(v, n, 6, 2);
  const p16 = new Uint16Array(n * 4), t16 = new Uint16Array(n * 2), nf = new Float32Array(n * 4);
  for (let i = 0; i < n; i++) {
    for (let d = 0; d < 3; d++) p16[i * 4 + d] = Math.round((v[i * STRIDE + d] - pos.min[d]) / pos.scale[d] * 65535);
    for (let d = 0; d < 2; d++) t16[i * 2 + d] = Math.round((v[i * STRIDE + 6 + d] - uv.min[d]) / uv.scale[d] * 65535);
    for (let d = 0; d < 3; d++) nf[i * 4 + d] = v[i * STRIDE + 3 + d];
  }
  const normalStride = normalBits > 8 ? 8 : 4;
  const oct = MeshoptEncoder.encodeFilterOct(nf, n, normalStride, normalBits);
  return {
    pos, uv, normalStride,
    // The same quantized streams without the meshopt codec, to separate what
    // quantization buys from what the codec buys.
    unencoded: [u8(p16), oct, u8(t16), u8(r.indices)],
    position: MeshoptEncoder.encodeVertexBuffer(u8(p16), n, 8),
    normal: MeshoptEncoder.encodeVertexBuffer(oct, n, normalStride),
    texcoord: MeshoptEncoder.encodeVertexBuffer(u8(t16), n, 4),
    index: MeshoptEncoder.encodeIndexBuffer(u8(r.indices), r.indices.length, 4),
  };
}
function decodeQuantized(r, e) {
  const n = r.count;
  const p16 = new Uint16Array(n * 4), t16 = new Uint16Array(n * 2);
  const oct = e.normalStride === 8 ? new Int16Array(n * 4) : new Int8Array(n * 4);
  const indices = new Uint32Array(r.indices.length);
  MeshoptDecoder.decodeVertexBuffer(u8(p16), n, 8, e.position);
  MeshoptDecoder.decodeVertexBuffer(u8(oct), n, e.normalStride, e.normal, 'OCTAHEDRAL');
  MeshoptDecoder.decodeVertexBuffer(u8(t16), n, 4, e.texcoord);
  MeshoptDecoder.decodeIndexBuffer(u8(indices), indices.length, 4, e.index);
  // Expand to the float layout convertGLB produces, so the timing includes
  // everything a loader would do before handing arrays to the renderer.
  const vertices = new Float32Array(n * STRIDE);
  const ns = e.normalStride === 8 ? 32767 : 127;
  for (let i = 0; i < n; i++) {
    for (let d = 0; d < 3; d++) vertices[i * STRIDE + d] = e.pos.min[d] + p16[i * 4 + d] / 65535 * e.pos.scale[d];
    for (let d = 0; d < 3; d++) vertices[i * STRIDE + 3 + d] = oct[i * 4 + d] / ns;
    for (let d = 0; d < 2; d++) vertices[i * STRIDE + 6 + d] = e.uv.min[d] + t16[i * 2 + d] / 65535 * e.uv.scale[d];
  }
  return { vertices, indices };
}

// Compare the decoded mesh against the reordered float32 source. The index
// codec may rotate the corners of a triangle (winding is preserved), so each
// decoded triangle must be a rotation of the source triangle at the same
// position; attributes are then compared corner by corner.
function compare(r, decoded) {
  let bitExact = true, maxPos = 0, maxNormalDeg = 0, maxUv = 0;
  const idx = r.indices, out = decoded.indices;
  if (out.length !== idx.length) throw Error('index count changed');
  const diag = Math.hypot(...bounds(r.source, r.source.length / STRIDE, 0, 3).scale);
  for (let t = 0; t < idx.length; t += 3) {
    const shift = [0, 1, 2].find(s => [0, 1, 2].every(k => out[t + k] === idx[t + (k + s) % 3]));
    if (shift === undefined) throw Error(`triangle ${t / 3} did not round-trip`);
    for (let k = 0; k < 3; k++) {
      const a = r.vertices.subarray(out[t + k] * STRIDE), b = decoded.vertices.subarray(out[t + k] * STRIDE);
      for (let d = 0; d < STRIDE; d++) if (!Object.is(a[d], b[d])) bitExact = false;
      maxPos = Math.max(maxPos, Math.hypot(a[0] - b[0], a[1] - b[1], a[2] - b[2]) / diag);
      const dot = (a[3] * b[3] + a[4] * b[4] + a[5] * b[5]) / (Math.hypot(a[3], a[4], a[5]) * Math.hypot(b[3], b[4], b[5]) || 1);
      maxNormalDeg = Math.max(maxNormalDeg, Math.acos(Math.min(1, Math.max(-1, dot))) * 180 / Math.PI);
      maxUv = Math.max(maxUv, Math.abs(a[6] - b[6]), Math.abs(a[7] - b[7]));
    }
  }
  return { bitExact, maxPos, maxNormalDeg, maxUv };
}

// reorderMesh changes vertex and triangle order only: the set of triangles
// (as vertex values, up to corner rotation) must match the float32 source.
function sameTriangles(r) {
  const key = (v, i) => Array.from(v.subarray(i * STRIDE, (i + 1) * STRIDE)).join(',');
  const list = (v, idx) => {
    const out = [];
    for (let t = 0; t < idx.length; t += 3) {
      const c = [key(v, idx[t]), key(v, idx[t + 1]), key(v, idx[t + 2])];
      const s = c.indexOf([...c].sort()[0]);
      out.push([...c.slice(s), ...c.slice(0, s)].join('|'));
    }
    return out.sort();
  };
  const before = list(r.source, r.sourceIndices), after = list(r.vertices, r.indices);
  return before.length === after.length && before.every((t, i) => t === after[i]);
}

const report = [];
for (const name of ['strix', 'bastion']) {
  const asset = convertGLB(await readFile(new URL(`../../assets/source/${name}.glb`, import.meta.url)));
  const full = new TextEncoder().encode(stringify(asset));
  const meta = new TextEncoder().encode(stringify({ ...asset, batches: asset.batches.map(({ vertices, indices, ...rest }) => rest) }));
  const geometryJson = new TextEncoder().encode(stringify(asset.batches.map(b => [b.vertices, b.indices])));
  const reordered = asset.batches.map(reorder);
  if (!reordered.every(sameTriangles)) throw Error(`${name}: reorderMesh changed the triangle set`);
  const vertexCount = asset.batches.reduce((n, b) => n + b.vertices.length / STRIDE, 0);
  const uniqueCount = reordered.reduce((n, r) => n + r.count, 0);
  const indexCount = asset.batches.reduce((n, b) => n + b.indices.length, 0);
  const rawBinary = concat(asset.batches.flatMap(b => [u8(Float32Array.from(b.vertices)), u8(Uint32Array.from(b.indices))]));

  const variants = {
    'meshopt lossless (v0)': [r => encodeLossless(r, 2, 0), decodeLossless],
    'meshopt lossless (v1, level 3)': [r => encodeLossless(r, 3, 1), decodeLossless],
    'meshopt quantized (normal 8bit)': [r => encodeQuantized(r, 8), decodeQuantized],
    'meshopt quantized (normal 12bit)': [r => encodeQuantized(r, 12), decodeQuantized],
  };
  const rows = [
    { format: 'current JSON (whole asset)', ...sizes(full) },
    { format: 'JSON, non-geometry part', ...sizes(meta) },
    { format: 'JSON, geometry only', ...sizes(geometryJson) },
    { format: 'float32 + uint32 binary', ...sizes(rawBinary) },
  ];
  const quantized = reordered.map(r => encodeQuantized(r, 8));
  rows.push({ format: 'quantized binary, no meshopt codec', ...sizes(concat(quantized.flatMap(e => e.unencoded))) });
  for (const [format, [encode, decode]] of Object.entries(variants)) {
    const encoded = reordered.map(encode);
    const streams = concat(encoded.flatMap(e => [e.vertex, e.position, e.normal, e.texcoord, e.index].filter(Boolean)));
    const decodeMs = time(() => reordered.forEach((r, i) => decode(r, encoded[i])));
    const checks = reordered.map((r, i) => compare(r, decode(r, encoded[i])));
    rows.push({
      format, ...sizes(streams), decodeMs,
      bitExact: checks.every(c => c.bitExact),
      maxPosition: Math.max(...checks.map(c => c.maxPos)),
      maxNormalDeg: Math.max(...checks.map(c => c.maxNormalDeg)),
      maxUv: Math.max(...checks.map(c => c.maxUv)),
    });
  }
  const parseMs = time(() => JSON.parse(new TextDecoder().decode(geometryJson)));
  report.push({ name, batches: asset.batches.length, vertexCount, uniqueCount, indexCount, geometryJsonParseMs: parseMs, rows });
}

if (json) {
  console.log(JSON.stringify(report, null, 2));
} else {
  const kb = n => (n / 1024).toFixed(1).padStart(8);
  for (const a of report) {
    console.log(`\n${a.name}: ${a.batches} batches, ${a.vertexCount} vertices (${a.uniqueCount} referenced), ${a.indexCount} indices; geometry JSON.parse ${a.geometryJsonParseMs.toFixed(2)} ms`);
    console.log('format'.padEnd(34) + '     raw KiB    gzip KiB  brotli KiB  decode ms  exact  maxPos/diag  normal°   uv');
    for (const r of a.rows) {
      const extra = r.decodeMs === undefined ? '' :
        `  ${r.decodeMs.toFixed(2).padStart(9)}  ${String(r.bitExact).padEnd(5)}  ${r.maxPosition.toExponential(1).padStart(11)}  ${r.maxNormalDeg.toFixed(2).padStart(7)}  ${r.maxUv.toExponential(1)}`;
      console.log(r.format.padEnd(34) + kb(r.raw) + '    ' + kb(r.gzip) + '    ' + kb(r.brotli) + extra);
    }
  }
}
