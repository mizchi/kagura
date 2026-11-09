import { validateInspection, validateInspectionEdit } from "./inspection.mjs";

/** Narrow field edits own a session, without claiming full-state restoration. */
export function createRuntimeFieldSession(adapter) {
  if (
    adapter?.apiVersion !== 1 ||
    typeof adapter.game !== "string" ||
    typeof adapter.read !== "function" ||
    typeof adapter.edit !== "function" ||
    typeof adapter.pause !== "function"
  )
    throw Error("Invalid runtime field adapter");
  const session = crypto.randomUUID(),
    journal = [];
  let disposed = false;
  function live() {
    if (disposed) throw Error("Runtime field session disposed");
  }
  function copy(value) {
    const json = JSON.stringify(value, (_, v) => {
      if (typeof v === "number" && !Number.isFinite(v))
        throw Error("Invalid inspection number");
      return v;
    });
    if (!json || new TextEncoder().encode(json).byteLength > 4 * 1024 * 1024)
      throw Error("Runtime fields exceed 4 MiB");
    return JSON.parse(json);
  }
  function inspect() {
    live();
    const value = adapter.read();
    if (
      !Number.isSafeInteger(value.revision) ||
      value.revision < 0 ||
      typeof value.paused !== "boolean" ||
      typeof value.scope !== "string" ||
      !value.scope.length ||
      value.scope.length > 256
    )
      throw Error("Invalid runtime field inspection");
    const current = copy({
      session,
      revision: value.revision,
      scope: value.scope,
      paused: value.paused,
      subjects: value.subjects,
    });
    validateInspection(current.subjects);
    return current;
  }
  function guard(token) {
    const current = inspect();
    if (token?.session !== session)
      throw Error("Runtime field session conflict");
    if (token?.revision !== current.revision)
      throw Error("Runtime field revision conflict");
    if (token?.scope !== current.scope)
      throw Error("Runtime field scope conflict");
    if (!current.paused) throw Error("Runtime must be paused");
    return current;
  }
  return Object.freeze({
    inspect,
    pause() {
      live();
      adapter.pause(true);
      const next = inspect();
      journal.push({ operation: "pause", revision: next.revision });
      if (journal.length > 100) journal.shift();
      return next;
    },
    resume(token) {
      guard(token);
      adapter.pause(false);
      const next = inspect();
      journal.push({ operation: "resume", revision: next.revision });
      if (journal.length > 100) journal.shift();
      return next;
    },
    edit(edit, token) {
      const current = guard(token);
      const command = copy(edit);
      validateInspectionEdit(command, current.subjects);
      const subject = current.subjects.find((s) => s.id === command.subject);
      const before = subject.fields.find((f) => f.id === command.field);
      adapter.edit(command, {
        revision: current.revision,
        scope: current.scope,
      });
      const next = inspect();
      const after = next.subjects
        .find((s) => s.id === command.subject)
        ?.fields.find((f) => f.id === command.field);
      const trim = (value) =>
        typeof value === "string" && value.length > 512
          ? value.slice(0, 512) + "…"
          : value;
      journal.push({
        operation: "edit",
        revision: next.revision,
        label: subject.name + " / " + before.label,
        before: trim(before.value),
        after: trim(after?.value ?? command.value),
      });
      if (journal.length > 100) journal.shift();
      return next;
    },
    history() {
      live();
      return copy(journal);
    },
    dispose() {
      disposed = true;
      journal.length = 0;
    },
  });
}
