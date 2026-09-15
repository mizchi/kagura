import { createModelEditor, kawaiikoDocument } from "./model.mjs";
import { createExpressionPanel } from "./expressions-pane.mjs";
import { createModelViewport } from "./viewer.mjs";
import { exportModelGLB } from "./geometry.mjs";
import { createIndexedDBStore } from "../storage/indexeddb.mjs";
import { downloadBlob } from "../web/storage.mjs";
import "./style.css";

const ID = "studio.modeling",
  SOURCE = "https://github.com/chibivue-land/art";
const element = (tag, cls, text) => {
  const node = document.createElement(tag);
  if (cls) node.className = cls;
  if (text) node.textContent = text;
  return node;
};
function button(text, label, action) {
  const b = element("button", "", text);
  b.type = "button";
  b.setAttribute("aria-label", label);
  b.addEventListener("click", action);
  return b;
}

export function installModeling({
  panes,
  workspace,
  viewport,
  host,
  setStatus,
  restoreDraft = true,
}) {
  const editor = createModelEditor(),
    store = createIndexedDBStore({ name: "kagura.studio.modeling.v1" });
  let mounted,
    savedRevision = -1,
    etag = null,
    touched = false,
    disposed = false;
  let project = host.project(),
    sceneId = host.sceneId();
  const report = (error) => {
    setStatus("Modeling · " + error.message);
    if (mounted) mounted.message.textContent = error.message;
  };
  const send = (command) => {
    touched = true;
    try {
      return editor.request(command);
    } catch (error) {
      report(error);
      return null;
    }
  };
  const ready = store
    .read("draft.kgrmodel")
    .then(async (entry) => {
      // A preset link starts from the built-in document. Read only the etag so
      // a later explicit Save still has normal optimistic-write semantics.
      etag = entry.etag;
      if (!restoreDraft) return;
      const doc = JSON.parse(await entry.blob.text());
      if (disposed || touched) return;
      const state = editor.request({ op: "replace", document: doc });
      savedRevision = state.revision;
      mounted?.sync(state);
    })
    .catch((error) => {
      if (error.code !== "not_found") report(error);
    });
  async function save() {
    await ready;
    const state = editor.snapshot();
    if (state.expressionEdit)
      throw Error("表情の差分を確定または取り消してください");
    if (state.modal) throw Error("変形を確定してから保存してください");
    const result = await store.write(
      "draft.kgrmodel",
      new Blob([JSON.stringify(state.document)], { type: "application/json" }),
      { ifMatch: etag },
    );
    etag = result.etag;
    savedRevision = state.revision;
    mounted?.sync(editor.snapshot());
    setStatus("Saved · Modeling / " + state.document.name);
  }
  function exportJSON() {
    const state = editor.snapshot();
    if (state.expressionEdit)
      throw Error("表情の差分を確定または取り消してください");
    if (state.modal) throw Error("変形を確定してから書き出してください");
    downloadBlob(
      new Blob([JSON.stringify(state.document, null, 2)], {
        type: "application/json",
      }),
      state.document.name + ".kgrmodel",
    );
  }
  async function exportGLB() {
    const state = editor.snapshot();
    if (state.expressionEdit)
      throw Error("表情の差分を確定または取り消してください");
    if (state.modal) throw Error("変形を確定してから書き出してください");
    const bytes = await exportModelGLB(state.document);
    downloadBlob(
      new Blob([bytes], { type: "model/gltf-binary" }),
      state.document.name + ".glb",
    );
    setStatus("Exported · " + state.document.name + ".glb");
  }
  const openButton = button("Modeling", "Open 3D modeling", () =>
    panes.open(ID),
  );
  document.querySelector(".layout-switch").append(openButton);
  panes.register({
    id: ID,
    title: "Modeling",
    workspace: true,
    mount({ element: tools, signal }) {
      const releaseViewport = viewport?.suspendRendering();
      const overlay = element("section", "modeling-overlay");
      overlay.setAttribute("aria-label", "3D modeling workspace");
      const toolbar = element("div", "modeling-toolbar"),
        stage = element("div", "modeling-stage");
      const status = element("div", "modeling-status"),
        message = element("span", "modeling-message");
      message.setAttribute("role", "status");
      const cameraLabel = element(
        "span",
        "modeling-camera",
        "Perspective · Y up",
      );
      const caption = element("div", "modeling-caption");
      caption.append(
        element("small", "", "MESH WORKSPACE"),
        element("strong", "", "kawaiiko"),
        element("span", "", "chibivue-land / character study"),
      );
      const mode = document.createElement("select");
      mode.setAttribute("aria-label", "Modeling mode");
      mode.append(
        new Option("Object Mode", "object"),
        new Option("Edit · Vertices", "vertex"),
        new Option("Edit · Faces", "face"),
      );
      mode.addEventListener("change", () => {
        send({ op: "mode", value: mode.value });
        viewer.canvas.focus();
      });
      const undo = button("↶", "Undo model", () => send({ op: "undo" })),
        redo = button("↷", "Redo model", () => send({ op: "redo" }));
      toolbar.append(
        mode,
        undo,
        redo,
        button("正面", "Model front view", () => viewer.view("front")),
        button("右", "Model side view", () => viewer.view("side")),
        button("上", "Model top view", () => viewer.view("top")),
        button("背面", "Model back view", () => viewer.view("back")),
        button("透視", "Model perspective view", () =>
          viewer.view("perspective"),
        ),
        button("閉じる", "Close modeling", () => panes.close(ID)),
      );
      status.append(message, cameraLabel);
      overlay.append(toolbar, stage, status);
      stage.append(caption);
      workspace.slot("viewport").host.append(overlay);
      const workspaceInfo = element("span", "modeling-workspace-info");
      document.querySelector(".workspace-bar").append(workspaceInfo);
      const topActions = element("div", "modeling-top-actions");
      topActions.append(
        button("Save model", "Save model", () => save().catch(report)),
        button("JSON ↓", "Export model JSON", () => {
          try {
            exportJSON();
          } catch (e) {
            report(e);
          }
        }),
        button("GLB ↓", "Export model GLB", () => exportGLB().catch(report)),
      );
      document.querySelector(".toolbar").append(topActions);
      const slots = [];
      function adopt(id, title) {
        const view = workspace.slot(id).adopt({
          id: ID,
          title,
          mount: ({ element: e }) => e.classList.add("modeling-pane"),
        });
        slots.push(id);
        return view;
      }
      const hierarchy = adopt("hierarchy", "Model objects");
      hierarchy.append(element("h2", "", "アウトライナー"));
      const count = element("p", "modeling-muted"),
        tree = element("div", "modeling-tree");
      tree.setAttribute("role", "list");
      hierarchy.append(count, tree);
      const resources = adopt("resources", "Model primitives");
      resources.append(element("h2", "", "形状を追加"));
      const additions = element("div", "modeling-actions");
      additions.append(
        button("□  Cube", "Add model cube", () => {
          send({ op: "add", kind: "cube" });
          viewer.canvas.focus();
        }),
        button("◉  Sphere", "Add model sphere", () => {
          send({ op: "add", kind: "sphere" });
          viewer.canvas.focus();
        }),
      );
      resources.append(additions);
      const reference = document.createElement("a");
      reference.href = SOURCE;
      reference.target = "_blank";
      reference.rel = "noreferrer";
      reference.textContent = "kawaiko の原画 ↗";
      const image = document.createElement("img");
      image.src =
        "https://raw.githubusercontent.com/chibivue-land/art/main/kawaiko.png";
      image.alt = "chibivue-land の kawaiko 原画";
      image.className = "modeling-reference";
      image.loading = "lazy";
      resources.append(
        image,
        reference,
        element(
          "p",
          "modeling-muted",
          "原画を参考に作った立体モデル。各パーツは頂点・面を直接編集できます。",
        ),
      );
      const inspector = adopt("inspector", "Model properties");
      inspector.append(element("h2", "", "オブジェクト"));
      const name = document.createElement("input");
      name.setAttribute("aria-label", "Model object name");
      name.addEventListener("change", () =>
        send({ op: "rename", name: name.value }),
      );
      const color = document.createElement("input");
      color.type = "color";
      color.setAttribute("aria-label", "Model object color");
      color.addEventListener("change", () =>
        send({ op: "material", color: parseInt(color.value.slice(1), 16) }),
      );
      const information = element("p", "modeling-muted");
      inspector.append(name, color, information);
      const transforms = element("div", "modeling-actions");
      for (const [text, kind, key] of [
        ["移動", "move", "G"],
        ["回転", "rotate", "R"],
        ["拡縮", "scale", "S"],
        ["押出", "extrude", "E"],
      ])
        transforms.append(
          button(`${text}  ${key}`, "Model " + kind, () => begin(kind)),
        );
      inspector.append(
        transforms,
        button("複製  Shift D", "Duplicate model object", () =>
          send({ op: "duplicate" }),
        ),
        button("X 反転", "Mirror model object", () => {
          if (send({ op: "begin", kind: "scale" })) {
            send({ op: "preview", value: [-1, 1, 1] });
            send({ op: "confirm" });
          }
        }),
        button("削除  X", "Delete model selection", () =>
          send({ op: "remove" }),
        ),
      );
      const wire = document.createElement("input");
      wire.type = "checkbox";
      wire.setAttribute("aria-label", "Model wireframe");
      wire.addEventListener("change", () => viewer.wire(wire.checked));
      const wireLabel = element("label", "modeling-check", "ワイヤーフレーム");
      wireLabel.prepend(wire);
      inspector.append(wireLabel);
      const timeline = adopt("timeline", "Facial expressions");
      const expressions = createExpressionPanel({
        container: timeline,
        element,
        button,
        send,
        snapshot: () => editor.snapshot(),
        focusFace: () => {
          const ids = [
            ...new Set(
              editor
                .snapshot()
                .document.expressions.flatMap((e) =>
                  e.targets.map((t) => t.node),
                ),
            ),
          ];
          viewer.view("front");
          viewer.frame(ids.length ? ids : undefined);
        },
      });
      tools.append(
        element("h2", "", "Modeling"),
        element(
          "p",
          "modeling-muted",
          "左クリックで部品を選択。Tab でメッシュを編集します。Shift + クリックで頂点を追加選択できます。",
        ),
        element(
          "p",
          "modeling-muted",
          "Save model はブラウザに保存。JSON は再編集用、GLB はゲームや他のエディタへ渡す形式です。",
        ),
      );
      const file = document.createElement("input");
      file.type = "file";
      file.accept = ".kgrmodel,.json";
      file.setAttribute("aria-label", "Import model JSON");
      file.addEventListener("change", async () => {
        try {
          const f = file.files[0];
          if (!f) return;
          if (f.size > 8 * 1024 * 1024) throw Error("Model exceeds 8 MiB");
          send({ op: "replace", document: JSON.parse(await f.text()) });
        } catch (e) {
          report(e);
        } finally {
          file.value = "";
        }
      });
      tools.append(
        file,
        button("kawaiiko を読み直す", "Reset kawaiiko model", () =>
          send({ op: "replace", document: kawaiikoDocument() }),
        ),
        element(
          "p",
          "modeling-muted",
          "操作は物理キー位置で判定。単位: m / 回転の数値: 度。Y が上方向です。",
        ),
      );
      let modal = null,
        lastPointer = null,
        lastOutline = "",
        lastInspector = "",
        sceneRevision = -1;
      const viewer = createModelViewport(stage, {
        select: (id) => send({ op: "select", id }),
        vertex: (i, add) => {
          const state = editor.snapshot();
          send({
            op: "vertices",
            indices: add
              ? state.vertices.includes(i)
                ? state.vertices.filter((v) => v !== i)
                : [...state.vertices, i]
              : [i],
          });
        },
        face: (index) => send({ op: "face", index }),
        pointerDown: (e) => {
          if (!modal) return false;
          if (e.button === 0) finish(true);
          else if (e.button === 2) finish(false);
          return true;
        },
        pointerMove: (e) => {
          lastPointer = { x: e.clientX, y: e.clientY };
          if (modal) {
            modal.dx = e.clientX - modal.start.x;
            modal.dy = e.clientY - modal.start.y;
            applyPreview();
          }
        },
        onCamera: () => {
          const stats = mounted?.viewer.stats();
          if (stats)
            cameraLabel.textContent =
              (stats.camera === "orthographic"
                ? "Orthographic"
                : "Perspective") + " · Y up";
        },
      });
      function sync(state) {
        viewer.update({
          ...state,
          document: { ...state.document, nodes: state.previewNodes },
        });
        expressions.sync(state);
        caption.querySelector("strong").textContent = state.document.name;
        caption.querySelector("span").textContent =
          state.document.source.includes("chibivue-land/art")
            ? "chibivue-land / character study"
            : "Mesh authoring";
        mode.value = state.mode;
        mode.disabled = !!state.modal;
        undo.disabled =
          !state.canUndo || !!state.modal || !!state.expressionEdit;
        redo.disabled =
          !state.canRedo || !!state.modal || !!state.expressionEdit;
        const n = state.document.nodes.find((n) => n.id === state.selected);
        const signature = JSON.stringify([
          state.document.nodes.map((n) => [n.id, n.name, n.color]),
          state.selected,
        ]);
        if (signature !== lastOutline) {
          lastOutline = signature;
          tree.replaceChildren(
            ...state.document.nodes.map((n) => {
              const b = button(n.name, "Select model " + n.id, () => {
                send({ op: "select", id: n.id });
                viewer.canvas.focus();
              });
              b.setAttribute("aria-pressed", String(n.id === state.selected));
              b.style.setProperty(
                "--part-color",
                "#" + n.color.toString(16).padStart(6, "0"),
              );
              return b;
            }),
          );
        }
        const vertexCount = state.document.nodes.reduce(
            (sum, n) => sum + n.vertices.length,
            0,
          ),
          faceCount = state.document.nodes.reduce(
            (sum, n) => sum + n.faces.length,
            0,
          );
        count.textContent = `${state.document.nodes.length} objects · ${vertexCount.toLocaleString()} vertices`;
        workspaceInfo.textContent = `${state.document.nodes.length} meshes · Y up · meters · REV ${state.revision}`;
        const signatureInspector = JSON.stringify([n?.id, n?.name, n?.color]);
        if (signatureInspector !== lastInspector) {
          lastInspector = signatureInspector;
          name.value = n?.name ?? "";
          name.disabled = !n;
          color.disabled = !n;
          color.value = "#" + (n?.color ?? 0).toString(16).padStart(6, "0");
        }
        const previewing = Object.values(state.weights).some(
          (weight) => weight > 0,
        );
        for (const b of transforms.querySelectorAll("button")) {
          b.disabled =
            !!state.modal ||
            previewing ||
            (b.getAttribute("aria-label") === "Model extrude" &&
              !!state.expressionEdit);
        }
        information.textContent = n
          ? `${n.vertices.length} vertices · ${n.faces.length} faces · ${state.vertices.length} selected`
          : "オブジェクトを選択";
        if (!state.modal)
          message.textContent = `${state.revision === savedRevision ? "Saved" : "Unsaved"}${state.expressionEdit ? " · Expression draft" : previewing ? " · Expression preview" : ""} · ${faceCount.toLocaleString()} polygons · ${state.mode === "object" ? "Object Mode" : state.mode === "vertex" ? "Edit / Vertices" : "Edit / Faces"}`;
        if (state.revision !== sceneRevision) {
          sceneRevision = state.revision;
          overlay.dataset.revision = String(state.revision);
        }
      }
      function begin(kind) {
        const state = send({ op: "begin", kind });
        if (!state) return;
        const bounds = viewer.canvas.getBoundingClientRect();
        modal = {
          kind,
          axis: null,
          typed: "",
          dx: 0,
          dy: 0,
          start: lastPointer ?? {
            x: bounds.x + bounds.width / 2,
            y: bounds.y + bounds.height / 2,
          },
          normal: state.modal.normal,
        };
        viewer.canvas.focus();
        applyPreview();
      }
      function finish(confirm) {
        if (confirm && modal?.valid === false) return;
        send({ op: confirm ? "confirm" : "cancel" });
        modal = null;
        viewer.axis(null);
      }
      function applyPreview() {
        if (!modal) return;
        const { kind, axis, typed, dx, dy } = modal;
        const numeric =
          typed !== "" && typed !== "-" && typed !== "." && typed !== "-."
            ? Number(typed)
            : null;
        if (numeric !== null && !Number.isFinite(numeric)) return;
        let value;
        if (kind === "move") {
          value = viewer.delta(dx, dy);
          if (numeric !== null) {
            value = [0, 0, 0];
            value[{ x: 0, y: 1, z: 2 }[axis ?? "x"]] = numeric;
          } else if (axis)
            value = value.map((v, i) =>
              i === { x: 0, y: 1, z: 2 }[axis] ? v : 0,
            );
        } else if (kind === "extrude") {
          const amount = numeric ?? (dx - dy) * 0.008;
          value = axis ? [0, 0, 0] : modal.normal.map((v) => v * amount);
          if (axis) value[{ x: 0, y: 1, z: 2 }[axis]] = amount;
        } else if (kind === "rotate") {
          value = [0, 0, 0];
          value[{ x: 0, y: 1, z: 2 }[axis ?? "y"]] =
            ((numeric ?? (dx - dy) * 0.5) * Math.PI) / 180;
        } else {
          const amount = numeric ?? Math.max(0.01, 1 + (dx - dy) * 0.008);
          value = [1, 1, 1].map((v, i) =>
            !axis || i === { x: 0, y: 1, z: 2 }[axis] ? amount : v,
          );
        }
        modal.valid = !!send({ op: "preview", value });
        if (modal.valid)
          message.textContent = `${kind.toUpperCase()} · ${axis?.toUpperCase() ?? (kind === "extrude" ? "NORMAL" : "FREE")} ${typed || value.map((v) => v.toFixed(2)).join(" / ")} · Enter 確定 / Esc 取消`;
      }
      function key(e) {
        if (
          !mounted ||
          e.target?.closest?.("input,textarea,select,[contenteditable]")
        )
          return;
        const shortcut = e.ctrlKey || e.metaKey;
        if (shortcut && e.code === "KeyS") {
          e.preventDefault();
          e.stopImmediatePropagation();
          save().catch(report);
          return;
        }
        if (shortcut && e.code === "KeyZ") {
          e.preventDefault();
          e.stopImmediatePropagation();
          if (modal) finish(false);
          else send({ op: e.shiftKey ? "redo" : "undo" });
          return;
        }
        if (shortcut || e.altKey || e.repeat) return;
        if (modal) {
          e.preventDefault();
          e.stopImmediatePropagation();
          if (e.code === "Escape") {
            finish(false);
            return;
          }
          if (e.code === "Enter" || e.code === "NumpadEnter") {
            finish(true);
            return;
          }
          if (["KeyX", "KeyY", "KeyZ"].includes(e.code)) {
            const axis = e.code.slice(-1).toLowerCase();
            modal.axis = modal.axis === axis ? null : axis;
            viewer.axis(modal.axis);
          } else if (/^(Digit|Numpad)[0-9]$/.test(e.code))
            modal.typed += e.code.slice(-1);
          else if (
            ["Period", "NumpadDecimal"].includes(e.code) &&
            !modal.typed.includes(".")
          )
            modal.typed += ".";
          else if (["Minus", "NumpadSubtract"].includes(e.code))
            modal.typed = modal.typed.startsWith("-")
              ? modal.typed.slice(1)
              : "-" + modal.typed;
          else if (e.code === "Backspace")
            modal.typed = modal.typed.slice(0, -1);
          applyPreview();
          return;
        }
        const state = editor.snapshot();
        const actions = {
          KeyG: () => begin("move"),
          KeyR: () => begin("rotate"),
          KeyS: () => begin("scale"),
          KeyE: () => begin("extrude"),
          Tab: () =>
            send({
              op: "mode",
              value: state.mode === "object" ? "vertex" : "object",
            }),
          Digit1: () => send({ op: "mode", value: "vertex" }),
          Digit3: () => send({ op: "mode", value: "face" }),
          KeyA: () => {
            if (state.mode === "vertex") {
              const n = state.document.nodes.find(
                (n) => n.id === state.selected,
              );
              if (n)
                send({
                  op: "vertices",
                  indices: e.shiftKey ? [] : n.vertices.map((_, i) => i),
                });
            }
          },
          KeyX: () => send({ op: "remove" }),
          Delete: () => send({ op: "remove" }),
          KeyF: () => viewer.frame(),
          KeyD: () => {
            if (e.shiftKey) send({ op: "duplicate" });
          },
          Numpad1: () => viewer.view("front"),
          Numpad3: () => viewer.view("side"),
          Numpad7: () => viewer.view("top"),
          Numpad5: () => viewer.view("toggle"),
          NumpadDecimal: () => viewer.frame(),
        };
        if (actions[e.code]) {
          e.preventDefault();
          e.stopImmediatePropagation();
          actions[e.code]();
        }
      }
      const unsubscribe = editor.subscribe(sync);
      mounted = { sync, message, viewer };
      sync(editor.snapshot());
      document.addEventListener("keydown", key, { capture: true, signal });
      window.addEventListener(
        "blur",
        () => {
          if (modal) finish(false);
        },
        { signal },
      );
      viewer.canvas.focus();
      return () => {
        if (modal) finish(false);
        mounted = undefined;
        unsubscribe();
        viewer.dispose();
        releaseViewport?.();
        for (const id of slots) workspace.slot(id).release(ID);
        overlay.remove();
        topActions.remove();
        workspaceInfo.remove();
      };
    },
  });
  const unsubscribeHost = host.subscribe(() => {
    if (
      mounted &&
      (host.transport?.().playing ||
        host.project() !== project ||
        host.sceneId() !== sceneId)
    )
      panes.close(ID);
    project = host.project();
    sceneId = host.sceneId();
  });
  return Object.freeze({
    open: () => panes.open(ID),
    close: () => panes.close(ID),
    active: () => !!mounted,
    snapshot: () => editor.snapshot(),
    request: send,
    save,
    exportJSON,
    exportGLB,
    stats: () => mounted?.viewer.stats() ?? null,
    dispose() {
      disposed = true;
      unsubscribeHost();
      panes.unregister(ID);
      openButton.remove();
      store.dispose().catch(report);
    },
  });
}
