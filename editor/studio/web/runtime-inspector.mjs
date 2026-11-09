import { createSubjectInspector } from "./subject-inspector.mjs";
import { downloadBlob } from "./storage.mjs";
import { readRuntimeSubjectView } from "../runtime/subject-view.mjs";

export function exportRuntimeCheckpoint(host) {
  const { game, schema, state } = host.debug("snapshot");
  downloadBlob(
    new Blob(
      [
        JSON.stringify(
          { format: "kagura.checkpoint", version: 1, game, schema, state },
          null,
          2,
        ),
      ],
      { type: "application/json" },
    ),
    game + ".kgrstate",
  );
}

/** An explicit paused-state draft; it never writes authoring documents or source files. */
export function installRuntimeInspector(host, setStatus, workspace) {
  const shell = document.querySelector(".inspector");
  const container = workspace?.slot("inspector").body ?? shell;
  let panel,
    text,
    caption,
    apply,
    file,
    base,
    subjectInspector,
    undo,
    dirty = false;
  let observationPanel,
    observationText,
    observationCaption,
    observationHeading,
    observationCapture,
    captured;
  let observationSubjects, observationRaw, currentObservation, hadSubjects;
  const refreshDraft = (snapshot) => {
    base = snapshot;
    text.value = JSON.stringify(snapshot.state, null, 2);
    dirty = false;
  };
  function mount() {
    panel = document.createElement("section");
    panel.className = "runtime-inspector";
    panel.setAttribute("aria-label", "Runtime inspector");
    const heading = document.createElement("h2");
    heading.textContent = "Runtime state";
    caption = document.createElement("p");
    const note = document.createElement("p");
    note.textContent =
      "Pauseで実行状態を編集。Apply後はその状態から再開します。";
    text = document.createElement("textarea");
    text.setAttribute("aria-label", "Runtime state JSON");
    text.spellcheck = false;
    text.addEventListener("input", () => {
      dirty = true;
    });
    const button = (label, action) => {
      const node = document.createElement("button");
      node.type = "button";
      node.textContent = label;
      node.addEventListener("click", async () => {
        try {
          await action();
        } catch (error) {
          setStatus("Error · " + error.message);
        }
      });
      return node;
    };
    apply = button("Apply state", () => {
      const next = host.debug("replace", JSON.parse(text.value), base);
      refreshDraft(next);
      setStatus("Runtime state applied · ソースは変更していません");
    });
    const read = button("Read state", () =>
      refreshDraft(host.debug("snapshot")),
    );
    const save = button("Export checkpoint", () =>
      exportRuntimeCheckpoint(host),
    );
    undo = button("Undo runtime edit", () =>
      refreshDraft(host.debug("undo", host.debug("snapshot"))),
    );
    file = document.createElement("input");
    file.type = "file";
    file.accept = ".kgrstate,.json";
    file.setAttribute("aria-label", "Import checkpoint");
    file.addEventListener("change", async () => {
      const target = panel,
        inputFile = file;
      try {
        const current = host.debug("snapshot");
        if (!current.paused) throw Error("Pause before importing a checkpoint");
        const selected = inputFile.files[0];
        if (!selected) return;
        if (selected.size > 4 * 1024 * 1024)
          throw Error("Checkpoint exceeds 4 MiB");
        const checkpoint = JSON.parse(await selected.text());
        if (panel !== target)
          throw Error("Runtime changed while loading checkpoint");
        const latest = host.debug("snapshot");
        if (
          latest.session !== current.session ||
          latest.revision !== current.revision
        )
          throw Error("Runtime changed while loading checkpoint");
        if (
          checkpoint.format !== "kagura.checkpoint" ||
          checkpoint.version !== 1 ||
          checkpoint.game !== current.game ||
          checkpoint.schema?.id !== current.schema.id ||
          checkpoint.schema?.version !== current.schema.version ||
          !Object.hasOwn(checkpoint, "state")
        )
          throw Error("Incompatible checkpoint");
        base = current;
        text.value = JSON.stringify(checkpoint.state, null, 2);
        dirty = true;
        setStatus("Checkpoint loaded · Apply stateで適用");
      } catch (error) {
        setStatus("Error · " + error.message);
      } finally {
        inputFile.value = "";
      }
    });
    subjectInspector = createSubjectInspector(host, setStatus);
    const raw = document.createElement("details");
    raw.className = "runtime-json";
    const summary = document.createElement("summary");
    summary.textContent = "Raw state JSON";
    raw.append(summary, text, apply, read, save, file);
    panel.append(heading, caption, note, subjectInspector.panel, undo, raw);
    container.append(panel);
    shell.classList.add("runtime-inspecting");
  }
  function render() {
    const transport = host.transport();
    if (!transport.debugging) {
      panel?.remove();
      panel = undefined;
      base = undefined;
      subjectInspector = undefined;
      dirty = false;
      shell.classList.remove("runtime-inspecting");
      if (transport.playing) {
        if (!observationPanel) {
          observationPanel = document.createElement("section");
          observationPanel.className = "runtime-inspector runtime-observation";
          observationPanel.setAttribute("aria-label", "Runtime observation");
          observationHeading = document.createElement("h2");
          observationCaption = document.createElement("p");
          const capture = (observationCapture =
            document.createElement("button"));
          capture.textContent = "Capture observation";
          capture.onclick = () => {
            captured = host.observe?.();
            render();
          };
          const live = document.createElement("button");
          live.textContent = "Live observation";
          live.onclick = () => {
            captured = undefined;
            render();
          };
          observationText = document.createElement("pre");
          observationSubjects = createSubjectInspector(host, setStatus, () =>
            readRuntimeSubjectView(host, currentObservation, {
              readonly: captured != null,
            }),
          );
          observationRaw = document.createElement("details");
          observationRaw.className = "runtime-json";
          const summary = document.createElement("summary");
          summary.textContent = "Raw observation JSON";
          observationRaw.append(summary, observationText);
          observationPanel.append(
            observationHeading,
            observationCaption,
            observationSubjects.panel,
            capture,
            live,
            observationRaw,
          );
          container.append(observationPanel);
        }
        const observation = captured ?? host.observe?.();
        currentObservation = observation;
        const editingFields = transport.fieldEditing && captured == null;
        observationHeading.textContent = editingFields
          ? "Runtime fields"
          : "Runtime observation · Read only";
        const fieldInspection = editingFields ? host.fields("inspect") : null;
        const hasSubjects = !!(
          fieldInspection?.subjects.length ||
          observation?.inspection?.subjects.length
        );
        observationCapture.disabled =
          !observation || (editingFields && !observation.inspection);
        observationSubjects.panel.hidden = !hasSubjects;
        observationSubjects.render();
        if (hadSubjects !== hasSubjects) observationRaw.open = !hasSubjects;
        hadSubjects = hasSubjects;
        const observationMode = captured
          ? transport.paused
            ? "Captured · Paused"
            : "Captured; game keeps running"
          : transport.paused
            ? "Paused"
            : "Live";
        const observationHint = captured
          ? "Read only; use Live observation for current state"
          : "Read only; state editing requires a debug adapter";
        observationCaption.textContent = fieldInspection
          ? `${fieldInspection.paused ? "Paused" : "Running"} · ${fieldInspection.scope} · revision ${fieldInspection.revision} · ${fieldInspection.paused ? "Edit declared fields" : "Pause to edit declared fields"}`
          : observation
            ? `${observationMode} · ${observation.inspection?.scope ?? observation.source} · ${observationHint}`
            : "This game does not publish observations. Pause/edit require a game debug adapter.";
        observationText.textContent = observation
          ? JSON.stringify(observation.state, null, 2).slice(0, 65536)
          : "";
        shell.classList.add("runtime-inspecting");
      } else {
        observationPanel?.remove();
        observationPanel = undefined;
        observationSubjects = undefined;
        currentObservation = undefined;
        hadSubjects = undefined;
        captured = undefined;
      }
      return;
    }
    observationPanel?.remove();
    observationPanel = undefined;
    observationSubjects = undefined;
    currentObservation = undefined;
    hadSubjects = undefined;
    captured = undefined;
    if (!panel) mount();
    const snapshot = host.debug("snapshot");
    subjectInspector.render();
    caption.textContent =
      (snapshot.paused ? "Paused" : "Running") +
      " · revision " +
      snapshot.revision;
    text.disabled = apply.disabled = file.disabled = !snapshot.paused;
    undo.disabled = !host.debug("canUndo");
    if (!dirty || base?.session !== snapshot.session) refreshDraft(snapshot);
  }
  const unsubscribe = host.subscribe(render);
  const interval = setInterval(() => {
    try {
      render();
    } catch (error) {
      setStatus("Error · " + error.message);
    }
  }, 250);
  render();
  return {
    selectSubject(id) {
      (subjectInspector ?? observationSubjects)?.select(id);
    },
    dispose() {
      unsubscribe();
      clearInterval(interval);
      panel?.remove();
      observationPanel?.remove();
      shell.classList.remove("runtime-inspecting");
    },
  };
}
