import { createHash } from "node:crypto";
import {
  analyzeExperience,
  validateSpec,
} from "../../../game/experience/index.mjs";
import {
  check,
  integer,
  canonical,
} from "../../../game/experience/contract.mjs";

export const spec = validateSpec({
  apiVersion: 1,
  id: "dungeon_rpg",
  version: 1,
  loops: [
    {
      id: "combat-round",
      label: "戦闘ラウンド",
      intent: "予告を読み、行動を選び、解決結果から次を選ぶ",
    },
  ],
  arcs: [
    {
      id: "b2-arrival",
      label: "地下2階への到達",
      intent: "discovery",
      knowledgeKey: "fathom:floor:2",
      contentVersion: "map:1",
    },
  ],
  relations: [{ from: "b2-arrival", to: "combat-round", kind: "context" }],
});

/** Raw simulation sequences remain auditable; observation exposures are separate
 * events. Seeing a floor in the policy input is never a human recognition. */
export function recordingFromTrace(
  records,
  { runId, subjectId = runId, scope = "fathom", ledger = [] } = {},
) {
  const header = records?.[0],
    end = records?.at(-1);
  check(
    header?.game === "dungeon_rpg" &&
      header.experienceVersion === 1 &&
      end?.type === "run_end",
    "Trace has no experience telemetry",
  );
  let rawCursor = 0,
    sequence = 0,
    pending;
  const events = [];
  function append(batch, decisionIndex) {
    check(
      batch?.version === 1 &&
        integer(batch.firstSequence) &&
        batch.firstSequence > 0 &&
        integer(batch.lastSequence) &&
        typeof batch.dropped === "boolean" &&
        Array.isArray(batch.events),
      "Invalid experience batch",
    );
    check(
      batch.lastSequence >= rawCursor &&
        batch.firstSequence <= batch.lastSequence + 1,
      "Invalid experience cursor",
    );
    check(
      batch.dropped === rawCursor < batch.firstSequence - 1,
      "Inconsistent dropped-event marker",
    );
    for (const e of batch.events) {
      check(
        integer(e.sequence) &&
          e.sequence > rawCursor &&
          e.sequence <= batch.lastSequence &&
          e.id === `s${e.sequence}`,
        "Invalid raw sequence",
      );
      sequence += e.sequence - rawCursor;
      rawCursor = e.sequence;
      events.push({ ...e, sequence, decisionIndex });
      if (e.type === "arc.reached" && e.target === "b2-arrival") pending = e;
    }
    check(rawCursor === batch.lastSequence, "Incomplete experience batch");
  }
  append(header.experience, 0);
  for (const record of records.slice(1, -1)) {
    check(
      record.type === "decision" && integer(record.index),
      "Invalid decision record",
    );
    if (record.before.state.floor !== 2) pending = undefined;
    if (pending && record.source === "model") {
      sequence++;
      events.push({
        version: 1,
        id: `observation:${record.index}`,
        sequence,
        source: "observation",
        revision: record.before.revision,
        decisionIndex: record.index,
        type: "arc.exposed",
        target: pending.target,
        instance: pending.instance,
        causes: [pending.id],
        data: { medium: "policy-input" },
      });
      pending = undefined;
    }
    append(record.experience, record.index);
  }
  return {
    format: "kagura.experience-recording",
    version: 1,
    spec,
    run: {
      id: runId,
      subjectId,
      scope,
      cohort: header.model,
      context: {
        seed: header.seed,
        engineVersion: header.engineVersion,
        input: "agent-choice",
        knowledge: "exposure-history-only",
        balance: canonical(header.balance),
        masterData: createHash("sha256")
          .update(canonical(header.masterData))
          .digest("hex"),
      },
    },
    events,
    termination: ["victory", "defeat", "returned"].includes(end.status)
      ? "completed"
      : end.limitReason === "interrupted"
        ? "interrupted"
        : "censored",
    ledger: structuredClone(ledger),
  };
}

export function analyzeTrace(records, options) {
  return analyzeExperience(recordingFromTrace(records, options));
}
