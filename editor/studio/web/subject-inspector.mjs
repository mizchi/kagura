import { readRuntimeSubjectView } from "../runtime/subject-view.mjs";

/** Generic form generated from game-owned descriptors; selection is only a logical ID. */
export function createSubjectInspector(
  host,
  setStatus,
  read = () => readRuntimeSubjectView(host),
) {
  const panel = document.createElement("section");
  panel.setAttribute("aria-label", "Selected runtime subject");
  let selected, key, signature;
  function render() {
    const view = read() ?? { subjects: [], writable: false };
    if (key !== undefined && key !== view.key) selected = undefined;
    key = view.key;
    const subject = view.subjects.find((value) => value.id === selected);
    const next = JSON.stringify([
      selected,
      key,
      view.paused,
      view.writable,
      view.token?.revision,
      subject,
    ]);
    if (signature === next) return;
    signature = next;
    panel.replaceChildren();
    const heading = document.createElement("h3");
    heading.textContent = subject?.name ?? "Hierarchy で対象を選択";
    panel.append(heading);
    if (!subject) return;
    for (const field of subject.fields) {
      const form = document.createElement("form");
      const label = document.createElement("label");
      label.textContent = field.label + (field.unit ? " · " + field.unit : "");
      const input = document.createElement("input");
      input.setAttribute("aria-label", subject.name + " " + field.label);
      input.type =
        field.kind === "number"
          ? "number"
          : field.kind === "boolean"
            ? "checkbox"
            : "text";
      input.step = "any";
      if (field.kind === "boolean") input.checked = field.value;
      else input.value = String(field.value);
      input.disabled =
        !view.writable || field.access !== "runtime" || !view.paused;
      label.append(input);
      form.append(label);
      if (view.writable && field.access === "runtime") {
        const button = document.createElement("button");
        button.textContent = "Apply " + field.label;
        button.disabled = !view.paused;
        form.append(button);
      } else {
        const note = document.createElement("span");
        note.textContent = "Read only";
        form.append(note);
      }
      form.addEventListener("submit", (event) => {
        event.preventDefault();
        if (!view.writable || field.access !== "runtime" || !view.paused)
          return;
        try {
          const value =
            field.kind === "number"
              ? input.valueAsNumber
              : field.kind === "boolean"
                ? input.checked
                : input.value;
          host[view.editor === "fields" ? "fields" : "debug"](
            "edit",
            { subject: subject.id, field: field.id, value },
            view.token,
          );
          setStatus(
            "Runtime field applied · " + subject.name + " / " + field.label,
          );
        } catch (error) {
          setStatus("Error · " + error.message);
        }
      });
      panel.append(form);
    }
  }
  return {
    panel,
    render,
    select(subject) {
      key = read()?.key;
      selected = subject;
      signature = undefined;
      render();
    },
  };
}
