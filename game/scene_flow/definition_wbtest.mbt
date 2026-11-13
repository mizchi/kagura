///|
fn sample_definition() -> Definition {
  {
    entry: "title",
    scenes: ["title", "play", "result"],
    terminal: ["result"],
    transitions: [
      { from: "title", event: "start", to: "play", },
      { from: "play", event: "finish", to: "result", },
      { from: "play", event: "retry", to: "play", },
    ],
  }
}

///|
test "external enum and signal owners can enforce the same declaration without duplicating state" {
  let definition = sample_definition()
  definition.require_transition("title", "play")
  definition.require_transition("play", "play")
  assert_true(try { definition.require_transition("title", "result"); false } catch { _ => true })
  assert_true(try { definition.require_transition("missing", "play"); false } catch { _ => true })
}

///|
test "declarative flow analyzes cycles and explicit terminal scenes" {
  let report = sample_definition().analyze()
  assert_true(report.valid)
  assert_eq(report.issues.length(), 0)
  assert_eq(report.reachable, ["title", "play", "result"])
}

///|
test "analysis reports unreachable scenes and their dead transitions" {
  let definition = sample_definition()
  let broken : Definition = {
    ..definition,
    scenes: ["title", "play", "result", "unused"],
    transitions: [
      ..definition.transitions,
      { from: "unused", event: "start", to: "play", },
    ],
  }
  let report = broken.analyze()
  assert_true(
    report.issues.any(i => i.code == "unreachable-scene" && i.scene == "unused"),
  )
  assert_true(
    report.issues.any(i => i.code == "dead-transition" && i.transition == 3),
  )
}

///|
test "analysis rejects dangling endpoints ambiguous events and terminal exits" {
  let definition = sample_definition()
  let broken : Definition = {
    ..definition,
    transitions: [
      ..definition.transitions,
      { from: "title", event: "start", to: "result", },
      { from: "missing", event: "ghost", to: "absent", },
      { from: "result", event: "restart", to: "title", },
      { from: "play", event: "", to: "title", },
    ],
  }
  let report = broken.analyze()
  assert_false(report.valid)
  for
    code in [
      "ambiguous-event", "unknown-source", "unknown-target", "terminal-transition",
      "invalid-event",
    ] {
    assert_true(report.issues.any(i => i.code == code))
  }
}

///|
test "analysis distinguishes undeclared dead ends and traps without terminal paths" {
  let definition : Definition = {
    entry: "a",
    scenes: ["a", "b", "trap", "end"],
    terminal: ["end"],
    transitions: [
      { from: "a", event: "stop", to: "b", },
      { from: "a", event: "loop", to: "trap", },
      { from: "trap", event: "again", to: "trap", },
      { from: "a", event: "finish", to: "end", },
    ],
  }
  let report = definition.analyze()
  assert_true(report.issues.any(i => i.code == "dead-end" && i.scene == "b"))
  assert_true(
    report.issues.any(i => i.code == "no-terminal-path" && i.scene == "trap"),
  )
}

///|
test "declarative runtime rejects illegal edges and events without changing live tickets" {
  let flow = Flow::from_definition(sample_definition())
  assert_true(
    try {
      ignore(flow.request("result"))
      false
    } catch {
      _ => true
    },
  )
  assert_true(
    try {
      ignore(flow.send("finish"))
      false
    } catch {
      _ => true
    },
  )
  assert_eq(flow.current(), "title")
  let ticket = flow.send("start")
  assert_true(
    try {
      ignore(flow.send("start"))
      false
    } catch {
      _ => true
    },
  )
  assert_eq(flow.current(), "title")
  assert_true(flow.cancel(ticket))
  assert_false(flow.commit(ticket))
  let next = flow.send("start")
  assert_false(flow.commit(ticket))
  assert_true(flow.commit(next))
  assert_eq(flow.current(), "play")
  assert_true(flow.commit(flow.send("retry")))
  assert_true(flow.commit(flow.send("finish")))
  assert_true(
    try {
      ignore(flow.request("title"))
      false
    } catch {
      _ => true
    },
  )
  assert_eq(flow.current(), "result")
}

///|
test "runtime owns a copy and invalid definitions fail before activation" {
  let definition = sample_definition()
  let flow = Flow::from_definition(definition)
  definition.transitions.clear()
  definition.scenes.clear()
  assert_true(flow.commit(flow.send("start")))
  assert_true(
    try {
      ignore(
        Flow::from_definition({ ..sample_definition(), entry: "missing", }),
      )
      false
    } catch {
      _ => true
    },
  )
}

///|
test "mermaid uses stable generated IDs and escapes user labels" {
  let definition : Definition = {
    entry: "a\"<b>",
    scenes: ["a\"<b>", "done"],
    terminal: ["done"],
    transitions: [{ from: "a\"<b>", event: "go\"|\n", to: "done", }],
  }
  let diagram = definition.to_mermaid()
  assert_true(diagram.contains("stateDiagram-v2"))
  assert_true(diagram.contains("[*] --> s0"))
  assert_true(diagram.contains("s1 --> [*]"))
  assert_true(diagram.contains("s0 --> s1"))
  assert_false(diagram.contains("<b>"))
}

///|
test "invalid scene identity and terminal declarations are errors" {
  let definition : Definition = {
    entry: "missing",
    scenes: ["a", "a", ""],
    terminal: ["a", "a", "missing"],
    transitions: [],
  }
  let report = definition.analyze()
  assert_false(report.valid)
  for
    code in [
      "invalid-entry", "invalid-scene", "duplicate-scene", "unknown-terminal", "duplicate-terminal",
    ] {
    assert_true(report.issues.any(i => i.code == code))
  }
}

///|
test "an endless declared cycle is allowed when the game has no terminal" {
  let definition : Definition = {
    entry: "a",
    scenes: ["a", "b"],
    terminal: [],
    transitions: [
      { from: "a", event: "next", to: "b", },
      { from: "b", event: "next", to: "a", },
    ],
  }
  assert_eq(definition.analyze().issues.length(), 0)
}

///|
test "Mermaid cannot turn punctuation in labels into diagram syntax" {
  let definition : Definition = {
    entry: "a",
    scenes: ["a", "b"],
    terminal: ["b"],
    transitions: [{ from: "a", event: "go; b --> a: %%{init: {}}%%", to: "b", }],
  }
  let diagram = definition.to_mermaid()
  assert_false(diagram.contains("%%"))
  assert_false(diagram.contains("go;"))
}
