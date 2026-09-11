/** A deliberately small literal-only subset: browser loading never executes project code. */
const begin = '// kagura-scene:begin';
const end = '// kagura-scene:end';
function region(source) {
  if (typeof source !== 'string') throw Error('Expected MoonBit source');
  const starts = [...source.matchAll(/^\/\/ kagura-scene:begin[ \t]*\r?$/gm)];
  const stops = [...source.matchAll(/^\/\/ kagura-scene:end[ \t]*\r?$/gm)];
  if (starts.length !== 1 || stops.length !== 1)
    throw Error('Expected exactly one managed MoonBit scene region');
  const start = starts[0].index,
    stop = stops[0].index;
  if (stop < start) throw Error('Invalid managed scene region');
  const body = source.slice(start + begin.length, stop).trim();
  const match =
    /^(?:\/\/[^\n]*\n)*pub fn ([a-z][a-z0-9_]*)\(\) -> @scene_document\.Document\s*\{([\s\S]*)\}$/.exec(
      body,
    );
  if (!match)
    throw Error('Expected a managed scene declaration returning @scene_document.Document');
  return { start, stop: stop + end.length, name: match[1], expression: match[2] };
}
function literal(expression) {
  let offset = 0;
  function skip() {
    while (true) {
      const token = /^(?:\s+|\/\/[^\n]*(?:\n|$))/.exec(expression.slice(offset));
      if (!token) return;
      offset += token[0].length;
    }
  }
  function take(text) {
    skip();
    if (!expression.startsWith(text, offset)) return false;
    offset += text.length;
    return true;
  }
  function string() {
    skip();
    const token = /^"(?:[^"\\\x00-\x1f]|\\(?:u\{[0-9a-fA-F]{1,6}\}|["\\nrtbf]))*"/.exec(
      expression.slice(offset),
    );
    if (!token) throw Error('Invalid MoonBit string literal');
    offset += token[0].length;
    return JSON.parse(
      token[0].replace(/\\(u\{([0-9a-fA-F]+)\}|["\\nrtbf])/g, (escape, _, hex) => {
        if (!hex) return escape;
        const cp = parseInt(hex, 16);
        if (cp > 0x10ffff || (cp >= 0xd800 && cp <= 0xdfff)) throw Error('Invalid Unicode scalar');
        return JSON.stringify(String.fromCodePoint(cp)).slice(1, -1);
      }),
    );
  }
  function value(depth = 0) {
    if (depth > 100) throw Error('Scene literal is too deeply nested');
    skip();
    if (expression[offset] === '"') return string();
    if (take('{')) {
      const object = {};
      while (!take('}')) {
        skip();
        let key;
        if (expression[offset] === '"') key = string();
        else {
          const token = /^[A-Za-z_][A-Za-z0-9_]*/.exec(expression.slice(offset));
          if (!token) throw Error('Expected a literal object key');
          key = token[0];
          offset += key.length;
        }
        if (Object.hasOwn(object, key)) throw Error('Duplicate literal key');
        if (!take(':')) throw Error('Expected literal field separator');
        Object.defineProperty(object, key, {
          value: value(depth + 1),
          enumerable: true,
          writable: true,
          configurable: true,
        });
        if (take('}')) return object;
        if (!take(',')) throw Error('Expected literal field separator');
      }
      return object;
    }
    if (take('[')) {
      const array = [];
      while (!take(']')) {
        array.push(value(depth + 1));
        if (take(']')) return array;
        if (!take(',')) throw Error('Expected literal array separator');
      }
      return array;
    }
    if (take('Json::null()')) return null;
    if (take('Json::empty_object()')) return {};
    if (take('true')) return true;
    if (take('false')) return false;
    skip();
    const number = /^-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?/.exec(expression.slice(offset));
    if (number) {
      offset += number[0].length;
      const result = Number(number[0]);
      if (!Number.isFinite(result)) throw Error('Nonfinite literal');
      return result;
    }
    throw Error('Only scene literals are editable; put logic outside the managed region');
  }
  const result = value();
  skip();
  if (offset !== expression.length) throw Error('Unexpected code after scene literal');
  return result;
}
export function decodeMoonScene(source) {
  return literal(region(source).expression);
}
function quote(value) {
  let output = '"';
  for (const char of value) {
    const cp = char.codePointAt(0);
    if (cp >= 0xd800 && cp <= 0xdfff) throw Error('Invalid Unicode scalar');
    if (cp < 32) output += '\\u{' + cp.toString(16) + '}';
    else output += char === '"' || char === '\\' ? '\\' + char : char;
  }
  return output + '"';
}
function encode(value, depth = 1, json = false) {
  if (depth > 100) throw Error('Scene literal is too deeply nested');
  if (value === null) return 'Json::null()';
  if (typeof value === 'string') return quote(value);
  if (typeof value === 'boolean') return String(value);
  if (typeof value === 'number' && Number.isFinite(value)) {
    const text = String(value).replace(/^(-?\d+)([eE])/, '$1.0$2');
    // JSON numbers are doubles; large integer-looking literals must not overflow MoonBit Int.
    return json && Number.isInteger(value) && Math.abs(value) > 2147483647 && !/[eE]/.test(text)
      ? text + '.0'
      : text;
  }
  if (Array.isArray(value))
    return '[' + value.map((v) => encode(v, depth + 1, json)).join(', ') + ']';
  if (value && typeof value === 'object') {
    const entries = Object.entries(value);
    if (!entries.length) return json ? 'Json::empty_object()' : '{}';
    return (
      '{\n' +
      entries
        .map(
          ([key, v]) =>
            '  '.repeat(depth + 1) +
            (!json && /^[a-zA-Z_][a-zA-Z0-9_]*$/.test(key) ? key : quote(key)) +
            ': ' +
            encode(v, depth + 1, json || key === 'data') +
            ',',
        )
        .join('\n') +
      '\n' +
      '  '.repeat(depth) +
      '}'
    );
  }
  throw Error('Expected a JSON-compatible scene value');
}
export function encodeMoonScene(document, { name = 'scene', source } = {}) {
  const previous = source === undefined ? undefined : region(source);
  if (previous) {
    decodeMoonScene(source);
    name = previous.name;
  }
  if (!/^[a-z][a-z0-9_]*$/.test(name)) throw Error('Invalid MoonBit scene function name');
  const block =
    begin +
    '\n///|\npub fn ' +
    name +
    '() -> @scene_document.Document {\n  ' +
    encode(document) +
    '\n}\n' +
    end;
  return previous
    ? source.slice(0, previous.start) + block + source.slice(previous.stop)
    : '// Edit scene literals here or in Kagura Studio. Keep behavior outside the managed region.\n' +
        block +
        '\n';
}
export function decodeSceneFile(path, source) {
  return path.endsWith('.mbt') ? decodeMoonScene(source) : JSON.parse(source);
}
