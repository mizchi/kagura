# Wasm SIMD MVP experiment

Run `just iron-yard-simd` from the repository root. Requires Zig 0.16, wasm-tools, wasm-opt, pnpm dependencies and installed Chrome. The task compiles and validates three tiny imported-memory Wasm modules, verifies their imports/exports and arithmetic, inspects SIMD opcodes, and runs seven rotated trials per size in Chrome. Binaries, WAT and measurements go to `test-results/iron-yard-simd/` and are not production assets.

The approach follows [mizchi's small SIMD Wasm gist](https://gist.github.com/mizchi/9fb6627ffa370f55d482c82bc8d36fcf). The kernel is specific to Kagura: column-major MVP matrices, f64 accumulation with the same order as `math3d.Mat4::multiply`, final f32 uniforms. Zig `@Vector(2, f64)` produces `f64x2.mul`/`f64x2.add`. No relaxed math or f32 intermediate arithmetic is used. Deterministic random matrices, very small/large finite values, negative zero, and counts 0/1/3/32/128/882 are checked against scalar JS with `Object.is`.

Measured on 2026-09-10, Chrome 152 / Apple M5, Zig 0.16.0, wasm-tools 1.245.1, wasm-opt 116. Times below are medians, **microseconds per 882 matrices**, not milliseconds per rendered frame.

| Input/call layout | JS | scalar Wasm | SIMD Wasm | SIMD + `-Oz` |
|---|---:|---:|---:|---:|
| Contiguous, arithmetic only | 37.4 | 7.6 | 7.0 | 8.2 |
| Contiguous, copy in/out included | 37.4 | 10.0 | 9.2 | 10.6 |
| Ordinary source arrays, one call per draw | 95.6 | 277.6 | 275.6 | 277.4 |
| Wasm binary bytes | — | 384 | 344 | 319 |

Contiguous SIMD is about 4.1× faster than the typed-array JS oracle including copies, but SIMD itself is only about 8% faster than scalar Wasm. Converting ordinary MoonBit-style source arrays per draw reverses the outcome: SIMD is about 2.9× slower than JS. `-Oz` reduces size but also slows this kernel.

The production renderer retains its JS/MoonBit matrix path. This experiment does not establish a rendered-frame speedup. A future integration should maintain transforms/uniforms in contiguous imported memory and submit a batch per pass, then remeasure whole frames. Replacing each existing `Mat4.multiply` call with a Wasm call is not justified by these results. The arithmetic-only opportunity for 882 matrices is approximately 0.028 ms; normal-matrix calculation, object allocation and packing the rest of each uniform are outside that number.
