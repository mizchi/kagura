import { projectPath } from '../projects/project.mjs';

export function modelFormat(path) {
  return typeof path === 'string'
    ? (/\.(glb|gltf|obj)$/i.exec(path)?.[1].toLowerCase() ?? null)
    : null;
}

/** Resolve model-relative buffers through ProjectResources, never the browser network. */
export function dependencyPath(model, uri) {
  projectPath(model);
  if (typeof uri !== 'string' || !uri || uri.startsWith('/') || /[\\:%?#\x00-\x1f]/.test(uri))
    throw Error('Invalid model dependency URI');
  const parts = model.split('/').slice(0, -1);
  for (const part of uri.split('/')) {
    if (part === '.') continue;
    if (part === '..') {
      if (!parts.length) throw Error('Model dependency escapes project root');
      parts.pop();
    } else {
      if (!part) throw Error('Invalid model dependency URI');
      parts.push(part);
    }
  }
  return projectPath(parts.join('/'));
}

function unpackGLB(bytes) {
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  if (
    bytes.length < 20 ||
    view.getUint32(0, true) !== 0x46546c67 ||
    view.getUint32(4, true) !== 2 ||
    view.getUint32(8, true) !== bytes.length
  )
    throw Error('Invalid GLB header/version/length');
  let json, binary;
  for (let offset = 12; offset < bytes.length; ) {
    if (offset + 8 > bytes.length) throw Error('Truncated GLB chunk');
    const size = view.getUint32(offset, true),
      type = view.getUint32(offset + 4, true);
    if (size % 4 || offset + 8 + size > bytes.length) throw Error('Invalid GLB chunk length');
    const chunk = bytes.subarray(offset + 8, offset + 8 + size);
    if (offset === 12 && type !== 0x4e4f534a) throw Error('GLB must start with JSON');
    if (type === 0x4e4f534a) {
      if (json !== undefined) throw Error('Duplicate GLB JSON');
      json = new TextDecoder().decode(chunk);
    } else if (type === 0x004e4942) {
      if (binary) throw Error('Duplicate GLB binary buffer');
      binary = chunk;
    }
    offset += 8 + size;
  }
  return { json, binary };
}

function validateGraph(doc) {
  const nodes = doc.nodes ?? [];
  if (!Array.isArray(nodes) || nodes.length > 10000) throw Error('Invalid glTF node count');
  const parents = new Set(),
    visiting = new Set(),
    heights = new Map();
  for (const node of nodes) {
    if (!node || !Array.isArray(node.children ?? [])) throw Error('Invalid glTF node');
    for (const id of node.children ?? []) {
      if (parents.has(id)) throw Error('glTF node has multiple parents');
      parents.add(id);
    }
  }
  function visit(id) {
    if (!Number.isInteger(id) || !nodes[id]) throw Error('Invalid glTF node reference');
    if (visiting.has(id)) throw Error('glTF hierarchy contains a cycle');
    if (heights.has(id)) return heights.get(id);
    if (visiting.size >= 128) throw Error('glTF hierarchy exceeds 128 levels');
    visiting.add(id);
    let height = 1;
    for (const child of nodes[id].children ?? []) height = Math.max(height, 1 + visit(child));
    if (height > 128) throw Error('glTF hierarchy exceeds 128 levels');
    visiting.delete(id);
    heights.set(id, height);
    return height;
  }
  nodes.forEach((_, id) => visit(id));
}

/** Headless preparation; no DOM, GPU, object URLs or writes. 64 MiB total input budget. */
export async function prepareModel(resources, path) {
  projectPath(path);
  const format = modelFormat(path);
  if (!format) throw Error('Supported models: .glb, .gltf, .obj');
  let total = 0;
  async function read(key) {
    const blob = await resources.read(key);
    total += blob.size;
    if (total > 64 * 1024 * 1024) throw Error('Model exceeds 64 MiB');
    return new Uint8Array(await blob.arrayBuffer());
  }
  const bytes = await read(path);
  if (format === 'obj')
    return {
      format,
      text: new TextDecoder().decode(bytes),
      json: '',
      buffers: [],
      warnings: ['OBJ: geometry only; MTL materials are not loaded.'],
    };
  const { json, binary } =
    format === 'glb' ? unpackGLB(bytes) : { json: new TextDecoder().decode(bytes) };
  const doc = JSON.parse(json);
  if (doc.asset?.version !== '2.0') throw Error('Unsupported glTF version');
  if (doc.extensionsRequired?.length)
    throw Error('Unsupported required glTF extensions: ' + doc.extensionsRequired.join(', '));
  validateGraph(doc);
  if (!Array.isArray(doc.buffers ?? []) || (doc.buffers?.length ?? 0) > 256)
    throw Error('Invalid glTF buffers');
  const buffers = [];
  for (const [index, buffer] of (doc.buffers ?? []).entries()) {
    let data;
    if (buffer.uri === undefined) data = index === 0 ? binary : undefined;
    else if (typeof buffer.uri === 'string' && buffer.uri.startsWith('data:')) {
      const match =
        /^data:application\/(?:octet-stream|gltf-buffer);base64,([A-Za-z0-9+/]*={0,2})$/.exec(
          buffer.uri,
        );
      if (!match) throw Error('Invalid embedded glTF buffer');
      data = Uint8Array.from(atob(match[1]), (c) => c.charCodeAt(0));
      total += data.length;
      if (total > 64 * 1024 * 1024) throw Error('Model exceeds 64 MiB');
    } else data = await read(dependencyPath(path, buffer.uri));
    if (
      !data ||
      !Number.isInteger(buffer.byteLength) ||
      buffer.byteLength < 0 ||
      data.length < buffer.byteLength
    )
      throw Error('Missing or truncated glTF buffer ' + index);
    buffers.push(data);
  }
  const warnings = [];
  if (doc.images?.length)
    warnings.push('Kagura glTF loader: image textures are not loaded; base color only.');
  if (doc.animations?.length || doc.skins?.length)
    warnings.push('Static pose preview; animation and skin playback are not enabled.');
  if (doc.nodes?.some((n) => n.matrix))
    warnings.push('Kagura glTF loader: matrix transforms are not supported; use TRS transforms.');
  if (doc.meshes?.some((m) => m.primitives?.length > 1))
    warnings.push('Kagura glTF loader: multiple primitives use the first material.');
  return { format: 'gltf', json, text: '', buffers, warnings };
}
