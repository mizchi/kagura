import {
  motionFormat,
  prepareMotionAsset,
  validateMotionAsset,
} from "./contract.mjs";
import { createMotionPlayer } from "./player.mjs";
import "./style.css";

export function installMotionAssets({
  host,
  panes,
  viewport,
  workspace,
  setStatus,
}) {
  let project = host.project(),
    mounted,
    viewer,
    player,
    asset,
    resumeViewport,
    sequence = 0,
    disposed = false;
  let state = { path: null, state: "idle", model: null, skeleton: false };
  const snapshot = () => ({
    ...state,
    transport: player?.snapshot() ?? null,
    models: asset?.models.map(({ id, name }) => ({ id, name })) ?? [],
    clips:
      asset?.clips.map(({ id, name, duration, events }) => ({
        id,
        name,
        duration,
        events: structuredClone(events),
      })) ?? [],
  });
  function reset() {
    sequence++;
    viewer?.dispose();
    viewer = undefined;
    player = undefined;
    asset = undefined;
    resumeViewport?.();
    resumeViewport = undefined;
    state = { path: null, state: "idle", model: null, skeleton: false };
    if (mounted) {
      mounted.overlay.hidden = true;
      mounted.stage.replaceChildren();
      mounted.controls.disabled = true;
      mounted.timeline.disabled = true;
    }
  }
  async function list() {
    const p = host.project();
    if (!p) return [];
    const files = await p.list();
    if (disposed || p !== host.project())
      throw new DOMException("Project changed", "AbortError");
    return files.filter(motionFormat).sort();
  }
  const report = (error) => {
    if (error.name !== "AbortError") setStatus("Error · " + error.message);
  };
  async function refresh() {
    const target = mounted;
    const paths = await list();
    if (!target || mounted !== target) return;
    target.resources.replaceChildren(
      new Option("モーションデータを選択…", ""),
      ...paths.map((p) => new Option(p, p)),
    );
    target.resources.value = state.path ?? "";
  }
  function sync(transport) {
    if (!mounted || !player) return;
    mounted.play.textContent = transport.playing ? "一時停止" : "再生";
    mounted.play.setAttribute(
      "aria-label",
      transport.playing ? "Pause motion" : "Play motion",
    );
    mounted.seek.value = String(transport.time);
    mounted.seek.max = String(transport.duration);
    mounted.seek.step = String(1 / transport.fps);
    const text = `${transport.time.toFixed(3)} / ${transport.duration.toFixed(3)} s · ${transport.frame} / ${Math.round(transport.duration * transport.fps)} f`;
    if (mounted.time.textContent !== text) mounted.time.textContent = text;
    mounted.speed.value = String(transport.speed);
    mounted.loop.checked = transport.loop;
  }
  function requirePlayer() {
    if (!player) throw Error("Load a motion asset first");
    return player;
  }
  function selectClip(id) {
    requirePlayer().selectClip(id);
    mounted.clips.value = id;
    const clip = asset.clips.find((c) => c.id === id);
    mounted.events.replaceChildren(
      ...clip.events.map((event) =>
        button(`${event.name} · ${event.time.toFixed(2)}s`, () =>
          seek(event.time),
        ),
      ),
    );
    mounted.title.textContent =
      asset.name +
      " / " +
      asset.models.find((m) => m.id === state.model).name +
      " / " +
      clip.name;
    sync(player.snapshot());
  }
  function selectModel(id) {
    requirePlayer();
    const model = asset.models.find((m) => m.id === id);
    if (!model) throw Error("Unknown motion model");
    state.model = id;
    mounted.models.value = id;
    viewer.model(id);
    selectClip(model.defaultClip);
  }
  function seek(time) {
    requirePlayer().seek(time);
    sync(player.snapshot());
  }
  function step(direction) {
    requirePlayer().step(direction);
    sync(player.snapshot());
  }
  function play() {
    requirePlayer().play();
    sync(player.snapshot());
  }
  function pause() {
    requirePlayer().pause();
    sync(player.snapshot());
  }
  function setSpeed(speed) {
    requirePlayer().setSpeed(speed);
    sync(player.snapshot());
  }
  function setLoop(loop) {
    requirePlayer().setLoop(loop);
    sync(player.snapshot());
  }
  function showSkeleton(show) {
    if (typeof show !== "boolean")
      throw Error("Skeleton visibility must be boolean");
    requirePlayer();
    state.skeleton = show;
    viewer.skeleton(show);
    mounted.bones.checked = show;
  }
  async function load(read, path) {
    if (disposed) throw Error("Motion viewer disposed");
    panes.open("studio.motions");
    reset();
    const token = sequence,
      target = mounted,
      p = host.project();
    state = { ...state, path, state: "loading" };
    target.result.textContent = "Loading · " + path;
    target.resources.value = path;
    try {
      const [data, { createMotionViewer }] = await Promise.all([
        read(),
        import("./viewer.mjs"),
      ]);
      if (token !== sequence || p !== host.project() || !mounted)
        throw new DOMException("Motion load superseded", "AbortError");
      // The viewer is an authoring tool. End any Play iframe before mounting it.
      if (host.transport?.().playing) await host.stop();
      if (token !== sequence || p !== host.project() || !mounted)
        throw new DOMException("Motion load superseded", "AbortError");
      asset = data;
      player = createMotionPlayer(data);
      target.overlay.hidden = false;
      resumeViewport = viewport?.suspendRendering();
      viewer = createMotionViewer(target.stage, data, player, sync);
      target.models.replaceChildren(
        ...data.models.map((m) => new Option(m.name, m.id)),
      );
      target.clips.replaceChildren(
        ...data.clips.map((c) => new Option(c.name, c.id)),
      );
      target.controls.disabled = false;
      target.timeline.disabled = false;
      target.bones.checked = false;
      target.grid.checked = true;
      state = {
        path,
        state: "ready",
        model: data.models[0].id,
        skeleton: false,
      };
      selectModel(state.model);
      target.result.textContent = `${data.skeleton.length} joints · ${data.models.length} models · ${data.clips.length} clips`;
      setStatus("Motion viewer · " + data.name);
      return snapshot();
    } catch (error) {
      if (token === sequence) {
        reset();
        state = { ...state, path, state: "error" };
        target.result.textContent = error.message;
      }
      throw error;
    }
  }
  async function preview(path) {
    const p = host.project();
    if (!p) throw Error("Open a project first");
    return load(() => prepareMotionAsset(p, path), path);
  }
  function importAsset(data, name = "Imported motion") {
    return load(async () => validateMotionAsset(data), name);
  }
  function button(text, action, label) {
    const b = document.createElement("button");
    b.type = "button";
    b.textContent = text;
    if (label) b.setAttribute("aria-label", label);
    b.addEventListener("click", () => {
      try {
        action();
      } catch (e) {
        report(e);
      }
    });
    return b;
  }
  function select(label) {
    const s = document.createElement("select");
    s.setAttribute("aria-label", label);
    return s;
  }
  function checkbox(text, label, action) {
    const l = document.createElement("label"),
      input = document.createElement("input");
    input.type = "checkbox";
    input.setAttribute("aria-label", label);
    input.addEventListener("change", () => action(input.checked));
    l.append(input, text);
    return { label: l, input };
  }
  panes.register({
    id: "studio.motions",
    title: "Motions",
    workspace: true,
    mount({ element, signal }) {
      const heading = document.createElement("h2");
      heading.textContent = "Motion viewer";
      const note = document.createElement("p");
      note.className = "panel-note";
      note.textContent =
        "モデルと動作を選び、コマ送りで確認します。ドラッグで回転、ホイールで拡大。";
      const resources = select("Motion resource");
      resources.addEventListener("change", () => {
        if (resources.value) preview(resources.value).catch(report);
        else reset();
      });
      const file = document.createElement("input");
      file.type = "file";
      file.accept = ".kgrmotion";
      file.setAttribute("aria-label", "Import motion asset");
      file.addEventListener("change", () => {
        const source = file.files[0];
        if (source)
          load(
            () => prepareMotionAsset({ read: async () => source }, source.name),
            source.name,
          ).catch(report);
        file.value = "";
      });
      const controls = document.createElement("fieldset");
      controls.disabled = true;
      controls.className = "motion-options";
      const models = select("Motion model"),
        clips = select("Motion clip");
      models.addEventListener("change", () => selectModel(models.value));
      clips.addEventListener("change", () => selectClip(clips.value));
      const modelLabel = document.createElement("label");
      modelLabel.textContent = "モデル";
      modelLabel.append(models);
      const clipLabel = document.createElement("label");
      clipLabel.textContent = "モーション";
      clipLabel.append(clips);
      const bones = checkbox(
        "骨格を重ねる",
        "Show motion skeleton",
        showSkeleton,
      );
      const grid = checkbox("グリッド", "Show motion grid", (show) =>
        viewer?.grid(show),
      );
      grid.input.checked = true;
      const camera = document.createElement("div");
      camera.className = "motion-camera";
      for (const [name, id] of [
        ["斜め", "orbit"],
        ["正面", "front"],
        ["横", "side"],
        ["俯瞰", "top"],
      ])
        camera.append(
          button(name, () => viewer?.view(id), "Motion camera " + id),
        );
      controls.append(modelLabel, clipLabel, bones.label, grid.label, camera);
      const result = document.createElement("p");
      result.setAttribute("aria-label", "Motion information");
      result.className = "panel-note";
      const overlay = document.createElement("section");
      overlay.className = "motion-overlay";
      overlay.hidden = true;
      overlay.setAttribute("aria-label", "Motion viewer workspace");
      const toolbar = document.createElement("div");
      toolbar.className = "motion-toolbar";
      const title = document.createElement("strong");
      toolbar.append(
        title,
        button(
          "閉じる",
          () => panes.close("studio.motions"),
          "Close motion viewer",
        ),
      );
      const stage = document.createElement("div");
      stage.className = "motion-stage";
      const timeline = document.createElement("fieldset");
      timeline.className = "motion-timeline";
      timeline.disabled = true;
      const transport = document.createElement("div");
      transport.className = "motion-transport";
      const playButton = button(
        "再生",
        () => (player.snapshot().playing ? pause() : play()),
        "Play motion",
      );
      const speed = select("Motion speed");
      for (const n of [0.25, 0.5, 1, 2])
        speed.add(new Option(n + "×", String(n)));
      speed.value = "1";
      speed.addEventListener("change", () => setSpeed(Number(speed.value)));
      const loop = checkbox("ループ", "Loop motion", setLoop);
      loop.input.checked = true;
      transport.append(
        button("↤", () => seek(0), "Rewind motion"),
        button("‹", () => step(-1), "Previous motion frame"),
        playButton,
        button("›", () => step(1), "Next motion frame"),
        speed,
        loop.label,
      );
      const seekInput = document.createElement("input");
      seekInput.type = "range";
      seekInput.min = "0";
      seekInput.setAttribute("aria-label", "Motion time");
      seekInput.addEventListener("input", () => seek(Number(seekInput.value)));
      const time = document.createElement("span");
      time.className = "motion-time";
      time.setAttribute("aria-label", "Motion position");
      const events = document.createElement("div");
      events.className = "motion-events";
      timeline.append(transport, seekInput, time, events);
      overlay.append(toolbar, stage, timeline);
      workspace.slot("viewport").host.append(overlay);
      overlay.addEventListener(
        "keydown",
        (event) => {
          if (
            event.target.closest("input,select,textarea,button") ||
            event.ctrlKey ||
            event.metaKey ||
            event.altKey
          )
            return;
          const action = {
            Space: () => (player.snapshot().playing ? pause() : play()),
            ArrowLeft: () => step(-1),
            ArrowRight: () => step(1),
            KeyF: () => viewer.view(),
          }[event.code];
          if (action) {
            event.preventDefault();
            event.stopPropagation();
            action();
          }
        },
        { signal },
      );
      element.append(
        heading,
        note,
        resources,
        file,
        controls,
        result,
        button("一覧を更新", () => refresh().catch(report), "Refresh motions"),
      );
      mounted = {
        overlay,
        stage,
        controls,
        timeline,
        resources,
        models,
        clips,
        result,
        title,
        bones: bones.input,
        grid: grid.input,
        play: playButton,
        seek: seekInput,
        time,
        speed,
        loop: loop.input,
        events,
      };
      refresh().catch(report);
      return () => {
        reset();
        overlay.remove();
        mounted = undefined;
      };
    },
  });
  const unsubscribe = host.subscribe(() => {
    if (mounted && host.transport?.().playing) {
      panes.close("studio.motions");
    }
    if (host.project() === project) return;
    project = host.project();
    reset();
    if (mounted) {
      mounted.result.textContent = "";
      refresh().catch(report);
    }
  });
  return Object.freeze({
    list,
    preview,
    importAsset,
    snapshot,
    selectModel,
    selectClip,
    seek,
    step,
    play,
    pause,
    setSpeed,
    setLoop,
    showSkeleton,
    close() {
      panes.close("studio.motions");
    },
    dispose() {
      disposed = true;
      reset();
      unsubscribe();
      panes.unregister("studio.motions");
    },
  });
}
