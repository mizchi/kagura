export class AgentError extends Error {
  constructor(code, detail = '') {
    super(detail ? `${code}: ${detail}` : code);
    this.name = 'AgentError';
    this.code = code;
  }
}

export function int32(value, name) {
  if (!Number.isInteger(value) || value < -2147483648 || value > 2147483647) {
    throw new AgentError('invalid_input', `${name} must be a signed 32-bit integer`);
  }
  return value;
}
