// Minimal JavaScript host for a MoonBit `wasm` (wasm1) guest that links
// `moonbitlang/async`.
//
// Why this is not just an empty import object: async's wasm1 backend is a
// clone of its native backend, so it asks the host for a POSIX-shaped world --
// 48 imports covering an epoll-style event bus, a thread pool, file
// descriptors, errno, signals and os strings. Almost all of them are only
// reached by socket/file/process work, which a browser or Node host has no
// business emulating. Timers, though, need just seven of them to be real:
//
//   time/get_ms_since_epoch   the loop's clock; timers are compared against it
//   event_bus/create          any non-zero handle
//   event_bus/wait            return 0 ("no I/O events"); the loop then runs
//                             due timers itself
//   fd_util/invalid_fd        -1, the usual sentinel
//   runtime/get_platform      0 (unix)
//   thread_pool/cancel_worker 2, i.e. NoWait -- 0 means "retry later" and
//                             hangs shutdown forever on the sigwait worker
//   os_error/get_errno        0, so the cancel path does not raise
//
// Everything else is a correctly-typed zero, derived from the module's own
// import signatures so an ABI change surfaces as a wrong-value bug rather than
// a LinkError.
//
// Known limits, before you reach for this in a browser:
//   - wasm1 only. On wasm-gc `moonbitlang/async` has no `run_async_main`.
//   - `_start` does not return until the guest's whole async main finishes,
//     and the event loop blocks inside it. On a browser main thread that
//     freezes the page, so the guest belongs in a Web Worker.
//   - Because the guest holds the thread, the host cannot call into it during
//     the run. A `requestAnimationFrame`-driven engine loop and this async
//     loop cannot share one thread.

const ASYNC = "moonbitlang/async";

const VALUE_TYPES = {
  0x7f: "i32",
  0x7e: "i64",
  0x7d: "f32",
  0x7c: "f64",
  0x7b: "v128",
  0x70: "funcref",
  0x6f: "externref",
};

/**
 * Read the type and import sections so every stub can return a value of the
 * right type. `WebAssembly.Module.imports()` gives names but not signatures.
 */
function readImportSignatures(bytes) {
  let at = 8; // magic + version
  const u32 = () => {
    let result = 0;
    let shift = 0;
    let byte;
    do {
      byte = bytes[at++];
      result |= (byte & 0x7f) << shift;
      shift += 7;
    } while (byte & 0x80);
    return result >>> 0;
  };
  const name = () => {
    const length = u32();
    const text = Buffer.from(bytes.buffer, bytes.byteOffset + at, length).toString("utf8");
    at += length;
    return text;
  };

  const types = [];
  const imports = [];
  while (at < bytes.length) {
    const id = bytes[at++];
    // `u32()` advances `at`, so read the size before computing the end.
    const size = u32();
    const end = at + size;
    if (id === 1) {
      const count = u32();
      for (let i = 0; i < count; i++) {
        if (bytes[at++] !== 0x60) {
          // Not a plain function type (wasm-gc shapes); the rest of the
          // section is not something this host needs to understand. Keep the
          // index aligned so later function types still resolve.
          types.push({ params: [], results: [] });
          at = end;
          break;
        }
        const params = [];
        for (let k = u32(); k > 0; k--) params.push(VALUE_TYPES[bytes[at++]] ?? "?");
        const results = [];
        for (let k = u32(); k > 0; k--) results.push(VALUE_TYPES[bytes[at++]] ?? "?");
        types.push({ params, results });
      }
    } else if (id === 2) {
      const count = u32();
      for (let i = 0; i < count; i++) {
        const module = name();
        const field = name();
        const kind = bytes[at++];
        const typeIndex = u32();
        imports.push({ module, field, kind, signature: kind === 0 ? types[typeIndex] : null });
      }
    }
    at = end;
  }
  return imports;
}

const zeroOf = (results) => {
  if (results.length === 0) return undefined;
  return results[0] === "i64" ? 0n : 0;
};

/**
 * Sleep the calling thread for `ms`. `Atomics.wait` is allowed on Node's main
 * thread and inside a Worker, which is exactly where this host runs; without
 * it the event loop would busy-wait through every timer.
 */
function makeBlockingSleep() {
  let cell = null;
  try {
    cell = new Int32Array(new SharedArrayBuffer(4));
  } catch {
    return () => {}; // no SharedArrayBuffer (missing COOP/COEP): spin instead
  }
  return (ms) => {
    if (ms > 0) Atomics.wait(cell, 0, 0, ms);
  };
}

/**
 * Build the import object for `module`.
 *
 * @param {WebAssembly.Module} module
 * @param {Uint8Array} bytes the same module, for signature parsing
 * @param {object} options
 * @param {(text: string) => void} [options.write] receives guest stdout
 * @param {number} [options.maxWaitMs] cap on one `event_bus/wait`, so a guest
 *   asking to wait forever still yields to the host periodically
 * @returns {{imports: object, setMemory: (m: WebAssembly.Memory) => void, stats: object}}
 */
export function createAsyncWasmHost(module, bytes, options = {}) {
  const write = options.write ?? ((text) => process.stdout.write(text));
  const maxWaitMs = options.maxWaitMs ?? 50;
  const sleep = makeBlockingSleep();
  const stats = { waits: 0, sleptMs: 0 };

  let memory = null;
  const imports = {};
  for (const entry of readImportSignatures(bytes)) {
    if (entry.kind !== 0) continue;
    const results = entry.signature?.results ?? [];
    (imports[entry.module] ??= {})[entry.field] = () => zeroOf(results);
  }

  const async_ = imports[ASYNC];
  if (async_ != null) {
    async_["time/get_ms_since_epoch"] = () => BigInt(Date.now());
    async_["runtime/get_platform"] = () => 0;
    async_["event_bus/create"] = () => 1n;
    async_["fd_util/invalid_fd"] = () => -1n;
    async_["os_error/get_errno"] = () => 0;
    async_["thread_pool/cancel_worker"] = () => 2;
    async_["event_bus/wait"] = (_bus, timeout) => {
      stats.waits += 1;
      // A negative timeout means "block until something happens". Nothing in
      // this host ever will, so treat it as the cap.
      const ms = Math.min(timeout < 0 ? maxWaitMs : timeout, maxWaitMs);
      if (ms > 0) {
        sleep(ms);
        stats.sleptMs += ms;
      }
      return 0; // no I/O events; the loop goes on to run due timers
    };
  }

  // kagura's own host namespace, so an async guest and the engine's wasm frame
  // loop can be linked against the same host.
  imports.kagura_web = { ...(imports.kagura_web ?? {}), now_ms: () => Date.now() };

  const wasi = imports.wasi_snapshot_preview1;
  if (wasi != null) {
    wasi.fd_write = (_fd, iovs, iovsLen, nwritten) => {
      const view = new DataView(memory.buffer);
      let total = 0;
      let text = "";
      for (let i = 0; i < iovsLen; i++) {
        const ptr = view.getUint32(iovs + i * 8, true);
        const len = view.getUint32(iovs + i * 8 + 4, true);
        text += Buffer.from(memory.buffer, ptr, len).toString("utf8");
        total += len;
      }
      write(text);
      view.setUint32(nwritten, total, true);
      return 0;
    };
  }

  return { imports, setMemory: (m) => (memory = m), stats };
}

/**
 * Instantiate and run a guest to completion, collecting its stdout.
 *
 * @returns {{output: string, stats: object, instance: WebAssembly.Instance}}
 */
export function runAsyncWasm(bytes, options = {}) {
  const module = new WebAssembly.Module(bytes);
  const chunks = [];
  const host = createAsyncWasmHost(module, bytes, {
    ...options,
    write: (text) => chunks.push(text),
  });
  const instance = new WebAssembly.Instance(module, host.imports);
  host.setMemory(instance.exports.memory);
  instance.exports._start();
  return { output: chunks.join(""), stats: host.stats, instance };
}
