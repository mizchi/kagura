import { check, decodeJSON, encodeJSON, MAX_MESSAGE_BYTES } from './contract.mjs';

/** JS and MoonBit/JS share exactly the same JSON transport boundary. */
export function defineJSPlugin({ manifest, invoke, mount, dispose }) {
  check(typeof invoke === 'function', 'Expected plugin invoke function');
  const description = decodeJSON(encodeJSON(manifest));
  return {
    manifest: description, mount,
    transport: {
      async invoke(source, options) { return encodeJSON(await invoke(decodeJSON(source), options)); },
      dispose,
    },
  };
}
export function fromJSONModule(module, { mount } = {}) {
  check(typeof module.manifest === 'function' && typeof module.invoke === 'function', 'Expected manifest() and invoke(json) exports');
  check(module.dispose === undefined || typeof module.dispose === 'function', 'Invalid module dispose');
  return { manifest: decodeJSON(module.manifest()), mount, transport: { invoke: module.invoke.bind(module), dispose: module.dispose?.bind(module) } };
}

/** Linear-memory wasm32 ABI. No imports, DOM handles, language heap objects or WASI required. */
export async function fromWasm(bytesOrModule, { mount } = {}) {
  const loaded = await WebAssembly.instantiate(bytesOrModule, {});
  let instance = loaded instanceof WebAssembly.Instance ? loaded : loaded.instance;
  let disposed = false;
  const decoder = new TextDecoder('utf-8', { fatal: true }), encoder = new TextEncoder();
  function exports() { check(!disposed, 'Wasm plugin disposed', 'canceled'); return instance.exports; }
  const required = ['kagura_alloc', 'kagura_free', 'kagura_manifest', 'kagura_invoke', 'kagura_result_len'];
  check(instance.exports.memory instanceof WebAssembly.Memory && required.every(name => typeof instance.exports[name] === 'function'), 'Invalid Kagura wasm32 ABI exports');
  function range(pointer, length) {
    const ptr = pointer >>> 0, size = length >>> 0;
    check(Number.isInteger(pointer) && Number.isInteger(length) && size <= MAX_MESSAGE_BYTES && ptr + size <= exports().memory.buffer.byteLength, 'Wasm buffer out of bounds');
    return new Uint8Array(exports().memory.buffer, ptr, size);
  }
  function call(source) {
    const api = exports(); let input, inputPtr, outputPtr, outputLength;
    let inputValid = false, outputValid = false;
    try {
      if (source !== undefined) {
        input = encoder.encode(source); check(input.length <= MAX_MESSAGE_BYTES, 'Plugin message exceeds 4 MiB');
        inputPtr = api.kagura_alloc(input.length);
        range(inputPtr, input.length).set(input);
        inputValid = true;
      }
      outputPtr = input === undefined ? api.kagura_manifest() : api.kagura_invoke(inputPtr, input.length);
      outputLength = api.kagura_result_len();
      // Reacquire memory after every guest call: memory.grow can detach previous views.
      const output = range(outputPtr, outputLength);
      if (inputValid) check((outputPtr >>> 0) + (outputLength >>> 0) <= (inputPtr >>> 0) ||
        (inputPtr >>> 0) + input.length <= (outputPtr >>> 0), 'Wasm input and result buffers overlap');
      outputValid = true;
      return decoder.decode(output);
    } finally {
      try { if (outputValid) api.kagura_free(outputPtr, outputLength); }
      finally { if (inputValid) api.kagura_free(inputPtr, input.length); }
    }
  }
  return { manifest: decodeJSON(call()), mount, transport: {
    invoke: source => call(source),
    dispose() { disposed = true; instance = null; },
  } };
}
