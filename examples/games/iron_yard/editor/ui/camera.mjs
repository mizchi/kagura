export const add = (a, b) => a.map((v, i) => v + b[i]);
export const sub = (a, b) => a.map((v, i) => v - b[i]);
export const scale = (a, s) => a.map((v) => v * s);
const dot = (a, b) => a.reduce((n, v, i) => n + v * b[i], 0);
const cross = (a, b) => [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]];
export const normal = (a) => scale(a, 1 / Math.max(Math.hypot(...a), 1e-9));
export function ray(camera, x, y, aspect) {
  const forward = normal(sub(camera.target, camera.eye)),
    right = normal(cross(forward, [0, 1, 0])),
    up = cross(right, forward),
    t = Math.tan((48 * Math.PI) / 360);
  return {
    origin: camera.eye,
    direction: normal(add(forward, add(scale(right, x * t * aspect), scale(up, y * t)))),
  };
}
export function pick(ray, bounds) {
  let best = Infinity,
    id = null;
  for (const box of bounds) {
    let near = 0,
      far = Infinity;
    for (let i = 0; i < 3; i++) {
      const min = box.center[i] - box.size[i] / 2,
        max = box.center[i] + box.size[i] / 2,
        d = ray.direction[i],
        o = ray.origin[i];
      if (Math.abs(d) < 1e-9) {
        if (o < min || o > max) {
          far = -1;
          break;
        }
        continue;
      }
      const a = (min - o) / d,
        b = (max - o) / d;
      near = Math.max(near, Math.min(a, b));
      far = Math.min(far, Math.max(a, b));
    }
    if (near <= far && near < best) {
      best = near;
      id = box.id;
    }
  }
  return id;
}
export function orbitCamera(camera, dx, dy) {
  const p = sub(camera.eye, camera.target),
    r = Math.hypot(...p),
    theta = Math.atan2(p[0], p[2]) + dx,
    phi = Math.max(0.02, Math.min(Math.PI - 0.02, Math.acos(p[1] / r) + dy));
  return {
    target: camera.target,
    eye: add(camera.target, [
      r * Math.sin(phi) * Math.sin(theta),
      r * Math.cos(phi),
      r * Math.sin(phi) * Math.cos(theta),
    ]),
  };
}
export function frameCamera(camera, box) {
  return {
    target: box.center,
    eye: add(
      box.center,
      scale(normal(sub(camera.eye, camera.target)), Math.max(Math.hypot(...box.size) * 1.6, 10)),
    ),
  };
}
export function sceneBounds(doc, wave) {
  const ids = new Set(doc.mission.waves[wave].targets);
  return [
    ...doc.stage.solids,
    { id: 'spawn', center: add(doc.stage.spawn, [0, 2.3, 0]), size: [9, 4.6, 7] },
    ...doc.stage.targets
      .filter((t) => ids.has(t.id))
      .map((t) => ({ id: t.id, center: add(t.position, [0, 3, 0]), size: [5.6, 6, 5.6] })),
  ];
}
