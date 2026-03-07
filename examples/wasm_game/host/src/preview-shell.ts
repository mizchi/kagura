type AbiMode = "semantic" | "legacy";
type HmrState = "booting" | "ready" | "reloading" | "error";

interface MetaState {
  title: string;
  abiMode: AbiMode;
  logicalWidth: number;
  logicalHeight: number;
  targetTps: number;
}

interface FrameState {
  fps: number;
  frame: number;
  commandCount: number;
  redraw: boolean;
}

interface ShellState {
  meta: MetaState;
  frame: FrameState;
  hmrState: HmrState;
  error: string | null;
  logs: string[];
}

export interface PreviewShell {
  setMeta(meta: Partial<MetaState>): void;
  setFrame(frame: Partial<FrameState>): void;
  setHmrState(hmrState: HmrState): void;
  setError(message: string | null): void;
  pushLog(message: string): void;
}

const defaultState: ShellState = {
  meta: {
    title: "Loading guest",
    abiMode: "legacy",
    logicalWidth: 0,
    logicalHeight: 0,
    targetTps: 0,
  },
  frame: {
    fps: 0,
    frame: 0,
    commandCount: 0,
    redraw: false,
  },
  hmrState: "booting",
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
      `redraw   ${state.frame.redraw ? "yes" : "no"}`,
    ].join("\n");
    logs.textContent = state.logs.length > 0 ? state.logs.join("\n") : "logs    (empty)";
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
  };
}
