///|
test "scene project validates destinations before creating a flow" {
  let floor = Entity::{
    id: "floor",
    kind: "floor",
    position: [0.0, -0.125, 0.0],
    scale: [18.0, 0.25, 18.0],
    color: 0,
    target: "",
  }
  let spawn = Entity::{
    id: "spawn",
    kind: "spawn",
    position: [0.0, 0.5, 0.0],
    scale: [1.0, 1.0, 1.0],
    color: 0,
    target: "",
  }
  let portal = Entity::{
    id: "exit",
    kind: "portal",
    position: [2.0, 0.5, 0.0],
    scale: [1.0, 1.0, 1.0],
    color: 0,
    target: "b",
  }
  let a = Definition::{ version: 1, entities: [floor, spawn, portal], }
  let b = Definition::{ version: 1, entities: [floor, spawn], }
  let session = Session::new(
    { entry: "a", scenes: [{ id: "a", data: a, }, { id: "b", data: b, }], },
    ["floor", "spawn", "portal"],
  )
  assert_eq(session.portal_at(2.0, 0.0), Some("b"))
  session.transition("b")
  assert_eq(session.current_id(), "b")
  assert_eq(session.portal_at(2.0, 0.0), None)
  // A known scene is not automatically a legal destination from this scene.
  assert_true(try { session.transition("a"); false } catch { _ => true })
  assert_eq(session.current_id(), "b")
  assert_true(
    try {
      ignore(
        Session::new({ entry: "a", scenes: [{ id: "a", data: a, }], }, [
          "floor", "spawn", "portal",
        ]),
      )
      false
    } catch {
      _ => true
    },
  )
}

///|
test "portal definitions share the same state machine contract as explicit flows" {
  let project : Project = {
    entry: "a",
    scenes: [
      { id: "a", data: { version: 1, entities: [{ id: "exit", kind: "portal", position: [], scale: [], color: 0, target: "b" }] } },
      { id: "b", data: { version: 1, entities: [] } },
    ],
  }
  let definition = project.flow_definition()
  assert_eq(definition.terminal, ["b"])
  assert_eq(definition.transitions[0].event, "portal:exit")
  assert_eq(definition.analyze().issues.length(), 0)
}
