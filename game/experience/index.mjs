import { deriveMeasures } from "./measures.mjs";
import {
  validateSpec,
  validateEvent,
  validateRun,
  validateLedger,
  check,
  freeze,
  integer,
  text,
  canonical,
} from "./contract.mjs";
export { validateSpec } from "./contract.mjs";

const key = (...parts) => JSON.stringify(parts);

/** Pure reduction: no clocks, DOM, RNG, game rules, or model calls. */
export function analyzeExperience(inputRecording) {
  if (inputRecording?.format !== undefined)
    check(
      inputRecording.format === "kagura.experience-recording" &&
        inputRecording.version === 1,
      "Invalid recording",
    );
  const {
    spec: input,
    run,
    events,
    termination,
    ledger: previous = [],
  } = inputRecording;
  const spec = validateSpec(input);
  validateRun(run);
  validateLedger(previous);
  check(
    ["completed", "interrupted", "censored"].includes(termination),
    "Invalid termination",
  );
  check(Array.isArray(events) && events.length <= 100000, "Invalid events");
  const ledger = structuredClone(previous),
    loops = [],
    arcs = [],
    issues = [],
    byId = new Map(),
    loopMap = new Map(),
    arcMap = new Map(),
    acknowledged = new Set();
  const issue = (code, eventId, detail) =>
    issues.push({ code, eventId, detail });
  let sequence = 0;
  for (const e of events) {
    validateEvent(e, spec);
    check(
      e.sequence > sequence && !byId.has(e.id),
      "Invalid event order or duplicate ID",
    );
    if (e.sequence !== sequence + 1)
      issue(
        "sequence-gap",
        e.id,
        `Expected ${sequence + 1}, got ${e.sequence}`,
      );
    sequence = e.sequence;
    for (const id of e.causes ?? [])
      if (!byId.has(id)) issue("missing-cause", e.id, id);
    byId.set(e.id, e);
    if (e.type === "input.accepted" || e.type === "input.rejected") {
      const requests = (e.causes ?? []).filter(
        (id) => byId.get(id)?.type === "input.requested",
      );
      const request = byId.get(requests[0]);
      if (
        requests.length !== 1 ||
        request?.target !== e.target ||
        request?.instance !== e.instance
      )
        issue("missing-request", e.id, e.instance);
      if (acknowledged.has(requests[0]))
        issue("duplicate-acknowledgement", e.id, requests[0]);
      acknowledged.add(requests[0]);
    }
    if (e.type.startsWith("loop.")) {
      const id = key(e.target, e.instance);
      let l = loopMap.get(id);
      if (e.type === "loop.start") {
        if (l) {
          issue("duplicate-start", e.id, e.instance);
          continue;
        }
        l = {
          targetId: e.target,
          instance: e.instance,
          start: e.id,
          resolution: null,
          ready: null,
          interruption: null,
          commands: [],
          feedback: [],
          answers: [],
          status: "open",
        };
        loops.push(l);
        loopMap.set(id, l);
      } else if (!l) {
        issue("orphan-loop", e.id, e.instance);
        continue;
      } else if (e.type === "loop.resolved") {
        if (l.resolution || l.interruption) {
          issue("duplicate-resolution", e.id, e.instance);
          continue;
        }
        l.resolution = e.id;
      } else if (e.type === "loop.ready") {
        if (!l.resolution || l.ready || l.interruption) {
          issue("unexpected-ready", e.id, e.instance);
          continue;
        }
        l.ready = e.id;
      } else if (e.type === "loop.interrupted") {
        if (l.resolution || l.interruption) {
          issue("unexpected-interruption", e.id, e.instance);
          continue;
        }
        l.interruption = e.id;
      } else if (e.type === "loop.feedback") {
        if (!l.resolution || !(e.causes ?? []).includes(l.resolution)) {
          issue("unlinked-feedback", e.id, e.instance);
          continue;
        }
        l.feedback.push(e.id);
      } else if (e.type === "loop.understood") {
        if (!l.resolution) {
          issue("answer-before-resolution", e.id, e.instance);
          continue;
        }
        l.answers.push(e.id);
      }
    } else if (e.type.startsWith("arc.")) {
      const id = key(e.target, e.instance);
      let a = arcMap.get(id);
      if (e.type === "arc.reached") {
        if (a) {
          issue("duplicate-arc", e.id, e.instance);
          continue;
        }
        a = {
          targetId: e.target,
          instance: e.instance,
          reached: e.id,
          exposed: [],
          recognized: [],
          understood: [],
          exposure: "unknown",
        };
        arcs.push(a);
        arcMap.set(id, a);
      } else if (!a) {
        issue("orphan-arc", e.id, e.instance);
        continue;
      } else if (e.type === "arc.exposed") {
        if (a.exposed.length) {
          a.exposed.push(e.id);
          continue;
        }
        const s = spec.arcs.find((t) => t.id === e.target);
        let entry = ledger.find(
          (k) =>
            k.subjectId === run.subjectId &&
            k.scope === run.scope &&
            k.knowledgeKey === s.knowledgeKey &&
            k.contentVersion === s.contentVersion,
        );
        const already = entry?.exposures.some(
          (p) => p.runId === run.id && p.eventId === e.id,
        );
        // Re-analyzing with a previously exported ledger is idempotent.
        a.exposure = entry?.exposures.some(
          (p) =>
            p.runId !== run.id ||
            (byId.has(p.eventId) && byId.get(p.eventId).sequence < e.sequence),
        )
          ? "repeat"
          : "first";
        if (!entry) {
          entry = {
            subjectId: run.subjectId,
            scope: run.scope,
            knowledgeKey: s.knowledgeKey,
            contentVersion: s.contentVersion,
            exposures: [],
          };
          ledger.push(entry);
        }
        if (!already)
          entry.exposures.push({
            runId: run.id,
            eventId: e.id,
            source: e.source,
          });
        a.exposed.push(e.id);
      } else {
        if (!a.exposed.length) {
          issue("answer-before-exposure", e.id, e.instance);
          continue;
        }
        a[e.type === "arc.recognized" ? "recognized" : "understood"].push(e.id);
      }
    }
  }
  // Synchronous engines may emit acceptance after the resolution it caused.
  for (const e of events)
    if (e.type === "input.accepted" && e.target) {
      const l = loopMap.get(key(e.target, e.instance));
      if (!l) {
        issue("orphan-input", e.id, e.instance);
        continue;
      }
      if (l.ready && e.sequence > byId.get(l.ready).sequence)
        issue("late-input", e.id, e.instance);
      l.commands.push(e.id);
    }
  for (const l of loops)
    l.status = l.interruption
      ? "interrupted"
      : l.resolution && l.ready
        ? "completed"
        : termination === "interrupted"
          ? "interrupted"
          : "censored";
  const measures = deriveMeasures({ spec, loops, arcs, byId, issue });
  return freeze({
    format: "kagura.experience-report",
    version: 1,
    spec,
    run: structuredClone(run),
    termination,
    valid: issues.length === 0,
    issues,
    loops,
    arcs,
    measures,
    ledger,
  });
}

export function validateReport(input) {
  check(
    input?.format === "kagura.experience-report" &&
      input.version === 1 &&
      Array.isArray(input.measures) &&
      typeof input.valid === "boolean" &&
      Array.isArray(input.issues) &&
      Array.isArray(input.loops) &&
      Array.isArray(input.arcs) &&
      ["completed", "interrupted", "censored"].includes(input.termination),
    "Invalid experience report",
  );
  const spec = validateSpec(input.spec);
  validateRun(input.run);
  const ids = new Set();
  for (const m of input.measures) {
    const id = key(m.targetId, m.id);
    check(
      [...spec.loops, ...spec.arcs].some((t) => t.id === m.targetId) &&
        text(m.id) &&
        text(m.unit) &&
        !ids.has(id) &&
        integer(m.sampleCount) &&
        integer(m.eligibleCount) &&
        m.sampleCount <= m.eligibleCount &&
        ["mechanical", "rendered", "human", "exposure"].includes(
          m.evidenceKind,
        ) &&
        Array.isArray(m.sources) &&
        m.sources.every((s) =>
          ["simulation", "observation", "rendered", "human"].includes(s),
        ) &&
        Array.isArray(m.evidenceEventIds) &&
        m.evidenceEventIds.every(text),
      "Invalid report measure",
    );
    ids.add(id);
    check(
      ["observed", "not-instrumented", "not-applicable", "censored"].includes(
        m.status,
      ) &&
        (m.status === "observed" ? Number.isFinite(m.value) : m.value === null),
      "Invalid report value/status",
    );
  }
  return input;
}

export function compareExperience(before, after) {
  validateReport(before);
  validateReport(after);
  check(
    canonical({ ...before.spec, relations: before.spec.relations ?? [] }) ===
      canonical({ ...after.spec, relations: after.spec.relations ?? [] }),
    "Incompatible experience specs",
  );
  const a = { cohort: before.run.cohort, ...before.run.context },
    b = { cohort: after.run.cohort, ...after.run.context };
  const conditionsDiffer = [
    ...new Set([...Object.keys(a), ...Object.keys(b)]),
  ].filter((k) => a[k] !== b[k]);
  return freeze({
    format: "kagura.experience-comparison",
    version: 1,
    kind: "descriptive",
    before: before.run.id,
    after: after.run.id,
    valid: before.valid && after.valid,
    conditionsDiffer,
    measures: after.measures.map((m) => {
      const prior = before.measures.find(
        (p) => p.targetId === m.targetId && p.id === m.id,
      );
      return {
        targetId: m.targetId,
        id: m.id,
        unit: m.unit,
        before: prior?.value ?? null,
        after: m.value,
        delta:
          before.valid &&
          after.valid &&
          prior?.status === "observed" &&
          m.status === "observed" &&
          prior.unit === m.unit &&
          prior.evidenceKind === m.evidenceKind &&
          JSON.stringify(prior.sources) === JSON.stringify(m.sources)
            ? m.value - prior.value
            : null,
        beforeStatus: prior?.status ?? "not-instrumented",
        afterStatus: m.status,
        beforeSamples: prior?.sampleCount ?? 0,
        afterSamples: m.sampleCount,
      };
    }),
  });
}

/** Explicit bridge to balance's finite-number contract. No implicit imputation. */
export function projectMetrics(input, requests) {
  const r = validateReport(input);
  check(r.valid, "Invalid experience evidence");
  check(
    r.termination === "completed" &&
      r.loops.every((l) => l.status !== "censored"),
    "Incomplete experience run",
  );
  check(Array.isArray(requests) && requests.length > 0, "Invalid projection");
  const out = {};
  for (const p of requests) {
    check(
      text(p.as) &&
        !["__proto__", "constructor", "prototype"].includes(p.as) &&
        !Object.hasOwn(out, p.as) &&
        integer(p.minSamples) &&
        p.minSamples > 0,
      "Invalid projection request",
    );
    const m = r.measures.find(
      (m) => m.targetId === p.targetId && m.id === p.metricId,
    );
    check(
      m?.status === "observed" && Number.isFinite(m.value),
      "Projection requires observed values",
    );
    check(m.sampleCount >= p.minSamples, "Insufficient samples");
    check(m.sampleCount >= m.eligibleCount, "Incomplete measurement coverage");
    out[p.as] = m.value;
  }
  return out;
}
