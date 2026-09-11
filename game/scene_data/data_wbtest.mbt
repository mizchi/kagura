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
