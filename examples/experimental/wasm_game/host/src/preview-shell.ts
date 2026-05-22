type HmrState = "booting" | "ready" | "reloading" | "error";

interface MetaState {
  title: string;
  abiMode: string;
  logicalWidth: number;
  logicalHeight: number;
  targetTps: number;
}

interface FrameState {
  fps: number;
  frame: number;
  commandCount: number;
  vertexCount: number;
  redraw: boolean;
}

interface AbiStats {
  updateMs: number;
  renderMs: number;
  serializeMs: number;
  deserializeMs: number;
  inputBytes: number;
  drawBytes: number;
}

interface ShellState {
  meta: MetaState;
  frame: FrameState;
  abi: AbiStats;
  hmrState: HmrState;
  paused: boolean;
  error: string | null;
  logs: string[];
}

export interface PreviewShell {
  setMeta(meta: Partial<MetaState>): void;
  setFrame(frame: Partial<FrameState>): void;
  setAbi(abi: Partial<AbiStats>): void;
  setHmrState(hmrState: HmrState): void;
  setError(message: string | null): void;
  pushLog(message: string): void;
  isPaused(): boolean;
  /** Returns true if a single step was requested (auto-clears). */
  consumeStep(): boolean;
}

const defaultState: ShellState = {
  meta: {
    title: "Loading guest",
    abiMode: "v0",
    logicalWidth: 0,
    logicalHeight: 0,
    targetTps: 0,
  },
  frame: {
    fps: 0,
    frame: 0,
    commandCount: 0,
    vertexCount: 0,
    redraw: false,
  },
  abi: {
    updateMs: 0,
    renderMs: 0,
    serializeMs: 0,
    deserializeMs: 0,
    inputBytes: 0,
    drawBytes: 0,
  },
  hmrState: "booting",
  paused: false,
  error: null,
  logs: [],
};

function formatHmrState(state: HmrState): string {
  switch (state) {
    case "booting":
      return "booting";
    case "ready":
      return "ready";
    case "reloading":
      return "reloading";
    case "error":
      return "error";
  }
}

export function createPreviewShell(canvas: HTMLCanvasElement): PreviewShell {
  const state: ShellState = structuredClone(defaultState);
  let stepRequested = false;

  const app = document.createElement("div");
  app.className = "preview-shell";

  const stage = document.createElement("div");
  stage.className = "preview-stage";

  const panel = document.createElement("aside");
  panel.className = "preview-panel";

  const title = document.createElement("div");
  title.className = "preview-title";
  panel.appendChild(title);

  const status = document.createElement("pre");
  status.className = "preview-status";
  panel.appendChild(status);

  // Controls
  const controls = document.createElement("div");
  controls.className = "preview-controls";
  const pauseBtn = document.createElement("button");
  pauseBtn.textContent = "Pause";
  pauseBtn.onclick = () => {
    state.paused = !state.paused;
    pauseBtn.textContent = state.paused ? "Resume" : "Pause";
    render();
  };
  const stepBtn = document.createElement("button");
  stepBtn.textContent = "Step";
  stepBtn.onclick = () => {
    if (state.paused) {
      stepRequested = true;
    }
  };
  controls.appendChild(pauseBtn);
  controls.appendChild(stepBtn);
  panel.appendChild(controls);

  const logs = document.createElement("pre");
  logs.className = "preview-logs";
  panel.appendChild(logs);

  const error = document.createElement("div");
  error.className = "preview-error";

  const parent = canvas.parentElement ?? document.body;
  app.appendChild(stage);
  app.appendChild(panel);
  app.appendChild(error);
  parent.replaceChildren(app);
  stage.appendChild(canvas);

  function render() {
    title.textContent = state.meta.title;
    status.textContent = [
      `abi      ${state.meta.abiMode}`,
      `hmr      ${formatHmrState(state.hmrState)}`,
      `logical  ${state.meta.logicalWidth}x${state.meta.logicalHeight}`,
      `target   ${state.meta.targetTps} tps`,
      `fps      ${state.frame.fps.toFixed(1)}`,
      `frame    ${state.frame.frame}`,
      `cmds     ${state.frame.commandCount}`,
      `verts    ${state.frame.vertexCount}`,
      `redraw   ${state.frame.redraw ? "yes" : "no"}`,
      `state    ${state.paused ? "PAUSED" : "running"}`,
      ``,
      `--- ABI boundary ---`,
      `update   ${state.abi.updateMs.toFixed(3)} ms`,
      `render   ${state.abi.renderMs.toFixed(3)} ms`,
      `ser/in   ${state.abi.serializeMs.toFixed(3)} ms (${state.abi.inputBytes} B)`,
      `deser    ${state.abi.deserializeMs.toFixed(3)} ms (${state.abi.drawBytes} B)`,
    ].join("\n");
    logs.textContent =
      state.logs.length > 0 ? state.logs.join("\n") : "logs    (empty)";
    error.textContent = state.error ?? "";
    error.hidden = state.error == null;
  }

  render();

  return {
    setMeta(meta) {
      state.meta = { ...state.meta, ...meta };
      render();
    },
    setFrame(frame) {
      state.frame = { ...state.frame, ...frame };
      render();
    },
    setAbi(abi) {
      state.abi = { ...state.abi, ...abi };
      render();
    },
    setHmrState(hmrState) {
      state.hmrState = hmrState;
      if (hmrState !== "error" && state.error?.startsWith("[HMR]")) {
        state.error = null;
      }
      render();
    },
    setError(message) {
      state.error = message;
      if (message) {
        state.hmrState = "error";
      }
      render();
    },
    pushLog(message) {
      state.logs = [...state.logs.slice(-7), message];
      render();
    },
    isPaused() {
      return state.paused;
    },
    consumeStep() {
      if (stepRequested) {
        stepRequested = false;
        return true;
      }
      return false;
    },
  };
}
