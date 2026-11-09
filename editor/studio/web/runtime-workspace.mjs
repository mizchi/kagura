/** Runtime layout owns presentation only; existing slots and authoring state survive. */
import { runtimePickTargets } from "../runtime/picking.mjs";
export function installRuntimeWorkspace(host, panes, selection = {}) {
  const studio = document.querySelector(".studio"),
    workspace = document.querySelector(".workspace");
  const center = workspace.querySelector('[data-column="1"]');
  const transport = document.querySelector(".project-transport"),
    tools = document.querySelector(".agent");
  const resources = document.querySelector(".assets"),
    timeline = document.querySelector(".timeline");
  const viewport = document.getElementById("viewport"),
    toolbar = document.querySelector(".viewport-toolbar");
  const lifetime = new AbortController(),
    { signal } = lifetime;
  const placements = new Map(
    [transport, tools, resources, timeline].map((node) => {
      const marker = document.createComment("runtime workspace placement");
      node.before(marker);
      return [node, marker];
    }),
  );
  const restore = (node) => placements.get(node).after(node);
  const make = (tag, className, text) => {
    const n = document.createElement(tag);
    n.className = className;
    if (text) n.textContent = text;
    return n;
  };
  const bar = make("section", "runtime-bar");
  bar.setAttribute("aria-label", "Runtime controls");
  const status = make("span", "runtime-status");
  status.setAttribute("aria-live", "polite");
  const meta = make("span", "runtime-meta");
  bar.append(status, meta);
  bar.hidden = true;
  workspace.before(bar);
  const mobile = make("nav", "runtime-mobile-nav");
  mobile.setAttribute("aria-label", "Runtime panels");
  for (const [id, label] of [
    ["objects", "Objects"],
    ["game", "Game"],
    ["state", "State"],
  ]) {
    const b = make("button", "", label);
    b.type = "button";
    b.dataset.pane = id;
    b.addEventListener(
      "click",
      () => {
        studio.dataset.runtimePane = id;
        updateMobile();
      },
      { signal },
    );
    mobile.append(b);
  }
  bar.after(mobile);
  studio.dataset.runtimePane = "game";
  function updateMobile() {
    for (const b of mobile.children)
      b.setAttribute(
        "aria-pressed",
        String(b.dataset.pane === studio.dataset.runtimePane),
      );
  }
  updateMobile();
  const dock = make("section", "runtime-dock");
  dock.setAttribute("aria-label", "Runtime tools");
  const toggle = make("button", "runtime-dock-toggle", "Collapse tools");
  toggle.type = "button";
  toggle.setAttribute("aria-expanded", "true");
  function collapse(value) {
    dock.classList.toggle("collapsed", value);
    toggle.setAttribute("aria-expanded", String(!value));
    toggle.textContent = value ? "Expand tools" : "Collapse tools";
  }
  toggle.addEventListener(
    "click",
    () => collapse(!dock.classList.contains("collapsed")),
    { signal },
  );
  dock.append(toggle);
  dock.hidden = true;
  center.append(dock);
  dock.addEventListener(
    "click",
    (e) => {
      if (e.target.closest('[role="tab"]')) collapse(false);
    },
    { signal },
  );
  const controls = make("div", "runtime-view-controls");
  controls.append(make("strong", "", "Game view"));
  const zoom = make("select", "");
  zoom.setAttribute("aria-label", "Runtime view scale");
  for (const [value, label] of [
    ["fit", "Fit"],
    ["1", "1×"],
    ["2", "2×"],
  ]) {
    const o = make("option", "", label);
    o.value = value;
    zoom.append(o);
  }
  controls.append(zoom);
  toolbar.append(controls);
  controls.hidden = true;
  const pickLabel = make("label", "runtime-pick-toggle");
  const pick = document.createElement("input");
  pick.type = "checkbox";
  pick.checked = true;
  pick.setAttribute("aria-label", "Pick runtime objects");
  pickLabel.append(pick, document.createTextNode("Pick objects"));
  controls.append(pickLabel);
  const overlay = make("div", "runtime-pick-layer");
  overlay.setAttribute("aria-label", "Runtime object picking");
  viewport.append(overlay);
  let pickSignature;
  function updatePicking() {
    const frame = viewport.querySelector(".game-frame"),
      state = host.transport();
    const inspection = state.debugging ? host.debug("inspect") : null;
    const targets = inspection
      ? runtimePickTargets(
          host.hierarchy(),
          frame?.contentWindow.__kaguraUISnapshot?.parsed,
          new Set(inspection.subjects.map((s) => s.id)),
        )
      : [];
    pick.disabled = !state.paused || !targets.length;
    pickLabel.title = targets.length
      ? "Select a declared object while paused"
      : "This runtime does not publish pickable visual bindings";
    const enabled = state.paused && pick.checked && targets.length > 0;
    overlay.hidden = !enabled;
    if (!enabled) {
      pickSignature = undefined;
      overlay.replaceChildren();
      return;
    }
    const bounds = frame.getBoundingClientRect(),
      surface = viewport.getBoundingClientRect();
    const canvas = frame.contentDocument.querySelector("canvas"),
      local = canvas.getBoundingClientRect();
    const scale = bounds.width / frame.clientWidth;
    const signature = JSON.stringify([
      targets,
      bounds.x,
      bounds.y,
      bounds.width,
      surface.x,
      surface.y,
      selection.selection?.(),
    ]);
    if (signature === pickSignature) return;
    pickSignature = signature;
    overlay.replaceChildren();
    for (const target of targets) {
      const subject = inspection.subjects.find((s) => s.id === target.subject);
      const button = make("button", "runtime-pick-target");
      button.type = "button";
      button.setAttribute("aria-label", "Select " + subject.name + " in game");
      button.setAttribute(
        "aria-pressed",
        String(selection.selection?.() === subject.id),
      );
      Object.assign(button.style, {
        left: `${bounds.left - surface.left + (local.left + target.left) * scale}px`,
        top: `${bounds.top - surface.top + (local.top + target.top) * scale}px`,
        width: `${target.width * scale}px`,
        height: `${target.height * scale}px`,
      });
      button.addEventListener("click", (event) => {
        event.stopPropagation();
        selection.select?.(subject.id);
        updatePicking();
      });
      overlay.append(button);
    }
  }
  pick.addEventListener("change", updatePicking, { signal });
  function fit() {
    const frame = viewport.querySelector(".game-frame");
    const canvas = frame?.contentDocument?.querySelector("canvas");
    if (!canvas?.width || !canvas.height) return;
    const declaredDisplay =
      frame.contentWindow.kaguraExample?.project.display ??
      frame.contentWindow.__kaguraProject?.display;
    // An uninitialized HTML canvas defaults to 300×150. Fitting that placeholder
    // can constrain the game's canvas and feed the wrong size back to its renderer.
    if (!declaredDisplay && frame.dataset.ready !== "true") return;
    const display = declaredDisplay ?? {
      width: canvas.width,
      height: canvas.height,
    };
    const scale =
      zoom.value === "fit"
        ? Math.max(
            0.01,
            Math.min(
              (viewport.clientWidth - 24) / display.width,
              (viewport.clientHeight - 24) / display.height,
            ),
          )
        : Number(zoom.value);
    // Scale the iframe presentation, keeping its layout viewport and game coordinates fixed.
    frame.style.width = `${display.width}px`;
    frame.style.height = `${display.height}px`;
    frame.style.inset = "auto";
    frame.style.left = frame.style.top = "50%";
    frame.style.transform = `translate(-50%,-50%) scale(${scale})`;
    canvas.style.imageRendering = "pixelated";
  }
  zoom.addEventListener("change", fit, { signal });
  const resize = new ResizeObserver(fit);
  resize.observe(viewport);
  panes.register({
    id: "studio.runtime-history",
    title: "Changes",
    workspace: true,
    mount({ element }) {
      const log = make("div", "runtime-history");
      log.setAttribute("aria-label", "Runtime history");
      element.append(log);
      function render() {
        log.replaceChildren();
        const state = host.transport();
        if (!state.debugging && !state.fieldEditing) {
          log.append(
            make(
              "p",
              "",
              "Read only · this runtime does not expose state editing.",
            ),
          );
          return;
        }
        const entries = state.debugging
          ? host.debug("history")
          : host.fields("history");
        if (!entries.length)
          log.append(
            make("p", "", "Pause the game to inspect and edit its state."),
          );
        for (const entry of entries) {
          const row = make("div", "runtime-history-row");
          row.append(
            make("code", "", `rev ${entry.revision}`),
            make("span", "", entry.label ?? entry.operation),
          );
          if (entry.operation === "edit")
            row.append(make("span", "", `${entry.before} → ${entry.after}`));
          log.append(row);
        }
      }
      const unsubscribe = host.subscribe(render);
      render();
      return unsubscribe;
    },
  });
  for (const [id, title, node] of [
    ["resources", "Assets", resources],
    ["scene", "Scene setup", timeline],
  ]) {
    panes.register({
      id: "studio.runtime-" + id,
      title,
      workspace: true,
      mount({ element }) {
        element.append(node);
        return () => restore(node);
      },
    });
  }
  let active = false,
    previousPane = "console";
  function render() {
    const state = host.transport();
    if (state.playing !== active) {
      active = state.playing;
      studio.classList.toggle("runtime-layout", active);
      bar.hidden = dock.hidden = controls.hidden = !active;
      if (active) {
        previousPane = panes.list().find((p) => p.active)?.id ?? "console";
        bar.insertBefore(transport, meta);
        dock.append(tools);
        panes.open("studio.runtime-history");
        collapse(false);
        studio.dataset.runtimePane = "game";
        updateMobile();
      } else {
        panes.open(
          panes.list().some((p) => p.id === previousPane)
            ? previousPane
            : "console",
        );
        restore(transport);
        restore(tools);
      }
    }
    if (!active) {
      overlay.hidden = true;
      overlay.replaceChildren();
      pickSignature = undefined;
      return;
    }
    status.textContent =
      state.debugging || state.fieldEditing
        ? state.paused
          ? "Paused"
          : "Running"
        : state.paused
          ? "Paused · Read only"
          : "Read only";
    status.dataset.paused = String(state.paused);
    meta.textContent = state.debugging
      ? `revision ${host.debug("snapshot").revision} · Runtime state`
      : state.fieldEditing
        ? `revision ${host.fields("inspect").revision} · Runtime fields`
        : `Published observations · ${state.canPause ? "state editing" : "pause/edit"} unavailable`;
    fit();
    updatePicking();
  }
  const unsubscribe = host.subscribe(render),
    timer = setInterval(render, 250);
  render();
  return {
    dispose() {
      clearInterval(timer);
      unsubscribe();
      lifetime.abort();
      resize.disconnect();
      for (const id of ["history", "resources", "scene"])
        panes.unregister("studio.runtime-" + id);
      for (const [node, marker] of placements) {
        marker.after(node);
        marker.remove();
      }
      studio.classList.remove("runtime-layout");
      delete studio.dataset.runtimePane;
      bar.remove();
      mobile.remove();
      dock.remove();
      controls.remove();
      overlay.remove();
    },
  };
}
