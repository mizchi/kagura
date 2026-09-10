# Wasm SIMD / relaxed SIMD for the 3D contact solver

```sh
just physics-simd
```

Requires `wabt` from npm; it is deliberately **not** a repository dependency, so
install it ad hoc (`npm install --no-save wabt`) or point `WABT_PATH` at a copy.
Output goes to `test-results/physics3d-simd/` (`.wat` and `.wasm` per variant)
and is not a production asset.

Follows the methodology of `examples/games/iron_yard/experiments/simd/`: a leaf
kernel in imported-memory Wasm, checked against a JS oracle before it is timed,
with the opcodes verified so a "SIMD" variant that quietly compiled to scalar
cannot report a number. Three variants over identical data and an identical SoA
layout — scalar, strict `simd128`, and relaxed SIMD using `f64x2.relaxed_madd`.

The kernel is the normal-impulse half of `solve_constraint3d`'s non-angular fast
path, including the indexed gather and scatter through body indices. It is a
subset of the shipped solver, so read the **ratios**, not the absolute times.

## Conclusion

**Relaxed SIMD buys nothing here, and SIMD buys little.** Measured 2026-09-10,
Node 22.22 / V8 12.4, on the CI-class container.

| constraints | JS | wasm scalar | wasm simd | wasm relaxed | simd/scalar | relaxed/simd |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 1.48 | 1.29 | 1.51 | 1.58 | **0.85x** | 0.95x |
| 256 | 4.95 | 3.16 | 3.43 | 3.56 | **0.92x** | 0.96x |
| 688 | 13.22 | 10.46 | 9.50 | 10.01 | 1.10x | 0.95x |
| 2048 | 47.87 | 34.72 | 28.05 | 26.74 | 1.24x | 1.05x |

Microseconds per solve pass, median of 9.

- **`f64x2.relaxed_madd` is not faster** at any realistic size: 0.95x, 0.96x,
  0.95x, and 1.05x only at 2048 constraints. The kernel does about six
  multiply-adds out of thirty-odd operations per constraint; it is bound by the
  lane-by-lane gather and scatter and by the serial dependency, not by
  multiply-add throughput. Relaxed SIMD is aimed at the thing that is not the
  bottleneck.
- **SIMD is a *loss* below roughly 500 constraints** and a 1.1-1.24x win above.
  `f64x2` is two lanes, and each lane has to be filled with a separate
  `f64.load` + `replace_lane` and drained with `extract_lane`, because the two
  bodies of a constraint are at arbitrary indices.
- **Moving to Wasm at all is worth more than SIMD is**: scalar Wasm is
  1.15-1.57x over JS, against SIMD's 1.1-1.24x on top.

## Why it still would not pay

Three multipliers stack against it, each measured rather than assumed.

1. **The data is not in linear memory and cannot be.** `VelocityState3D` is
   `Array[Double]`: a JS array on the `js` target, and on `wasm-gc` a GC
   reference with no address in linear memory at all. Copying one frame's solver
   state in and out element-wise costs **12.9 us/frame** (6352 doubles). Against
   a best case of 4 substeps x (10.46 - 9.50) = 3.8 us saved by SIMD at 688
   constraints, the copy costs more than three times what SIMD returns. This is
   the same reversal the iron_yard MVP experiment measured, where per-draw
   conversion turned a 4.1x kernel win into a 2.9x loss.
2. **Gauss-Seidel is serially dependent.** Constraint *i+1* reads velocity that
   constraint *i* wrote. Two constraints may share a lane pair only if they touch
   four distinct bodies; otherwise the pass silently becomes Jacobi within the
   group and the simulation changes. The fixture here is *pre-coloured* to make
   the lanes disjoint, so the numbers above are an upper bound that assumes a
   constraint-graph colouring already exists. Box2D v3 ships graph colouring for
   exactly this reason, and it is a substantial subsystem, not a loop rewrite.
3. **Relaxed SIMD is not reproducible.** `relaxed_madd` *may* fuse the
   multiply-add into a single rounding, at the engine's discretion. V8 here does:
   the relaxed variant is bit-exact on 3765 of 4098 body velocities where scalar
   and strict SIMD are bit-exact on 4098 of 4098. Across a large random sample,
   **19.7% of multiply-adds round differently** when fused. An engine on a CPU
   without FMA is permitted to give the third answer. `physics3d` currently
   reproduces bit-for-bit across `js` and `native`, and
   `docs/performance/physics3d-optimization.md` treats that as the condition for
   shipping an optimisation, so this trade is not available for free.

Taking the most generous reading — the whole solve pass ported to hand-written
WAT, state resident in linear memory across substeps, colouring already done, the
1.3x Wasm-over-JS ratio holding for the full solver including friction, angular
terms and joints — the 448 us/frame the solve pass currently costs would become
roughly 312 us, minus 13 us of boundary: about **3.4% of a 3.6 ms frame**, in
exchange for a second implementation of the solver in a language the rest of the
engine is not written in, no `wasm-gc` support, and either lost reproducibility
or no relaxed opcodes.

`ContactConstraintRuntime3D`'s remaining per-frame allocation, by contrast, is
worth about 13% of the frame and is ordinary MoonBit.

## What would change the answer

- MoonBit gaining SIMD intrinsics **and** a way to back `Array[Double]` with
  linear memory, removing both the second implementation and the copy.
- `f32x4` instead of `f64x2`, doubling the lanes — but single precision in a
  contact solver changes behaviour on its own, so that is a separate decision.
- A contact-graph colouring, which is worth having anyway for multi-threading and
  is the prerequisite for any of this being correct.
