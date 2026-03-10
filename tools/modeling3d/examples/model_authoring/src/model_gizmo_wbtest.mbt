///|
test "pick_selected_primitive_gizmo_handle resolves x axis handles" {
  let doc : ModelDocument = {
    name: "gizmo-pick",
    notes: "",
    primitives: [
      {
        id: "box",
        kind: Cube,
        position: @math3d.Vec3::zero(),
        scale: @math3d.Vec3::one(),
        color_hex: 0xFFFFFF,
      },
    ],
    sculpt_layers: [],
  }
  let selection : ModelSelection? = Some({
    kind: PrimitiveSelection,
    target_id: "box",
  })
  let ray : WorldRay = {
    origin: @math3d.Vec3::new(0.85, 0.0, 2.0),
    direction: @math3d.Vec3::new(0.0, 0.0, -1.0),
  }
  match pick_selected_primitive_gizmo_handle(doc, selection, ray) {
    Some(hit) => {
      assert_eq(hit.target_id, "box")
      match hit.axis {
        GizmoAxisX => ()
        GizmoAxisY => fail("expected x axis gizmo handle")
        GizmoAxisZ => fail("expected x axis gizmo handle")
      }
    }
    None => fail("expected x axis gizmo hit")
  }
}

///|
test "apply_gizmo_drag moves the selected primitive along the chosen axis" {
  let doc : ModelDocument = {
    name: "gizmo-drag",
    notes: "",
    primitives: [
      {
        id: "box",
        kind: Cube,
        position: @math3d.Vec3::zero(),
        scale: @math3d.Vec3::one(),
        color_hex: 0xFFFFFF,
      },
    ],
    sculpt_layers: [],
  }
  let handle_hit : GizmoHandleHit = {
    target_id: "box",
    axis: GizmoAxisX,
    distance: 1.0,
    point: @math3d.Vec3::new(0.85, 0.0, 0.0),
  }
  match begin_gizmo_drag(doc, handle_hit, @math3d.Vec3::new(0.0, 0.0, -1.0)) {
    Some(drag) => {
      let ray : WorldRay = {
        origin: @math3d.Vec3::new(1.15, 0.0, 2.0),
        direction: @math3d.Vec3::new(0.0, 0.0, -1.0),
      }
      let moved = apply_gizmo_drag(doc, drag, ray)
      let box = moved.primitives[0]
      assert_true(
        box.position.approx_eq(@math3d.Vec3::new(0.3, 0.0, 0.0), 1.0e-6),
      )
    }
    None => fail("expected gizmo drag state")
  }
}
