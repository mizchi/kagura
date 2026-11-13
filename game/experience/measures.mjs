const quantile = (values, p) => {
  const sorted = values.toSorted((a, b) => a - b);
  return sorted[Math.max(0, Math.ceil(p * sorted.length) - 1)];
};

/** Derives measurements without imputing missing evidence. */
export function deriveMeasures({ spec, loops, arcs, byId, issue }) {
  const measures = [];
  function measure(
    targetId,
    id,
    value,
    unit,
    evidenceKind,
    refs,
    {
      sampleCount = refs.length,
      eligibleCount = sampleCount,
      status = value === null ? "not-instrumented" : "observed",
      numerator,
      denominator,
    } = {},
  ) {
    measures.push({
      targetId,
      id,
      value,
      unit,
      evidenceKind,
      sources: [...new Set(refs.map((id) => byId.get(id).source))].sort(),
      evidenceEventIds: refs,
      sampleCount,
      eligibleCount,
      status,
      ...(numerator !== undefined ? { numerator } : {}),
      ...(denominator !== undefined ? { denominator } : {}),
    });
  }
  function rate(targetId, id, refs, eligibleCount) {
    const latest = new Map();
    for (const eventId of refs) {
      const e = byId.get(eventId);
      latest.set(e.instance, e);
    }
    const answers = [...latest.values()],
      n = answers.filter((e) => e.data.value).length;
    measure(
      targetId,
      id,
      answers.length ? n / answers.length : null,
      "ratio",
      "human",
      answers.map((e) => e.id),
      {
        eligibleCount,
        sampleCount: answers.length,
        numerator: n,
        denominator: answers.length,
        status: answers.length
          ? "observed"
          : eligibleCount
            ? "not-instrumented"
            : "not-applicable",
      },
    );
  }
  for (const t of spec.loops) {
    const ls = loops.filter((l) => l.targetId === t.id),
      resolved = ls.filter((l) => l.resolution),
      commands = resolved.flatMap((l) => l.commands);
    measure(
      t.id,
      "resolvedCount",
      resolved.length,
      "resolution",
      "mechanical",
      resolved.map((l) => l.resolution),
      { sampleCount: ls.length },
    );
    measure(
      t.id,
      "completedCount",
      ls.filter((l) => l.status === "completed").length,
      "loop",
      "mechanical",
      ls.filter((l) => l.ready).map((l) => l.ready),
      { sampleCount: ls.length },
    );
    measure(
      t.id,
      "commandsPerResolution",
      resolved.length ? commands.length / resolved.length : null,
      "command/resolution",
      "mechanical",
      commands,
      {
        sampleCount: resolved.length,
        eligibleCount: resolved.length,
        numerator: commands.length,
        denominator: resolved.length,
        status: resolved.length ? "observed" : "not-applicable",
      },
    );
    const decisions = resolved.map(
        (l) =>
          new Set(
            l.commands
              .map((id) => byId.get(id).decisionIndex)
              .filter((i) => i !== undefined),
          ).size,
      ),
      decisionsKnown =
        resolved.length > 0 &&
        commands.every((id) => byId.get(id).decisionIndex !== undefined);
    measure(
      t.id,
      "decisionsPerResolution",
      decisionsKnown
        ? decisions.reduce((a, b) => a + b, 0) / resolved.length
        : null,
      "decision/resolution",
      "mechanical",
      commands,
      {
        sampleCount: decisionsKnown ? resolved.length : 0,
        eligibleCount: resolved.length,
        status: decisionsKnown
          ? "observed"
          : resolved.length
            ? "not-instrumented"
            : "not-applicable",
      },
    );
    const undo = ls
      .flatMap((l) => l.commands)
      .filter((id) => byId.get(id).data?.action === "undo");
    measure(t.id, "undoCommands", undo.length, "command", "mechanical", undo, {
      sampleCount: ls.length,
    });
    const linked = resolved.filter((l) => {
      const causes = byId.get(l.resolution).causes ?? [];
      return (
        l.commands.length > 0 &&
        l.commands.every((id) =>
          (byId.get(id).causes ?? []).some((c) => causes.includes(c)),
        )
      );
    });
    measure(
      t.id,
      "causalCoverage",
      resolved.length ? linked.length / resolved.length : null,
      "ratio",
      "mechanical",
      resolved.map((l) => l.resolution),
      {
        sampleCount: resolved.length,
        eligibleCount: resolved.length,
        numerator: linked.length,
        denominator: resolved.length,
        status: resolved.length ? "observed" : "not-applicable",
      },
    );
    const latencies = [];
    for (const l of resolved) {
      const start = byId.get(l.resolution);
      const feedback = l.feedback
        .map((id) => byId.get(id))
        .find((e) => e.clock && start.clock && e.clock.id === start.clock.id);
      if (feedback) {
        if (feedback.clock.ms < start.clock.ms)
          issue("backwards-clock", feedback.id, l.instance);
        else
          latencies.push({
            value: feedback.clock.ms - start.clock.ms,
            id: feedback.id,
          });
      }
    }
    for (const [id, p] of [
      ["feedbackLatencyP50Ms", 0.5],
      ["feedbackLatencyP95Ms", 0.95],
    ])
      measure(
        t.id,
        id,
        latencies.length
          ? quantile(
              latencies.map((l) => l.value),
              p,
            )
          : null,
        "ms",
        "rendered",
        latencies.map((l) => l.id),
        {
          sampleCount: latencies.length,
          eligibleCount: resolved.length,
          status: latencies.length
            ? "observed"
            : resolved.length
              ? "not-instrumented"
              : "not-applicable",
        },
      );
    rate(
      t.id,
      "understandingRate",
      ls.flatMap((l) => l.answers),
      resolved.length,
    );
  }
  for (const t of spec.arcs) {
    const as = arcs.filter((a) => a.targetId === t.id),
      exposed = as.filter((a) => a.exposed.length);
    measure(
      t.id,
      "reachedCount",
      as.length,
      "arc",
      "mechanical",
      as.map((a) => a.reached),
      { sampleCount: as.length },
    );
    for (const [id, selected] of [
      ["exposedCount", exposed],
      ["firstExposureCount", exposed.filter((a) => a.exposure === "first")],
      ["repeatExposureCount", exposed.filter((a) => a.exposure === "repeat")],
    ])
      measure(
        t.id,
        id,
        exposed.length ? selected.length : null,
        "arc",
        "exposure",
        selected.map((a) => a.exposed[0]),
        {
          sampleCount: exposed.length,
          eligibleCount: as.length,
          status: exposed.length
            ? "observed"
            : as.length
              ? "not-instrumented"
              : "not-applicable",
        },
      );
    rate(
      t.id,
      "recognitionRate",
      as.flatMap((a) => a.recognized),
      exposed.length,
    );
    rate(
      t.id,
      "comprehensionRate",
      as.flatMap((a) => a.understood),
      exposed.length,
    );
  }
  return measures;
}
