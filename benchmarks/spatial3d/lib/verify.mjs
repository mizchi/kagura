// Independent verification of GJK verdicts (no shared code with support()).

import { convexParts, dot, gjk, norm, scale, sub, support } from "./geometry.mjs";

const clamp = (x, lo, hi) => Math.max(lo, Math.min(hi, x));

// Quaternion to axes via q * v * q^-1, independent of geometry.quatToAxes.
function quatToAxesIndependent(q) {
  const n = Math.hypot(...q);
  const [w, x, y, z] = q.map((c) => c / n);
  const mul = (a, b) => [
    a[0] * b[0] - a[1] * b[1] - a[2] * b[2] - a[3] * b[3],
    a[0] * b[1] + a[1] * b[0] + a[2] * b[3] - a[3] * b[2],
    a[0] * b[2] - a[1] * b[3] + a[2] * b[0] + a[3] * b[1],
    a[0] * b[3] + a[1] * b[2] - a[2] * b[1] + a[3] * b[0],
  ];
  const conj = [w, -x, -y, -z];
  return [[1, 0, 0], [0, 1, 0], [0, 0, 1]].map((v) => mul(mul([w, x, y, z], [0, ...v]), conj).slice(1));
}

// Membership written independently of the support functions.
export function contains(shape, p, eps = 1e-7) {
  const segDist = (a, b) => {
    const ab = sub(b, a);
    const t = clamp(dot(sub(p, a), ab) / dot(ab, ab), 0, 1);
    return norm(sub(p, [0, 1, 2].map((k) => a[k] + ab[k] * t)));
  };
  switch (shape.type) {
    case "point":
      return norm(sub(p, shape.position)) <= eps;
    case "sphere":
      return norm(sub(p, shape.center)) <= shape.radius + eps;
    case "aabb":
      return [0, 1, 2].every((k) => p[k] >= shape.min[k] - eps && p[k] <= shape.max[k] + eps);
    case "obb": {
      // Solve center + sum(s_i * axes_i) = p; rounded axes are only nearly
      // orthonormal, so projection would not match the stated definition.
      const ax = shape.axes ?? quatToAxesIndependent(shape.rotation);
      const m = [0, 1, 2].map((row) => [0, 1, 2].map((col) => ax[col][row]));
      const q = sub(p, shape.center);
      const d = det3(m);
      const coeff = [0, 1, 2].map((k) => det3(m.map((row, i) => row.map((x, j) => (j === k ? q[i] : x)))) / d);
      return coeff.every((c, k) => Math.abs(c) <= shape.half_extents[k] + eps);
    }
    case "frame": {
      // Plate |x|<=ox, |y|<=oy, |z|<=t in the frame's local coordinates,
      // minus the open hole |x|<ix, |y|<iy. Written directly, not from parts.
      const ax = quatToAxesIndependent(shape.rotation);
      const q = sub(p, shape.center);
      const [x, y, z] = ax.map((a) => dot(q, a));
      const [ox, oy] = shape.outer_half_extents;
      const [ix, iy] = shape.inner_half_extents;
      const inPlate = Math.abs(x) <= ox + eps && Math.abs(y) <= oy + eps && Math.abs(z) <= shape.half_thickness + eps;
      const inHole = Math.abs(x) < ix - eps && Math.abs(y) < iy - eps;
      return inPlate && !inHole;
    }
    case "compound":
      return shape.parts.some((part) => contains(part, p, eps));
    case "segment":
      return segDist(shape.a, shape.b) <= eps;
    case "capsule":
      return segDist(shape.a, shape.b) <= shape.radius + eps;
    case "cylinder":
    case "cone": {
      const base = shape.type === "cone" ? shape.base_center : shape.a;
      const top = shape.type === "cone" ? shape.apex : shape.b;
      const axis = sub(top, base);
      const len = norm(axis);
      const h = dot(sub(p, base), axis) / len;
      if (h < -eps || h > len + eps) return false;
      const radial = norm(sub(sub(p, base), scale(axis, h / len)));
      const r = shape.type === "cone" ? shape.radius * (1 - clamp(h / len, 0, 1)) : shape.radius;
      return radial <= r + eps;
    }
    case "triangle":
    case "tetrahedron": {
      // Barycentric coordinates by least squares over the affine hull.
      const [v0, ...rest] = shape.vertices;
      const e = rest.map((v) => sub(v, v0));
      const g = e.map((x) => e.map((y) => dot(x, y)));
      const rhs = e.map((x) => dot(x, sub(p, v0)));
      const mu = rest.length === 2 ? solve2(g, rhs) : solve3(g, rhs);
      let q = v0;
      mu.forEach((m, k) => (q = [0, 1, 2].map((c) => q[c] + e[k][c] * m)));
      return norm(sub(q, p)) <= eps && mu.every((m) => m >= -eps) && mu.reduce((x, y) => x + y, 0) <= 1 + eps;
    }
    default:
      throw new Error(shape.type);
  }
}
const solve2 = (g, r) => {
  const det = g[0][0] * g[1][1] - g[0][1] * g[1][0];
  return [(r[0] * g[1][1] - g[0][1] * r[1]) / det, (g[0][0] * r[1] - r[0] * g[1][0]) / det];
};
const det3 = (m) =>
  m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1]) -
  m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0]) +
  m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0]);
const solve3 = (g, r) => {
  const d = det3(g);
  return [0, 1, 2].map((k) => det3(g.map((row, i) => row.map((x, j) => (j === k ? r[i] : x)))) / d);
};


// Throws unless the GJK verdict for (a, b) is proven by its witnesses.
export function certify(a, b, eps = 1e-6) {
  const r = gjk(a, b);
  if (!r.converged) throw new Error("GJK did not converge");
  if (!contains(a, r.witnessA, eps) || !contains(b, r.witnessB, eps)) throw new Error("witness outside shape");
  if (r.intersecting) {
    if (norm(sub(r.witnessA, r.witnessB)) > 1e-8) throw new Error("witnesses differ");
    return r;
  }
  const v = sub(r.witnessA, r.witnessB);
  const d = scale(v, 1 / norm(v));
  const lower = dot(support(a, scale(d, -1)), d) - dot(support(b, d), d);
  if (r.distance - lower > eps) throw new Error("separation not certified");
  return r;
}

// Certifies every convex piece pair of two (possibly non-convex) shapes and
// returns whether any piece pair intersects.
export function certifyAll(a, b, eps = 1e-6) {
  let any = false;
  for (const pa of convexParts(a)) for (const pb of convexParts(b)) if (certify(pa, pb, eps).intersecting) any = true;
  return any;
}
