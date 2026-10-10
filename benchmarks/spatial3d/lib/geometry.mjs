// Ground truth for the spatial3d benchmark.
//
// Every convex shape is described by a support function and tested with GJK
// (distance variant, brute-force Johnson sub-algorithm). The torus is not
// convex, so its tests are closed-form instead. All shapes are solid.

export const add = (a, b) => [a[0] + b[0], a[1] + b[1], a[2] + b[2]];
export const sub = (a, b) => [a[0] - b[0], a[1] - b[1], a[2] - b[2]];
export const scale = (a, s) => [a[0] * s, a[1] * s, a[2] * s];
export const dot = (a, b) => a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
export const cross = (a, b) => [
  a[1] * b[2] - a[2] * b[1],
  a[2] * b[0] - a[0] * b[2],
  a[0] * b[1] - a[1] * b[0],
];
export const norm = (a) => Math.sqrt(dot(a, a));
export const normalize = (a) => {
  const n = norm(a);
  return n === 0 ? [0, 0, 0] : scale(a, 1 / n);
};

// Unit quaternion [w, x, y, z] (Hamilton, normalized here) to the images
// of the local x, y, z axes, i.e. the columns of the rotation matrix.
export function quatToAxes(q) {
  const n = Math.hypot(...q);
  const [w, x, y, z] = q.map((c) => c / n);
  return [
    [1 - 2 * (y * y + z * z), 2 * (x * y + w * z), 2 * (x * z - w * y)],
    [2 * (x * y - w * z), 1 - 2 * (x * x + z * z), 2 * (y * z + w * x)],
    [2 * (x * z + w * y), 2 * (y * z - w * x), 1 - 2 * (x * x + y * y)],
  ];
}

export function rotate(q, v) {
  const [ax, ay, az] = quatToAxes(q);
  return add(add(scale(ax, v[0]), scale(ay, v[1])), scale(az, v[2]));
}

// v1 boxes carry explicit axes, v2 boxes a quaternion.
export const obbAxes = (s) => s.axes ?? quatToAxes(s.rotation);

// Convex pieces whose union is the shape. Non-convex v2 shapes (frame,
// compound) are decomposed here; everything else is its own single piece.
export function convexParts(shape) {
  switch (shape.type) {
    case "compound":
      return shape.parts.flatMap(convexParts);
    case "frame": {
      const [ox, oy] = shape.outer_half_extents;
      const [ix, iy] = shape.inner_half_extents;
      const t = shape.half_thickness;
      const bar = (local, half) => ({ type: "obb", center: add(shape.center, rotate(shape.rotation, local)), half_extents: half, rotation: shape.rotation });
      return [
        bar([0, (oy + iy) / 2, 0], [ox, (oy - iy) / 2, t]),
        bar([0, -(oy + iy) / 2, 0], [ox, (oy - iy) / 2, t]),
        bar([(ox + ix) / 2, 0, 0], [(ox - ix) / 2, iy, t]),
        bar([-(ox + ix) / 2, 0, 0], [(ox - ix) / 2, iy, t]),
      ];
    }
    case "torus":
      throw new Error("torus has no convex decomposition");
    default:
      return [shape];
  }
}

// World-space axis-aligned bounds.
export function bounds(shape) {
  if (shape.type === "torus") {
    const n = normalize(shape.axis);
    const e = n.map((x) => shape.major_radius * Math.sqrt(Math.max(0, 1 - x * x)) + shape.minor_radius);
    return { min: sub(shape.center, e), max: add(shape.center, e) };
  }
  const min = [Infinity, Infinity, Infinity];
  const max = [-Infinity, -Infinity, -Infinity];
  for (const part of convexParts(shape)) {
    for (let k = 0; k < 3; k++) {
      const d = [0, 0, 0];
      d[k] = 1;
      max[k] = Math.max(max[k], support(part, d)[k]);
      d[k] = -1;
      min[k] = Math.min(min[k], support(part, d)[k]);
    }
  }
  return { min, max };
}

function maxVertex(vertices, d) {
  let best = vertices[0];
  let bestDot = dot(best, d);
  for (let i = 1; i < vertices.length; i++) {
    const v = dot(vertices[i], d);
    if (v > bestDot) {
      bestDot = v;
      best = vertices[i];
    }
  }
  return best;
}

// Component of d perpendicular to the unit vector u, normalized (or zero).
// When d is nearly parallel to u the remainder is dominated by rounding
// error, so it is projected twice and dropped below a relative threshold.
function perpDir(d, u) {
  let p = sub(d, scale(u, dot(d, u)));
  p = sub(p, scale(u, dot(p, u)));
  if (norm(p) <= 1e-9 * norm(d)) return [0, 0, 0];
  return normalize(p);
}

export function support(shape, d) {
  switch (shape.type) {
    case "point":
      return shape.position;
    case "sphere":
      return add(shape.center, scale(normalize(d), shape.radius));
    case "aabb":
      return [0, 1, 2].map((i) => (d[i] >= 0 ? shape.max[i] : shape.min[i]));
    case "obb": {
      let p = shape.center;
      const axes = obbAxes(shape);
      for (let i = 0; i < 3; i++) {
        const axis = axes[i];
        const s = dot(d, axis) >= 0 ? 1 : -1;
        p = add(p, scale(axis, s * shape.half_extents[i]));
      }
      return p;
    }
    case "segment":
      return maxVertex([shape.a, shape.b], d);
    case "capsule":
      return add(maxVertex([shape.a, shape.b], d), scale(normalize(d), shape.radius));
    case "triangle":
    case "tetrahedron":
      return maxVertex(shape.vertices, d);
    case "cylinder": {
      const u = normalize(sub(shape.b, shape.a));
      const end = dot(d, u) >= 0 ? shape.b : shape.a;
      return add(end, scale(perpDir(d, u), shape.radius));
    }
    case "cone": {
      const u = normalize(sub(shape.apex, shape.base_center));
      const rim = add(shape.base_center, scale(perpDir(d, u), shape.radius));
      return dot(shape.apex, d) >= dot(rim, d) ? shape.apex : rim;
    }
    default:
      throw new Error(`no support function for ${shape.type}`);
  }
}

// A point known to lie inside the shape.
export function interiorPoint(shape) {
  switch (shape.type) {
    case "point":
      return shape.position;
    case "sphere":
    case "obb":
    case "torus_center_unused":
      return shape.center;
    case "aabb":
      return scale(add(shape.min, shape.max), 0.5);
    case "segment":
    case "capsule":
    case "cylinder":
      return scale(add(shape.a, shape.b), 0.5);
    case "triangle":
    case "tetrahedron": {
      let p = [0, 0, 0];
      for (const v of shape.vertices) p = add(p, v);
      return scale(p, 1 / shape.vertices.length);
    }
    case "cone":
      return add(scale(shape.base_center, 0.75), scale(shape.apex, 0.25));
    case "compound":
    case "frame":
      return interiorPoint(convexParts(shape)[0]);
    default:
      throw new Error(`no interior point for ${shape.type}`);
  }
}

// Radius of a ball around interiorPoint() that contains the shape.
export function boundingRadius(shape) {
  const c = interiorPoint(shape);
  let r = 0;
  const dirs = fibonacciDirections(64);
  for (const d of dirs) r = Math.max(r, dot(sub(support(shape, d), c), d));
  // Support distance along sampled directions underestimates slightly.
  return r * 1.05;
}

export function translate(shape, t) {
  const s = structuredClone(shape);
  const mv = (p) => add(p, t);
  switch (s.type) {
    case "point":
      s.position = mv(s.position);
      break;
    case "sphere":
    case "obb":
    case "torus":
    case "frame":
      s.center = mv(s.center);
      break;
    case "compound":
      s.parts = s.parts.map((p) => translate(p, t));
      break;
    case "aabb":
      s.min = mv(s.min);
      s.max = mv(s.max);
      break;
    case "segment":
    case "capsule":
    case "cylinder":
      s.a = mv(s.a);
      s.b = mv(s.b);
      break;
    case "triangle":
    case "tetrahedron":
      s.vertices = s.vertices.map(mv);
      break;
    case "cone":
      s.apex = mv(s.apex);
      s.base_center = mv(s.base_center);
      break;
    default:
      throw new Error(`cannot translate ${s.type}`);
  }
  return s;
}

export function fibonacciDirections(n) {
  const out = [];
  const golden = Math.PI * (3 - Math.sqrt(5));
  for (let i = 0; i < n; i++) {
    const y = 1 - (2 * (i + 0.5)) / n;
    const r = Math.sqrt(1 - y * y);
    const t = golden * i;
    out.push([Math.cos(t) * r, y, Math.sin(t) * r]);
  }
  return out;
}

// ---------------------------------------------------------------- GJK

function solve(m, rhs) {
  const n = rhs.length;
  const a = m.map((row, i) => [...row, rhs[i]]);
  for (let c = 0; c < n; c++) {
    let piv = c;
    for (let r = c + 1; r < n; r++) if (Math.abs(a[r][c]) > Math.abs(a[piv][c])) piv = r;
    if (Math.abs(a[piv][c]) < 1e-14) return null;
    [a[c], a[piv]] = [a[piv], a[c]];
    for (let r = 0; r < n; r++) {
      if (r === c) continue;
      const f = a[r][c] / a[c][c];
      for (let k = c; k <= n; k++) a[r][k] -= f * a[c][k];
    }
  }
  return a.map((row, i) => row[n] / row[i]);
}

// Closest point to the origin on the convex hull of up to 4 points.
function closestOnSimplex(pts) {
  let best = null;
  const n = pts.length;
  for (let mask = 1; mask < 1 << n; mask++) {
    const idx = [];
    for (let i = 0; i < n; i++) if (mask & (1 << i)) idx.push(i);
    const p0 = pts[idx[0]];
    const edges = idx.slice(1).map((i) => sub(pts[i], p0));
    let lambdas;
    let point;
    if (edges.length === 0) {
      lambdas = [1];
      point = p0;
    } else {
      const gram = edges.map((e) => edges.map((f) => dot(e, f)));
      const mu = solve(gram, edges.map((e) => -dot(e, p0)));
      if (!mu) continue;
      lambdas = [1 - mu.reduce((s, x) => s + x, 0), ...mu];
      point = p0;
      for (let k = 0; k < edges.length; k++) point = add(point, scale(edges[k], mu[k]));
    }
    if (lambdas.some((l) => l < -1e-12)) continue;
    const d2 = dot(point, point);
    if (!best || d2 < best.d2 - 1e-18) best = { d2, point, idx, lambdas };
  }
  return best;
}

function witness(vertices, idx, lambdas, key) {
  let p = [0, 0, 0];
  idx.forEach((i, k) => {
    p = add(p, scale(vertices[i][key], lambdas[k]));
  });
  return p;
}

// Returns { intersecting, distance, converged, witnessA, witnessB }.
// witnessA lies in a and witnessB in b (convex combinations of support
// points); they coincide when intersecting, and are the closest pair
// otherwise. Tests use them as an independent certificate.
export function gjk(a, b, { maxIter = 256, tol = 1e-12 } = {}) {
  const vertex = (d) => {
    const pa = support(a, d);
    const pb = support(b, scale(d, -1));
    return { w: sub(pa, pb), pa, pb };
  };
  const ia = interiorPoint(a);
  const ib = interiorPoint(b);
  let v = sub(ia, ib);
  if (norm(v) < 1e-12) {
    return { intersecting: true, distance: 0, converged: true, witnessA: ia, witnessB: ib };
  }
  let simplex = [];
  let result = { idx: [], lambdas: [] };
  const done = (intersecting, distance, converged) => ({
    intersecting,
    distance,
    converged,
    witnessA: witness(simplex, result.idx, result.lambdas, "pa"),
    witnessB: witness(simplex, result.idx, result.lambdas, "pb"),
  });
  let lastDist = Infinity;
  for (let iter = 0; iter < maxIter; iter++) {
    const vert = vertex(scale(v, -1));
    const vv = dot(v, v);
    if (simplex.length > 0 && vv - dot(v, vert.w) <= tol * Math.max(1, vv)) {
      return done(false, Math.sqrt(vv), true);
    }
    const candidate = [...simplex, vert];
    const c = closestOnSimplex(candidate.map((x) => x.w));
    if (!c) return done(false, Math.sqrt(vv), false);
    const d = Math.sqrt(c.d2);
    if (simplex.length > 0 && d >= lastDist - 1e-15) {
      // No progress: the previous simplex already holds the closest point.
      return done(false, lastDist, true);
    }
    simplex = candidate;
    result = c;
    v = c.point;
    if (d < 1e-10 || c.idx.length === 4) return done(true, 0, true);
    simplex = c.idx.map((i) => candidate[i]);
    result = { idx: c.idx.map((_, k) => k), lambdas: c.lambdas };
    lastDist = d;
  }
  return done(false, lastDist, false);
}

// ---------------------------------------------------------------- torus

function distanceToRing(torus, p) {
  const q = sub(p, torus.center);
  const n = normalize(torus.axis);
  const h = dot(q, n);
  const radial = norm(sub(q, scale(n, h)));
  return Math.hypot(radial - torus.major_radius, h);
}

// Signed clearance between a solid torus and a sphere/point (exact).
function torusClearance(torus, other) {
  if (other.type === "sphere") {
    return distanceToRing(torus, other.center) - torus.minor_radius - other.radius;
  }
  if (other.type === "point") {
    return distanceToRing(torus, other.position) - torus.minor_radius;
  }
  throw new Error(`torus vs ${other.type} is not supported`);
}

// ---------------------------------------------------------------- facade

function convexIntersects(a, b) {
  const r = gjk(a, b);
  if (!r.converged) throw new Error("GJK did not converge");
  return r;
}

// How far b must be moved (minimum over many directions) until it no
// longer overlaps a; an upper bound on penetration depth. Convex only.
function convexDepth(a, b, nDirs = 96) {
  const reach = boundingRadius(a) + boundingRadius(b) + norm(sub(interiorPoint(a), interiorPoint(b)));
  const dirs = fibonacciDirections(nDirs);
  const centre = normalize(sub(interiorPoint(b), interiorPoint(a)));
  if (norm(centre) > 0) dirs.push(centre);
  let best = Infinity;
  for (const d of dirs) {
    let lo = 0;
    let hi = Math.min(best, reach * 2);
    if (convexIntersects(a, translate(b, scale(d, hi))).intersecting) continue;
    for (let i = 0; i < 40; i++) {
      const mid = (lo + hi) / 2;
      if (convexIntersects(a, translate(b, scale(d, mid))).intersecting) lo = mid;
      else hi = mid;
    }
    best = Math.min(best, hi);
  }
  return best;
}

const isConvex = (s) => s.type !== "torus" && s.type !== "compound" && s.type !== "frame";

// Positive: separation distance (exact). Negative: penetration measure.
// Convex pairs: convexDepth of the pair. Unions: the deepest convexDepth
// among the overlapping piece pairs (how deep the deepest contact is; moving
// that far may still leave another piece touching). Torus: closed form.
export function signedClearance(a, b) {
  if (a.type === "torus") return torusClearance(a, b);
  if (b.type === "torus") return torusClearance(b, a);
  if (isConvex(a) && isConvex(b)) {
    const r = convexIntersects(a, b);
    return r.intersecting ? -convexDepth(a, b) : r.distance;
  }
  let minDist = Infinity;
  let maxDepth = 0;
  for (const pa of convexParts(a)) {
    for (const pb of convexParts(b)) {
      const r = convexIntersects(pa, pb);
      if (r.intersecting) maxDepth = Math.max(maxDepth, convexDepth(pa, pb));
      else minDist = Math.min(minDist, r.distance);
    }
  }
  return maxDepth > 0 ? -maxDepth : minDist;
}

export function intersects(a, b) {
  if (a.type === "torus" || b.type === "torus") return signedClearance(a, b) < 0;
  return convexParts(a).some((pa) => convexParts(b).some((pb) => convexIntersects(pa, pb).intersecting));
}

export function characteristicSize(shape) {
  switch (shape.type) {
    case "point":
      return Infinity;
    case "torus":
      return shape.minor_radius;
    case "segment":
      return norm(sub(shape.a, shape.b)) / 2;
    case "compound":
    case "frame":
      return Math.min(...convexParts(shape).map(characteristicSize));
    default:
      return boundingRadius(shape);
  }
}

// ---------------------------------------------------------------- v3

// Minimum Euclidean distance between two solids (0 when they intersect).
// Unions: minimum over convex piece pairs. Torus: closed form, clamped.
export function distance(a, b) {
  if (a.type === "torus" || b.type === "torus") return Math.max(0, signedClearance(a, b));
  let best = Infinity;
  for (const pa of convexParts(a)) {
    for (const pb of convexParts(b)) {
      const r = convexIntersects(pa, pb);
      best = Math.min(best, r.intersecting ? 0 : r.distance);
    }
  }
  return best;
}

const CURVED = new Set(["sphere", "capsule", "cylinder", "cone", "torus"]);

function polytopeVertices(s) {
  switch (s.type) {
    case "point":
      return [s.position];
    case "segment":
      return [s.a, s.b];
    case "triangle":
    case "tetrahedron":
      return s.vertices;
    case "aabb":
    case "obb": {
      if (s.type === "obb") {
        const ax = obbAxes(s);
        return [-1, 1].flatMap((i) => [-1, 1].flatMap((j) => [-1, 1].map((k) => add(add(add(s.center, scale(ax[0], i * s.half_extents[0])), scale(ax[1], j * s.half_extents[1])), scale(ax[2], k * s.half_extents[2])))));
      }
      return [0, 1, 2, 3, 4, 5, 6, 7].map((m) => [0, 1, 2].map((k) => (m & (1 << k) ? s.max[k] : s.min[k])));
    }
    default:
      return null;
  }
}

// Dimension of the face of a polytope that supports it in direction n:
// how many of its vertices lie on the supporting plane.
function supportFeature(s, n) {
  const vs = polytopeVertices(s);
  const top = Math.max(...vs.map((v) => dot(v, n)));
  const scaleLen = Math.max(1, ...vs.map((v) => norm(v)));
  const k = vs.filter((v) => dot(v, n) >= top - 1e-6 * scaleLen).length;
  return k === 1 ? "vertex" : k === 2 ? "edge" : "face";
}

// Which features realise the minimum distance, e.g. "edge-face". Pairs that
// involve a curved surface are "curved"; intersecting pairs "overlap".
export function closestFeatures(a, b) {
  if (a.type === "torus" || b.type === "torus") return "curved";
  let best = null;
  for (const pa of convexParts(a)) {
    for (const pb of convexParts(b)) {
      const r = convexIntersects(pa, pb);
      if (r.intersecting) return "overlap";
      if (!best || r.distance < best.r.distance) best = { pa, pb, r };
    }
  }
  if (CURVED.has(best.pa.type) || CURVED.has(best.pb.type)) return "curved";
  const n = normalize(sub(best.r.witnessB, best.r.witnessA));
  return [supportFeature(best.pa, n), supportFeature(best.pb, scale(n, -1))].sort().join("-");
}
