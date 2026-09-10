// WAT sources for the contact-solve leaf kernel, in three variants.
//
// The kernel is the normal-impulse half of `solve_constraint3d`'s
// non-angular fast path, which is the shape the shipped solver spends most of
// its time in:
//
//   vn     = (v[ia] - v[ib]) . n
//   lambda = -(vn + rb + ga * acc) * nm
//   acc'   = min(0, acc + lambda)
//   d      = acc' - acc
//   v[ia] += n * d * im[ia];  v[ib] -= n * d * im[ib]
//
// All three variants read the same SoA layout and do the same indexed
// gather/scatter, so the comparison is not rigged in SIMD's favour by handing it
// a layout the scalar version does not get.
//
// Grouping matters: the scalar expression order is `(n.x * d) * im`, matching
// `physics3d/solver.mbt`, and the vector variants keep it.

/** Byte offsets, given capacities. All arrays are 16-byte aligned for v128. */
export function layout(maxBodies, maxConstraints) {
  const align = (x) => (x + 15) & ~15;
  const b8 = align(maxBodies * 8);
  const c8 = align(maxConstraints * 8);
  const c4 = align(maxConstraints * 4);
  let o = 0;
  const at = (size) => { const a = o; o += size; return a; };
  return {
    VX: at(b8), VY: at(b8), VZ: at(b8), IM: at(b8),
    NX: at(c8), NY: at(c8), NZ: at(c8), NM: at(c8), RB: at(c8), GA: at(c8),
    ACC: at(c8),
    IA: at(c4), IB: at(c4),
    bytes: o,
  };
}

const scalarBody = (L) => `
    ;; --- gather ---
    (local.set $ia (i32.mul (i32.load offset=${L.IA} (local.get $c4)) (i32.const 8)))
    (local.set $ib (i32.mul (i32.load offset=${L.IB} (local.get $c4)) (i32.const 8)))
    (local.set $nx (f64.load offset=${L.NX} (local.get $c8)))
    (local.set $ny (f64.load offset=${L.NY} (local.get $c8)))
    (local.set $nz (f64.load offset=${L.NZ} (local.get $c8)))
    (local.set $acc (f64.load offset=${L.ACC} (local.get $c8)))
    ;; --- vn = (va - vb) . n ---
    (local.set $vn (f64.add (f64.add
      (f64.mul (f64.sub (f64.load offset=${L.VX} (local.get $ia))
                        (f64.load offset=${L.VX} (local.get $ib))) (local.get $nx))
      (f64.mul (f64.sub (f64.load offset=${L.VY} (local.get $ia))
                        (f64.load offset=${L.VY} (local.get $ib))) (local.get $ny)))
      (f64.mul (f64.sub (f64.load offset=${L.VZ} (local.get $ia))
                        (f64.load offset=${L.VZ} (local.get $ib))) (local.get $nz))))
    ;; --- lambda, clamp, delta ---
    (local.set $d (f64.mul (f64.neg (f64.add (f64.add (local.get $vn)
        (f64.load offset=${L.RB} (local.get $c8)))
        (f64.mul (f64.load offset=${L.GA} (local.get $c8)) (local.get $acc))))
      (f64.load offset=${L.NM} (local.get $c8))))
    (local.set $d (f64.add (local.get $acc) (local.get $d)))
    (local.set $d (select (f64.const 0) (local.get $d)
                          (f64.gt (local.get $d) (f64.const 0))))
    (f64.store offset=${L.ACC} (local.get $c8) (local.get $d))
    (local.set $d (f64.sub (local.get $d) (local.get $acc)))
    ;; --- scatter ---
    (local.set $ima (f64.load offset=${L.IM} (local.get $ia)))
    (local.set $imb (f64.load offset=${L.IM} (local.get $ib)))
    (f64.store offset=${L.VX} (local.get $ia) (f64.add (f64.load offset=${L.VX} (local.get $ia))
      (f64.mul (f64.mul (local.get $nx) (local.get $d)) (local.get $ima))))
    (f64.store offset=${L.VY} (local.get $ia) (f64.add (f64.load offset=${L.VY} (local.get $ia))
      (f64.mul (f64.mul (local.get $ny) (local.get $d)) (local.get $ima))))
    (f64.store offset=${L.VZ} (local.get $ia) (f64.add (f64.load offset=${L.VZ} (local.get $ia))
      (f64.mul (f64.mul (local.get $nz) (local.get $d)) (local.get $ima))))
    (f64.store offset=${L.VX} (local.get $ib) (f64.sub (f64.load offset=${L.VX} (local.get $ib))
      (f64.mul (f64.mul (local.get $nx) (local.get $d)) (local.get $imb))))
    (f64.store offset=${L.VY} (local.get $ib) (f64.sub (f64.load offset=${L.VY} (local.get $ib))
      (f64.mul (f64.mul (local.get $ny) (local.get $d)) (local.get $imb))))
    (f64.store offset=${L.VZ} (local.get $ib) (f64.sub (f64.load offset=${L.VZ} (local.get $ib))
      (f64.mul (f64.mul (local.get $nz) (local.get $d)) (local.get $imb))))`;

export function scalarWat(L) {
  return `(module
  (import "env" "memory" (memory 64))
  (func (export "solve") (param $count i32) (param $iters i32)
    (local $it i32) (local $i i32) (local $c8 i32) (local $c4 i32)
    (local $ia i32) (local $ib i32)
    (local $nx f64) (local $ny f64) (local $nz f64)
    (local $acc f64) (local $vn f64) (local $d f64)
    (local $ima f64) (local $imb f64)
    (loop $outer
      (local.set $i (i32.const 0))
      (block $done (loop $inner
        (br_if $done (i32.ge_u (local.get $i) (local.get $count)))
        (local.set $c8 (i32.mul (local.get $i) (i32.const 8)))
        (local.set $c4 (i32.mul (local.get $i) (i32.const 4)))
        ${scalarBody(L)}
        (local.set $i (i32.add (local.get $i) (i32.const 1)))
        (br $inner)))
      (local.set $it (i32.add (local.get $it) (i32.const 1)))
      (br_if $outer (i32.lt_u (local.get $it) (local.get $iters)))))
)`;
}

// Two constraints per iteration in f64x2 lanes. Sound only when the two
// constraints touch disjoint bodies -- otherwise lane 1 reads velocity that lane
// 0 has already changed in the scalar order, and the pass silently becomes
// Jacobi within the group. That disjointness is what a constraint graph colouring
// buys you, and it is why Box2D v3 needs colouring before it can use SIMD at all.
function simdWat(L, madd) {
  // madd(acc, a, b) -> "acc + a*b" as a WAT expression string.
  const gather = (base, l0, l1) => `(f64x2.replace_lane 1
      (f64x2.splat (f64.load offset=${base} (local.get ${l0})))
      (f64.load offset=${base} (local.get ${l1})))`;
  const scatter = (base, lane, l0, l1, v) => `
    (f64.store offset=${base} (local.get ${l0}) (f64x2.extract_lane 0 ${v}))
    (f64.store offset=${base} (local.get ${l1}) (f64x2.extract_lane 1 ${v}))`;
  return `(module
  (import "env" "memory" (memory 64))
  (func (export "solve") (param $count i32) (param $iters i32)
    (local $it i32) (local $i i32) (local $c8 i32) (local $c4 i32)
    (local $ia0 i32) (local $ia1 i32) (local $ib0 i32) (local $ib1 i32)
    (local $nx v128) (local $ny v128) (local $nz v128)
    (local $acc v128) (local $vn v128) (local $d v128)
    (local $va v128) (local $vb v128)
    (local $ima v128) (local $imb v128)
    (loop $outer
      (local.set $i (i32.const 0))
      (block $done (loop $inner
        (br_if $done (i32.gt_u (i32.add (local.get $i) (i32.const 2)) (local.get $count)))
        (local.set $c8 (i32.mul (local.get $i) (i32.const 8)))
        (local.set $c4 (i32.mul (local.get $i) (i32.const 4)))
        (local.set $ia0 (i32.mul (i32.load offset=${L.IA} (local.get $c4)) (i32.const 8)))
        (local.set $ia1 (i32.mul (i32.load offset=${L.IA + 4} (local.get $c4)) (i32.const 8)))
        (local.set $ib0 (i32.mul (i32.load offset=${L.IB} (local.get $c4)) (i32.const 8)))
        (local.set $ib1 (i32.mul (i32.load offset=${L.IB + 4} (local.get $c4)) (i32.const 8)))
        (local.set $nx (v128.load offset=${L.NX} (local.get $c8)))
        (local.set $ny (v128.load offset=${L.NY} (local.get $c8)))
        (local.set $nz (v128.load offset=${L.NZ} (local.get $c8)))
        (local.set $acc (v128.load offset=${L.ACC} (local.get $c8)))
        ;; vn = (va - vb) . n, lane-gathered per axis
        (local.set $vn (f64x2.mul (f64x2.sub ${gather(L.VX, "$ia0", "$ia1")}
                                             ${gather(L.VX, "$ib0", "$ib1")}) (local.get $nx)))
        (local.set $vn ${madd("(local.get $vn)",
          `(f64x2.sub ${gather(L.VY, "$ia0", "$ia1")} ${gather(L.VY, "$ib0", "$ib1")})`,
          "(local.get $ny)")})
        (local.set $vn ${madd("(local.get $vn)",
          `(f64x2.sub ${gather(L.VZ, "$ia0", "$ia1")} ${gather(L.VZ, "$ib0", "$ib1")})`,
          "(local.get $nz)")})
        ;; lambda = -(vn + rb + ga*acc) * nm
        (local.set $d (f64x2.mul (f64x2.neg ${madd(
          `(f64x2.add (local.get $vn) (v128.load offset=${L.RB} (local.get $c8)))`,
          `(v128.load offset=${L.GA} (local.get $c8))`, "(local.get $acc)")})
          (v128.load offset=${L.NM} (local.get $c8))))
        (local.set $d (f64x2.add (local.get $acc) (local.get $d)))
        ;; clamp to <= 0 without a branch
        (local.set $d (f64x2.pmin (local.get $d) (f64x2.splat (f64.const 0))))
        (v128.store offset=${L.ACC} (local.get $c8) (local.get $d))
        (local.set $d (f64x2.sub (local.get $d) (local.get $acc)))
        (local.set $ima ${gather(L.IM, "$ia0", "$ia1")})
        (local.set $imb ${gather(L.IM, "$ib0", "$ib1")})
        ${["$nx", "$ny", "$nz"].map((n, k) => {
          const base = [L.VX, L.VY, L.VZ][k];
          const step = `(f64x2.mul (f64x2.mul (local.get ${n}) (local.get $d))`;
          return scatter(base, k, "$ia0", "$ia1",
            `(f64x2.add ${gather(base, "$ia0", "$ia1")} ${step} (local.get $ima)))`) +
            scatter(base, k, "$ib0", "$ib1",
            `(f64x2.sub ${gather(base, "$ib0", "$ib1")} ${step} (local.get $imb)))`);
        }).join("\n")}
        (local.set $i (i32.add (local.get $i) (i32.const 2)))
        (br $inner)))
      (local.set $it (i32.add (local.get $it) (i32.const 1)))
      (br_if $outer (i32.lt_u (local.get $it) (local.get $iters)))))
)`;
}

export const simdStrictWat = (L) =>
  simdWat(L, (acc, a, b) => `(f64x2.add ${acc} (f64x2.mul ${a} ${b}))`);

// `f64x2.relaxed_madd(a, b, c)` computes `a*b + c`, and whether it fuses into a
// single rounding is left to the engine. That is the whole point of the relaxed
// proposal, and also the whole problem with it here.
export const simdRelaxedWat = (L) =>
  simdWat(L, (acc, a, b) => `(f64x2.relaxed_madd ${a} ${b} ${acc})`);
