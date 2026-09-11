#!/usr/bin/env node
// Does SIMD -- and specifically relaxed SIMD -- help the 3D contact solver?
//
// Methodology follows `examples/games/iron_yard/experiments/simd/`: a leaf kernel
// in imported-memory Wasm, validated against a JS oracle before it is timed,
// with the opcodes checked so a "SIMD" variant that quietly compiled to scalar
// cannot pass. Nothing here touches the shipped engine.
//
// Requires `wabt` (npm). It is not a repository dependency:
//   npm install --no-save wabt
// or point WABT_PATH at an installed copy.
import { createRequire } from "node:module";
import { mkdir, writeFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import process from "node:process";

import { layout, scalarWat, simdRelaxedWat, simdStrictWat } from "./kernels.mjs";

const out = fileURLToPath(new URL("../../../../test-results/physics3d-simd/", import.meta.url));
await mkdir(out, { recursive: true });

const require = createRequire(import.meta.url);
let wabtInit;
for (const id of [process.env.WABT_PATH, "wabt"].filter(Boolean)) {
  try { wabtInit = require(id); break; } catch { /* try the next */ }
}
if (!wabtInit) {
  console.error("wabt not found. Install it with `npm install --no-save wabt`,");
  console.error("or set WABT_PATH to an installed copy.");
  process.exit(2);
}
const wabt = await wabtInit();

const MAX_CONSTRAINTS = 2048;
// Each constraint owns two bodies in the fixture below, so the body arrays have
// to be sized from the constraint count -- getting this wrong silently ran the
// body writes off the end of VX and into VY, which showed up as the scalar
// control disagreeing with its own oracle.
const MAX_BODIES = 2 * MAX_CONSTRAINTS + 2;
const L = layout(MAX_BODIES, MAX_CONSTRAINTS);

// --- build and verify the three modules -------------------------------------
// `f64x2.relaxed_madd` is 0xFD with immediate 0x107, LEB128-encoded as 87 02.
const relaxedMaddOpcode = [0xfd, 0x87, 0x02];
const sources = {
  scalar: scalarWat(L),
  simd: simdStrictWat(L),
  relaxed: simdRelaxedWat(L),
};
const modules = {};
for (const [name, wat] of Object.entries(sources)) {
  await writeFile(`${out}${name}.wat`, wat);
  const parsed = wabt.parseWat(`${name}.wat`, wat, { simd: true, relaxed_simd: true });
  parsed.validate();
  const bytes = new Uint8Array(parsed.toBinary({}).buffer);
  await writeFile(`${out}${name}.wasm`, bytes);
  const hasV128 = wat.includes("f64x2");
  const hasRelaxed = [...bytes].some((_, i) =>
    relaxedMaddOpcode.every((b, k) => bytes[i + k] === b));
  // A variant that silently lost its vector or relaxed opcodes would still run
  // and would still produce a number, so refuse to report one.
  if (name === "scalar" && hasV128) throw Error("scalar control contains SIMD");
  if (name !== "scalar" && !hasV128) throw Error(`${name} lost its SIMD`);
  if (name === "relaxed" && !hasRelaxed) throw Error("relaxed variant has no relaxed_madd opcode");
  if (name === "simd" && hasRelaxed) throw Error("strict SIMD control contains relaxed_madd");
  modules[name] = { bytes, hasRelaxed };
}
console.log("built:", Object.entries(modules)
  .map(([n, m]) => `${n} ${m.bytes.length}B${m.hasRelaxed ? " (relaxed_madd present)" : ""}`)
  .join(", "));

// --- deterministic fixture ---------------------------------------------------
// Constraints are laid out so that each adjacent PAIR touches four distinct
// bodies. Without that the f64x2 variants are not merely slower or faster, they
// are wrong: lane 1 would read velocity that lane 0 has already written in the
// scalar ordering. Producing this ordering from a real contact set is a graph
// colouring problem, which is the actual prerequisite this experiment is here to
// price out.
function fixture(constraintCount) {
  let seed = 0x5eed3d01;
  const rnd = () => {
    seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0;
    return seed / 4294967296;
  };
  const bodyCount = 2 * constraintCount + 2;
  const data = {
    vx: new Float64Array(bodyCount), vy: new Float64Array(bodyCount),
    vz: new Float64Array(bodyCount), im: new Float64Array(bodyCount),
    nx: new Float64Array(constraintCount), ny: new Float64Array(constraintCount),
    nz: new Float64Array(constraintCount), nm: new Float64Array(constraintCount),
    rb: new Float64Array(constraintCount), ga: new Float64Array(constraintCount),
    acc: new Float64Array(constraintCount),
    ia: new Int32Array(constraintCount), ib: new Int32Array(constraintCount),
    bodyCount, constraintCount,
  };
  for (let b = 0; b < bodyCount; b++) {
    data.vx[b] = rnd() * 2 - 1;
    data.vy[b] = rnd() * 2 - 1;
    data.vz[b] = rnd() * 2 - 1;
    data.im[b] = b % 7 === 0 ? 0 : 1 / (0.5 + rnd()); // some static bodies
  }
  for (let i = 0; i < constraintCount; i++) {
    // Constraint i owns bodies 2i and 2i+1, so any two adjacent constraints touch
    // four distinct bodies and the two f64x2 lanes never race.
    data.ia[i] = 2 * i;
    data.ib[i] = 2 * i + 1;
    let x = rnd() * 2 - 1, y = rnd() * 2 - 1, z = rnd() * 2 - 1;
    const len = Math.hypot(x, y, z) || 1;
    data.nx[i] = x / len; data.ny[i] = y / len; data.nz[i] = z / len;
    data.nm[i] = 1 / (0.5 + rnd());
    data.rb[i] = (rnd() - 0.5) * 0.2;
    data.ga[i] = rnd() * 0.05;
    data.acc[i] = -rnd() * 0.5;
  }
  return data;
}

// The oracle is the shipped scalar arithmetic, in the shipped grouping.
function oracle(d, iters) {
  const { vx, vy, vz, im, nx, ny, nz, nm, rb, ga, acc, ia, ib } = d;
  for (let it = 0; it < iters; it++) {
    for (let i = 0; i < d.constraintCount; i++) {
      const a = ia[i], b = ib[i];
      const vn = (vx[a] - vx[b]) * nx[i] + (vy[a] - vy[b]) * ny[i] +
        (vz[a] - vz[b]) * nz[i];
      let na = acc[i] + -(vn + rb[i] + ga[i] * acc[i]) * nm[i];
      if (na > 0) na = 0;
      const dj = na - acc[i];
      acc[i] = na;
      const ima = im[a], imb = im[b];
      vx[a] += nx[i] * dj * ima; vy[a] += ny[i] * dj * ima; vz[a] += nz[i] * dj * ima;
      vx[b] -= nx[i] * dj * imb; vy[b] -= ny[i] * dj * imb; vz[b] -= nz[i] * dj * imb;
    }
  }
}

function loadInto(memory, d) {
  const f64 = (off, src) => new Float64Array(memory.buffer, off, src.length).set(src);
  const i32 = (off, src) => new Int32Array(memory.buffer, off, src.length).set(src);
  f64(L.VX, d.vx); f64(L.VY, d.vy); f64(L.VZ, d.vz); f64(L.IM, d.im);
  f64(L.NX, d.nx); f64(L.NY, d.ny); f64(L.NZ, d.nz); f64(L.NM, d.nm);
  f64(L.RB, d.rb); f64(L.GA, d.ga); f64(L.ACC, d.acc);
  i32(L.IA, d.ia); i32(L.IB, d.ib);
}
const readBack = (memory, d) => ({
  vx: new Float64Array(memory.buffer, L.VX, d.bodyCount).slice(),
  acc: new Float64Array(memory.buffer, L.ACC, d.constraintCount).slice(),
});

const clone = (d) => ({ ...d, vx: d.vx.slice(), vy: d.vy.slice(), vz: d.vz.slice(),
  acc: d.acc.slice() });

// --- correctness -------------------------------------------------------------
const instances = {};
for (const [name, m] of Object.entries(modules)) {
  const memory = new WebAssembly.Memory({ initial: 64 });
  const mod = await WebAssembly.compile(m.bytes);
  const inst = await WebAssembly.instantiate(mod, { env: { memory } });
  instances[name] = { memory, solve: inst.exports.solve };
}

console.log("\n=== correctness (1 pass, against the shipped scalar arithmetic) ===");
const exactness = {};
for (const count of [2, 8, 64, 512, 2048]) {
  const base = fixture(count);
  const want = clone(base);
  oracle(want, 1);
  const row = [];
  for (const [name, inst] of Object.entries(instances)) {
    loadInto(inst.memory, base);
    inst.solve(count, 1);
    const got = readBack(inst.memory, base);
    let exact = 0, close = 0, worst = 0;
    for (let b = 0; b < base.bodyCount; b++) {
      if (Object.is(got.vx[b], want.vx[b])) exact++;
      const err = Math.abs(got.vx[b] - want.vx[b]);
      const scale = Math.max(1e-300, Math.abs(want.vx[b]));
      if (err / scale < 1e-12) close++;
      if (err / scale > worst) worst = err / scale;
    }
    row.push(`${name}: ${exact}/${base.bodyCount} bit-exact, ${close} within 1e-12, worst rel ${worst.toExponential(2)}`);
    exactness[name] = { exact, total: base.bodyCount, worst };
  }
  console.log(`  n=${String(count).padStart(4)}  ${row.join(" | ")}`);
}

// --- timing ------------------------------------------------------------------
function timeOne(fn, seconds = 0.4) {
  fn(); // warm
  const samples = [];
  for (let r = 0; r < 9; r++) {
    const t0 = process.hrtime.bigint();
    fn();
    samples.push(Number(process.hrtime.bigint() - t0) / 1e3);
  }
  samples.sort((a, b) => a - b);
  return samples[4];
}

console.log("\n=== timing: microseconds per solve pass, median of 9 ===");
console.log("  count      JS   wasm scalar   wasm simd   wasm relaxed   simd/scalar  relaxed/simd");
const ITERS = 40;
for (const count of [64, 256, 688, 2048]) {
  const base = fixture(count);
  const js = clone(base);
  const tJs = timeOne(() => oracle(js, ITERS)) / ITERS;
  const t = {};
  for (const [name, inst] of Object.entries(instances)) {
    loadInto(inst.memory, base);
    t[name] = timeOne(() => inst.solve(count, ITERS)) / ITERS;
  }
  const f = (x) => x.toFixed(2).padStart(8);
  console.log(`  ${String(count).padStart(5)}${f(tJs)}${f(t.scalar)}${f(t.simd)}${f(t.relaxed)}` +
    `      ${(t.scalar / t.simd).toFixed(2)}x        ${(t.simd / t.relaxed).toFixed(2)}x`);
}

// --- determinism -------------------------------------------------------------
console.log("\n=== determinism ===");
{
  // The correctness table above is the evidence: strict SIMD reproduces the
  // shipped scalar arithmetic bit for bit, and the relaxed variant does not.
  // `relaxed_madd` is *permitted* to fuse the multiply-add into one rounding and
  // V8 on this machine does; another engine, or the same engine on a CPU without
  // FMA, is permitted not to. So the same module can give different answers on
  // different machines, which is disqualifying for a simulation that has to
  // reproduce -- and this repository treats bit-identical output as the condition
  // for shipping a physics optimisation at all.
  //
  // How often does the choice actually matter? Count over a fixed sample rather
  // than stopping at the first few.
  const split = (x) => { const t = x * 134217729; const h = t - (t - x); return [h, x - h]; };
  const fused = (a, b, c) => {
    const [ah, al] = split(a), [bh, bl] = split(b);
    const p = a * b;
    const e = ((ah * bh - p) + ah * bl + al * bh) + al * bl;
    const s2 = p + c;
    const se = (p - (s2 - c)) + (c - (s2 - (s2 - c)));
    return s2 + (se + e);
  };
  let seed = 12345;
  const rnd = () => { seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0; return seed / 4294967296; };
  const N = 200000;
  let differ = 0;
  const examples = [];
  for (let i = 0; i < N; i++) {
    const a = rnd() * 2 - 1, b = rnd() * 2 - 1, c = rnd() * 2 - 1;
    if (!Object.is(a * b + c, fused(a, b, c))) {
      differ++;
      if (examples.length < 2) examples.push([a, b, c, a * b + c, fused(a, b, c)]);
    }
  }
  for (const [a, b, c, u, f2] of examples) {
    console.log(`  a=${a} b=${b} c=${c}`);
    console.log(`    unfused a*b+c = ${u}`);
    console.log(`    fused   a*b+c = ${f2}`);
  }
  console.log(`  ${(differ / N * 100).toFixed(1)}% of ${N} random multiply-adds round differently ` +
    `when fused (${differ} of ${N}).`);
}

// --- the boundary ------------------------------------------------------------
// None of the speed above is reachable without the solver's data living in Wasm
// linear memory. It does not: `VelocityState3D` is `Array[Double]`, which on the
// JS target is a JS array and on wasm-gc is a GC reference with no address in
// linear memory at all. So a real integration copies in and out every frame --
// the same reversal that `examples/games/iron_yard/experiments/simd/` measured,
// where per-draw conversion turned a 4.1x kernel win into a 2.9x loss.
console.log("\n=== boundary: copying one frame's solver state in and out ===");
{
  const bodies = 256, constraints = 688;
  const src = Array.from({ length: bodies * 6 + constraints * 7 }, (_, i) => i * 0.5);
  const dst = new Float64Array(src.length);
  const copyIn = () => { for (let i = 0; i < src.length; i++) dst[i] = src[i]; };
  const copyOut = () => { for (let i = 0; i < src.length; i++) src[i] = dst[i]; };
  const t = timeOne(() => { for (let k = 0; k < 40; k++) { copyIn(); copyOut(); } }) / 40;
  console.log(`  ${src.length} doubles (${bodies} bodies x 6 + ${constraints} constraints x 7), ` +
    `element-wise in and out: ${t.toFixed(2)} us/frame`);
  console.log("  On wasm-gc there is no way to do it at all: a `FixedArray` is a GC");
  console.log("  reference, so the host cannot read it out of `memory.buffer`.");
}
