export function exampleRecording({ bulk = false, id = "sample-run" } = {}) {
  const events = [];
  const add = (type, extra = {}) => {
    const sequence = events.length + 1;
    const e = {
      version: 1,
      id: `e${sequence}`,
      sequence,
      source: "simulation",
      revision: sequence,
      type,
      ...extra,
    };
    events.push(e);
    return e.id;
  };
  for (let n = 1; n <= 2; n++) {
    const context = { target: "turn", instance: `turn:${n}`, decisionIndex: n };
    add("loop.start", context);
    const causes = [];
    if (!bulk) {
      const request = add("input.requested", context);
      causes.push(request);
      add("input.accepted", {
        ...context,
        causes: [request],
        data: { action: "guard" },
      });
    }
    const request = add("input.requested", context);
    causes.push(request);
    add("loop.resolved", {
      ...context,
      causes,
      data: {
        damage: 4,
        healing: 0,
        hp: [20],
        maxHp: [24],
        mp: [8],
        potions: 3,
        torch: 60,
      },
    });
    add("input.accepted", {
      ...context,
      causes: [request],
      data: { action: bulk ? "all-attack" : "resolve" },
    });
    add("loop.ready", context);
  }
  const reached = add("arc.reached", { target: "room", instance: "room:1" });
  add("arc.exposed", {
    target: "room",
    instance: "room:1",
    source: "observation",
    causes: [reached],
  });
  return {
    format: "kagura.experience-recording",
    version: 1,
    spec: {
      apiVersion: 1,
      id: "sample",
      version: 1,
      loops: [
        { id: "turn", label: "行動と結果", intent: "結果を確認して次を選ぶ" },
      ],
      arcs: [
        {
          id: "room",
          label: "新しい部屋",
          intent: "discovery",
          knowledgeKey: "room:2",
          contentVersion: "1",
        },
      ],
      relations: [],
    },
    run: {
      id,
      subjectId: id,
      scope: "sample",
      cohort: "local-policy",
      context: { input: bulk ? "bulk" : "manual" },
    },
    events,
    termination: "completed",
    ledger: [],
  };
}
