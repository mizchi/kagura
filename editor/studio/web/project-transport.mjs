/** Shell-owned controls. Game extensions expose behavior without inserting toolbar DOM. */
import { exportRuntimeCheckpoint } from "./runtime-inspector.mjs";
export function installProjectTransport(host, setStatus) {
  const group = document.createElement("div");
  group.className = "project-transport";
  group.setAttribute("role", "group");
  group.setAttribute("aria-label", "Project controls");
  let busy = false,
    disposed = false;
  const button = (label, action) => {
    const node = document.createElement("button");
    node.type = "button";
    node.textContent = label;
    node.addEventListener("click", async () => {
      // Moving focus out of a game may pause it before click fires. Honor the
      // action the user clicked, rather than toggling the newly changed state.
      const intent = node.textContent;
      busy = true;
      render();
      try {
        await action(intent);
      } catch (error) {
        setStatus("Error · " + error.message);
      } finally {
        busy = false;
        if (!disposed) render();
      }
    });
    return node;
  };
  const edit = button("Edit", () => host.edit());
  const play = button("Play", () => host.play());
  const stop = button("Stop", () => host.stop());
  const pause = button("Pause", (intent) => {
    const state = host.transport();
    const resume = intent === "Resume";
    if (!state.debugging) {
      if (state.fieldEditing)
        return resume
          ? host.fields("resume", host.fields("inspect"))
          : host.fields("pause");
      return resume ? host.resume() : host.pause();
    }
    return resume
      ? host.debug("resume", host.debug("snapshot"))
      : host.debug("pause");
  });
  const step = button("Step", () => host.debug("step", host.debug("snapshot")));
  const restart = button("Restart", async () => {
    await host.stop();
    await host.play();
  });
  const checkpoint = button("Checkpoint", () => exportRuntimeCheckpoint(host));
  play.className = "primary";
  group.append(edit, play, pause, step, restart, stop, checkpoint);
  const toolbar = document.querySelector(".viewport-toolbar");
  toolbar.prepend(group);
  function render() {
    const state = host.transport();
    group.hidden = !state.available;
    edit.disabled = busy;
    play.disabled = busy || !state.canPlay || state.playing;
    stop.disabled = busy || !state.playing;
    pause.hidden =
      step.hidden =
      restart.hidden =
      checkpoint.hidden =
        !state.playing;
    pause.textContent = state.paused ? "Resume" : "Pause";
    pause.disabled = busy || !(state.debugging || state.canPause);
    pause.title =
      state.debugging || state.canPause
        ? "Pause / resume simulation"
        : "This runtime has no pause adapter";
    step.disabled = busy || !state.debugging || !state.paused;
    restart.disabled = busy;
    checkpoint.disabled = busy || !state.debugging;
    toolbar.classList.toggle("showing-game", state.playing);
  }
  const unsubscribe = host.subscribe(render);
  const interval = setInterval(render, 250);
  render();
  return {
    dispose() {
      disposed = true;
      unsubscribe();
      clearInterval(interval);
      group.remove();
      toolbar.classList.remove("showing-game");
    },
  };
}
