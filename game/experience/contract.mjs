export const check = (condition, message) => {
  if (!condition) throw Error(message);
};
export const object = (value) =>
  value !== null && typeof value === "object" && !Array.isArray(value);
export const text = (value) =>
  typeof value === "string" && value.length > 0 && value.length <= 200;
export const integer = (value) => Number.isSafeInteger(value) && value >= 0;
export function freeze(value) {
  if (value && typeof value === "object") {
    Object.values(value).forEach(freeze);
    Object.freeze(value);
  }
  return value;
}
export function jsonValue(value, depth = 0) {
  check(depth < 32, "Invalid JSON depth");
  if (
    value === null ||
    typeof value === "string" ||
    typeof value === "boolean" ||
    Number.isFinite(value)
  )
    return;
  check(
    Array.isArray(value) ||
      (object(value) &&
        [Object.prototype, null].includes(Object.getPrototypeOf(value))),
    "Invalid JSON value",
  );
  for (const item of Object.values(value)) jsonValue(item, depth + 1);
}
export function canonical(value) {
  return JSON.stringify(normalize(value));
}
function normalize(value) {
  if (Array.isArray(value)) return value.map(normalize);
  if (object(value))
    return Object.fromEntries(
      Object.keys(value)
        .sort()
        .map((k) => [k, normalize(value[k])]),
    );
  return value;
}
function fields(value, keys, label) {
  check(
    object(value) && Object.keys(value).every((k) => keys.includes(k)),
    `Invalid ${label} fields`,
  );
}
function unique(values, label) {
  check(new Set(values).size === values.length, `Duplicate ${label}`);
}

export function validateSpec(input) {
  fields(
    input,
    ["apiVersion", "id", "version", "loops", "arcs", "relations"],
    "spec",
  );
  check(
    input.apiVersion === 1 &&
      text(input.id) &&
      integer(input.version) &&
      input.version > 0,
    "Invalid spec version",
  );
  check(
    Array.isArray(input.loops) &&
      Array.isArray(input.arcs) &&
      input.loops.length + input.arcs.length > 0 &&
      input.loops.length + input.arcs.length <= 128,
    "Invalid spec targets",
  );
  for (const t of input.loops) {
    fields(t, ["id", "label", "intent"], "loop spec");
    check([t.id, t.label, t.intent].every(text), "Invalid loop spec");
  }
  for (const t of input.arcs) {
    fields(
      t,
      ["id", "label", "intent", "knowledgeKey", "contentVersion"],
      "arc spec",
    );
    check(
      [t.id, t.label, t.intent, t.knowledgeKey, t.contentVersion].every(text),
      "Invalid arc spec",
    );
  }
  const ids = [...input.loops, ...input.arcs].map((t) => t.id);
  unique(ids, "spec IDs");
  check(Array.isArray(input.relations ?? []), "Invalid relations");
  for (const r of input.relations ?? []) {
    fields(r, ["from", "to", "kind"], "relation");
    check(
      ids.includes(r.from) &&
        ids.includes(r.to) &&
        r.from !== r.to &&
        ["contains", "context", "interrupts", "parallel"].includes(r.kind),
      "Invalid relation",
    );
  }
  return freeze(
    structuredClone({ ...input, relations: input.relations ?? [] }),
  );
}

const types = [
  "input.requested",
  "input.accepted",
  "input.rejected",
  "loop.start",
  "loop.resolved",
  "loop.ready",
  "loop.interrupted",
  "loop.feedback",
  "loop.understood",
  "arc.reached",
  "arc.exposed",
  "arc.recognized",
  "arc.understood",
];
export function validateEvent(input, spec) {
  fields(
    input,
    [
      "version",
      "id",
      "sequence",
      "source",
      "revision",
      "type",
      "target",
      "instance",
      "causes",
      "data",
      "clock",
      "decisionIndex",
    ],
    "event",
  );
  check(
    input.version === 1 &&
      text(input.id) &&
      integer(input.sequence) &&
      input.sequence > 0 &&
      integer(input.revision) &&
      types.includes(input.type),
    "Invalid event",
  );
  check(
    ["simulation", "observation", "rendered", "human"].includes(input.source),
    "Invalid event source",
  );
  if (input.type.endsWith("understood") || input.type === "arc.recognized")
    check(
      input.source === "human" && typeof input.data?.value === "boolean",
      "Invalid human event source/value",
    );
  else if (input.type === "arc.exposed")
    check(
      ["observation", "rendered"].includes(input.source),
      "Invalid exposure source",
    );
  else if (input.type === "loop.feedback")
    check(input.source === "rendered", "Invalid feedback source");
  else check(input.source === "simulation", "Invalid simulation source");
  if (!input.type.startsWith("input.") || input.target !== undefined) {
    const targets = input.type.startsWith("arc.") ? spec.arcs : spec.loops;
    check(
      targets.some((t) => t.id === input.target) && text(input.instance),
      "Invalid event target/instance",
    );
  } else
    check(input.instance === undefined, "Input instance requires a target");
  check(
    input.causes === undefined ||
      (Array.isArray(input.causes) && input.causes.every(text)),
    "Invalid causes",
  );
  unique(input.causes ?? [], "causes");
  if (input.data !== undefined) {
    check(object(input.data), "Invalid event data");
    jsonValue(input.data);
  }
  if (input.clock !== undefined) {
    fields(input.clock, ["id", "ms"], "clock");
    check(
      text(input.clock.id) &&
        Number.isFinite(input.clock.ms) &&
        input.clock.ms >= 0,
      "Invalid clock",
    );
  }
  if (input.decisionIndex !== undefined)
    check(integer(input.decisionIndex), "Invalid decision index");
  return input;
}

export function validateRun(run) {
  fields(run, ["id", "subjectId", "scope", "cohort", "context"], "run");
  check(
    [run.id, run.subjectId, run.scope, run.cohort].every(text) &&
      object(run.context ?? {}),
    "Invalid run",
  );
  check(
    Object.values(run.context ?? {}).every(
      (v) =>
        v === null ||
        typeof v === "string" ||
        typeof v === "boolean" ||
        Number.isFinite(v),
    ),
    "Invalid run context",
  );
  return run;
}

export function validateLedger(ledger) {
  check(Array.isArray(ledger), "Invalid ledger");
  const keys = [];
  for (const e of ledger) {
    fields(
      e,
      ["subjectId", "scope", "knowledgeKey", "contentVersion", "exposures"],
      "ledger",
    );
    check(
      [e.subjectId, e.scope, e.knowledgeKey, e.contentVersion].every(text) &&
        Array.isArray(e.exposures) &&
        e.exposures.length > 0,
      "Invalid ledger entry",
    );
    keys.push(
      JSON.stringify([e.subjectId, e.scope, e.knowledgeKey, e.contentVersion]),
    );
    const exposureKeys = [];
    for (const p of e.exposures) {
      fields(p, ["runId", "eventId", "source"], "exposure");
      check(
        text(p.runId) &&
          text(p.eventId) &&
          ["rendered", "observation"].includes(p.source),
        "Invalid ledger exposure",
      );
      exposureKeys.push(JSON.stringify([p.runId, p.eventId]));
    }
    unique(exposureKeys, "ledger exposures");
  }
  unique(keys, "ledger keys");
  return ledger;
}
