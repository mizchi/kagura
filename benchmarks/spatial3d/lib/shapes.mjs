// Random shape construction for the spatial3d benchmark.

import { add, cross, dot, norm, normalize, scale, sub } from "./geometry.mjs";

export function mulberry32(seed) {
  let a = seed >>> 0;
  return () => {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

export class Rng {
  constructor(seed) {
    this.next = mulberry32(seed);
  }
  range(lo, hi) {
    return lo + (hi - lo) * this.next();
  }
  int(n) {
    return Math.floor(this.next() * n);
  }
  pick(list) {
    return list[this.int(list.length)];
  }
  unit() {
    // Marsaglia: uniform on the sphere.
    for (;;) {
      const x = this.range(-1, 1);
      const y = this.range(-1, 1);
      const s = x * x + y * y;
      if (s >= 1 || s === 0) continue;
      const k = 2 * Math.sqrt(1 - s);
      return [x * k, y * k, 1 - 2 * s];
    }
  }
  vec(lo, hi) {
    return [this.range(lo, hi), this.range(lo, hi), this.range(lo, hi)];
  }
  // Orthonormal right-handed frame with uniformly random orientation.
  frame() {
    const x = this.unit();
    let y = normalize(cross(x, this.unit()));
    while (norm(y) < 0.5) y = normalize(cross(x, this.unit()));
    return [x, y, cross(x, y)];
  }
}

export const POSITION_DECIMALS = 2;
export const AXIS_DECIMALS = 3;

const roundTo = (x, d) => {
  const r = Number(x.toFixed(d));
  return Object.is(r, -0) ? 0 : r;
};

// Round every number the model will see. Ground truth is always computed
// on the rounded shape, so rounding never changes the answer key.
// v1 uses the defaults; v2 passes { pos: 3, axis: 4 }.
export function roundShape(s, { pos = POSITION_DECIMALS, axis = AXIS_DECIMALS } = {}) {
  const rv = (v, d = pos) => v.map((x) => roundTo(x, d));
  const o = { ...s };
  for (const key of ["position", "center", "min", "max", "a", "b", "apex", "base_center"]) {
    if (o[key]) o[key] = rv(o[key]);
  }
  for (const key of ["radius", "major_radius", "minor_radius", "half_thickness"]) {
    if (o[key] !== undefined) o[key] = roundTo(o[key], pos);
  }
  for (const key of ["half_extents", "outer_half_extents", "inner_half_extents"]) {
    if (o[key]) o[key] = rv(o[key]);
  }
  if (o.vertices) o.vertices = o.vertices.map((v) => rv(v));
  if (o.axes) o.axes = o.axes.map((v) => rv(v, axis));
  if (o.axis) o.axis = rv(o.axis, axis);
  if (o.rotation) o.rotation = rv(o.rotation, axis);
  if (o.parts) o.parts = o.parts.map((p) => roundShape(p, { pos, axis }));
  return o;
}

export const CONVEX_TYPES = [
  "point",
  "sphere",
  "aabb",
  "obb",
  "segment",
  "capsule",
  "cylinder",
  "cone",
  "triangle",
  "tetrahedron",
];

const LOW_DIM = { point: 0, segment: 1, triangle: 2 };

// Pairs whose intersection is a measure-zero event (always "no" in practice)
// are excluded: point/point, point/segment, point/triangle, segment/segment.
export function pairIsMeaningful(a, b) {
  const da = LOW_DIM[a] ?? 3;
  const db = LOW_DIM[b] ?? 3;
  return da + db >= 3;
}

// A shape whose interior point is at the origin.
export function makeShape(type, rng) {
  switch (type) {
    case "point":
      return { type, position: [0, 0, 0] };
    case "sphere":
      return { type, center: [0, 0, 0], radius: rng.range(0.4, 1.5) };
    case "aabb": {
      const h = rng.vec(0.3, 1.5);
      return { type, min: scale(h, -1), max: h };
    }
    case "obb":
      return { type, center: [0, 0, 0], half_extents: rng.vec(0.3, 1.5), axes: rng.frame() };
    case "segment": {
      const d = scale(rng.unit(), rng.range(0.6, 2));
      return { type, a: scale(d, -1), b: d };
    }
    case "capsule": {
      const d = scale(rng.unit(), rng.range(0.3, 1.5));
      return { type, a: scale(d, -1), b: d, radius: rng.range(0.2, 0.8) };
    }
    case "cylinder": {
      const d = scale(rng.unit(), rng.range(0.3, 1.5));
      return { type, a: scale(d, -1), b: d, radius: rng.range(0.3, 1.2) };
    }
    case "cone": {
      const u = rng.unit();
      const h = rng.range(0.8, 3);
      // Interior point (base + h/4) at the origin.
      return {
        type,
        apex: scale(u, h * 0.75),
        base_center: scale(u, -h * 0.25),
        radius: rng.range(0.3, 1.2),
      };
    }
    case "triangle": {
      for (;;) {
        const v = [rng.vec(-1.5, 1.5), rng.vec(-1.5, 1.5), rng.vec(-1.5, 1.5)];
        const area = norm(cross(sub(v[1], v[0]), sub(v[2], v[0]))) / 2;
        if (area < 0.6) continue;
        const c = scale(add(add(v[0], v[1]), v[2]), 1 / 3);
        return { type, vertices: v.map((p) => sub(p, c)) };
      }
    }
    case "tetrahedron": {
      for (;;) {
        const v = [0, 1, 2, 3].map(() => rng.vec(-1.4, 1.4));
        const vol = Math.abs(dot(sub(v[1], v[0]), cross(sub(v[2], v[0]), sub(v[3], v[0])))) / 6;
        if (vol < 0.25) continue;
        const c = scale(v.reduce(add, [0, 0, 0]), 1 / 4);
        return { type, vertices: v.map((p) => sub(p, c)) };
      }
    }
    case "torus": {
      const major = rng.range(1, 2.5);
      return {
        type,
        center: [0, 0, 0],
        axis: rng.unit(),
        major_radius: major,
        minor_radius: rng.range(0.2, 0.45) * major,
      };
    }
    default:
      throw new Error(`unknown shape type ${type}`);
  }
}

// ---------------------------------------------------------------- v2

// Uniform random unit quaternion [w, x, y, z] with w >= 0 (Shoemake).
export function randomQuat(rng) {
  const u1 = rng.next();
  const u2 = rng.next() * 2 * Math.PI;
  const u3 = rng.next() * 2 * Math.PI;
  const a = Math.sqrt(1 - u1);
  const b = Math.sqrt(u1);
  const q = [b * Math.cos(u3), a * Math.sin(u2), a * Math.cos(u2), b * Math.sin(u3)];
  return q[0] < 0 ? q.map((c) => -c) : q;
}

export const V2_CONVEX_TYPES = CONVEX_TYPES;

// v2 shapes: boxes are rotated by quaternion; compound (L/U of boxes) and
// frame (plate with a rectangular through-hole) are non-convex. The returned
// `meta.concavity` is a local point inside the notch/hole, used only by the
// generator to aim objects into it; it is never shown to the model.
export function makeShapeV2(type, rng, rotateFn) {
  switch (type) {
    case "obb":
      return { shape: { type, center: [0, 0, 0], half_extents: rng.vec(0.3, 1.5), rotation: randomQuat(rng) } };
    case "compound": {
      const q = randomQuat(rng);
      const w = rng.range(0.25, 0.5);
      const d = rng.range(0.25, 0.7);
      const l1 = rng.range(1.4, 2.6);
      const l2 = rng.range(1.2, 2.4);
      const box = (c, h) => ({ type: "obb", center: rotateFn(q, c), half_extents: h, rotation: q });
      const parts = [box([l1 / 2, w / 2, 0], [l1 / 2, w / 2, d]), box([w / 2, l2 / 2, 0], [w / 2, l2 / 2, d])];
      const u = rng.next() < 0.5;
      if (u) parts.push(box([l1 - w / 2, l2 / 2, 0], [w / 2, l2 / 2, d]));
      // Centre the shape roughly on the origin.
      const shift = rotateFn(q, [-l1 / 2, -l2 / 2, 0]);
      const moved = parts.map((p) => ({ ...p, center: p.center.map((x, k) => x + shift[k]) }));
      return { shape: { type, parts: moved }, meta: { concavity: rotateFn(q, [l1 / 2, l2 / 2, 0]).map((x, k) => x + shift[k]), kind: u ? "U" : "L", normal: rotateFn(q, [0, 0, 1]) } };
    }
    case "frame": {
      const ix = rng.range(0.35, 1.1);
      const iy = rng.range(0.35, 1.1);
      const q = randomQuat(rng);
      return {
        shape: {
          type,
          center: [0, 0, 0],
          rotation: q,
          outer_half_extents: [ix + rng.range(0.2, 0.6), iy + rng.range(0.2, 0.6)],
          inner_half_extents: [ix, iy],
          half_thickness: rng.range(0.1, 0.35),
        },
        meta: { concavity: [0, 0, 0], normal: rotateFn(q, [0, 0, 1]) },
      };
    }
    case "torus": {
      const s = makeShape("torus", rng);
      return { shape: s, meta: { concavity: [0, 0, 0], normal: s.axis } };
    }
    default:
      return { shape: makeShape(type, rng) };
  }
}

export function withId(id, shape) {
  return { id, ...shape };
}
