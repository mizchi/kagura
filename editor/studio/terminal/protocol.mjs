export const GESPENST_PROTOCOL = 'gespenst.v1';

export function encodePtyBytes(data) {
  if (Buffer.isBuffer(data)) return data;
  if (data instanceof Uint8Array) return Buffer.from(data.buffer, data.byteOffset, data.byteLength);
  if (typeof data === 'string') return Buffer.from(data, 'utf8');
  return Buffer.from(String(data), 'utf8');
}

export function isPtyControl(value) {
  return (
    value !== null &&
    typeof value === 'object' &&
    (value.type === 'hello' || value.type === 'resize' || value.type === 'exit' || value.type === 'error')
  );
}

export function readControl(data) {
  try {
    const value = JSON.parse(String(data));
    return isPtyControl(value) ? value : null;
  } catch {
    return null;
  }
}

export function selectGespenstProtocol(protocols) {
  if (typeof protocols?.has === 'function') return protocols.has(GESPENST_PROTOCOL) ? GESPENST_PROTOCOL : false;
  if (Array.isArray(protocols) && protocols.includes(GESPENST_PROTOCOL)) return GESPENST_PROTOCOL;
  return false;
}
