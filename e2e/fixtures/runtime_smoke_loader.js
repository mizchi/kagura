const statusElement = document.getElementById("status");
const outputElement = document.getElementById("output");
const wasmPath = document.documentElement.getAttribute("data-wasm-path");

const setStatus = (status) => {
  if (statusElement == null) {
    return;
  }
  statusElement.textContent = status;
  statusElement.dataset.state = status;
};

const setOutput = (output) => {
  if (outputElement == null) {
    return;
  }
  outputElement.textContent = output;
};

const run = async () => {
  if (wasmPath == null || wasmPath.length === 0) {
    throw new Error("data-wasm-path is required");
  }
  let output = "";
  const imports = {
    spectest: {
      print_char: (charCode) => {
        output += String.fromCharCode(Number(charCode));
        setOutput(output);
      },
    },
  };
  const response = await fetch(wasmPath);
  if (!response.ok) {
    throw new Error(`failed to fetch wasm: ${response.status}`);
  }
  let instance;
  try {
    ({ instance } = await WebAssembly.instantiateStreaming(response, imports));
  } catch (_) {
    const bytes = await response.arrayBuffer();
    ({ instance } = await WebAssembly.instantiate(bytes, imports));
  }
  const start = instance.exports._start;
  if (typeof start !== "function") {
    throw new Error("wasm export _start not found");
  }
  start();
  setStatus("ok");
  window.__wasmSmoke = { status: "ok", output };
};

const boot = async () => {
  setStatus("running");
  try {
    await run();
  } catch (error) {
    const message = error instanceof Error ? error.stack ?? error.message : String(error);
    setStatus("failed");
    setOutput(message);
    window.__wasmSmoke = { status: "failed", output: message };
  }
};

void boot();
