/** 2D layout data uses pixels, a top-left origin and downward Y; it never overloads 3D transforms. */
export const scene2dId = 'kagura.scene2d';
function fields(value, keys) {
  if (
    !value ||
    typeof value !== 'object' ||
    Array.isArray(value) ||
    Object.keys(value).some((k) => !keys.includes(k))
  )
    throw Error('Invalid 2D scene fields');
}
export function validateScene2D(data) {
  fields(data, ['coordinates', 'width', 'height', 'background', 'objects']);
  if (data.coordinates !== 'pixels-y-down') throw Error('2D scenes use pixels-y-down');
  for (const n of [data.width, data.height])
    if (!Number.isInteger(n) || n < 1 || n > 8192) throw Error('Invalid 2D screen size');
  const color = (n) => {
    if (!Number.isInteger(n) || n < 0 || n > 0xffffff) throw Error('Invalid RGB color');
  };
  color(data.background);
  if (!Array.isArray(data.objects) || data.objects.length > 512) throw Error('Invalid 2D objects');
  const ids = new Set();
  for (const o of data.objects) {
    fields(o, ['id', 'name', 'kind', 'x', 'y', 'width', 'height', 'color']);
    if (typeof o.id !== 'string' || !/^[a-z][a-z0-9_.-]{0,79}$/.test(o.id) || ids.has(o.id))
      throw Error('Invalid or duplicate 2D object ID');
    ids.add(o.id);
    if (
      typeof o.name !== 'string' ||
      !o.name.trim() ||
      o.name.length > 120 ||
      typeof o.kind !== 'string' ||
      !/^[a-z][a-z0-9_.-]{0,79}$/.test(o.kind)
    )
      throw Error('Invalid 2D object name/kind');
    for (const n of [o.x, o.y, o.width, o.height])
      if (!Number.isFinite(n) || Math.abs(n) > 1000000) throw Error('Invalid 2D transform');
    if (o.width <= 0 || o.height <= 0) throw Error('2D size must be positive');
    color(o.color);
  }
  return structuredClone(data);
}
export function readScene2D(document) {
  const resource = document.resources.find((r) => r.id === scene2dId);
  if (!resource) return undefined;
  if (resource.kind !== scene2dId || resource.version !== 1)
    throw Error('Unsupported 2D scene version');
  return validateScene2D(resource.data);
}
export function compileScene2D(document, profile) {
  const data = readScene2D(document);
  if (!data) throw Error('Missing 2D scene');
  profile.validate(data);
  return { apiVersion: 1, game: profile.game, data };
}
export function editObject(document, id, changes, profile) {
  fields(changes, ['x', 'y', 'width', 'height', 'color', 'name']);
  if (!Object.keys(changes).length) throw Error('Empty 2D edit');
  const data = readScene2D(document);
  const index = data?.objects.findIndex((o) => o.id === id) ?? -1;
  if (index < 0) throw Error('Unknown 2D object');
  const object = data.objects[index];
  const allowed = profile.fields[object.kind];
  if (!allowed || Object.keys(changes).some((k) => !allowed.includes(k)))
    throw Error('This component does not support those fields');
  data.objects[index] = { ...object, ...profile.edit(object, changes, data) };
  validateScene2D(data);
  profile.validate(data);
  return [{ op: 'resource.put', resource: { id: scene2dId, kind: scene2dId, version: 1, data } }];
}
export function screenPoint(x, y, rect, camera) {
  return {
    x: (x - rect.left - camera.x) / camera.zoom,
    y: (y - rect.top - camera.y) / camera.zoom,
  };
}
export function resizedObject(object, point, snap = 1) {
  return {
    width: Math.max(snap, Math.round((point.x - object.x) / snap) * snap),
    height: Math.max(snap, Math.round((point.y - object.y) / snap) * snap),
  };
}
