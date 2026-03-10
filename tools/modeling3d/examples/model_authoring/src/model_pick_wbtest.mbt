///|
fn approx_pick(a : Double, b : Double) -> Bool {
  (a - b).abs() < 1.0e-6
}

///|
test "pick_document_surface_hit resolves primitive sphere hits" {
  let doc : ModelDocument = {
    name: "primitive-hit",
    notes: "",
    primitives: [
      {
        id: "ball",
        kind: Sphere,
        position: @math3d.Vec3::zero(),
        scale: @math3d.Vec3::new(1.0, 1.0, 1.0),
        color_hex: 0xFFFFFF,
      },
    ],
    sculpt_layers: [],
  }
  let ray : WorldRay = {
    origin: @math3d.Vec3::new(0.0, 0.0, 2.0),
    direction: @math3d.Vec3::new(0.0, 0.0, -1.0),
  }
  match pick_document_surface_hit(doc, ray) {
    Some(hit) => {
      assert_eq(hit.target_id, "ball")
      assert_true(approx_pick(hit.point.z, 0.5))
      match hit.kind {
        PrimitiveSurface => ()
        SculptSurface => fail("expected primitive surface hit")
        BakedSculptSurface => fail("expected primitive surface hit")
      }
    }
    None => fail("expected sphere hit")
  }
}

///|
test "pick_document_surface_hit ignores plane primitives for sculpt editing" {
  let doc : ModelDocument = {
    name: "plane-only",
    notes: "",
    primitives: [
      {
        id: "ground",
        kind: Plane,
        position: @math3d.Vec3::zero(),
        scale: @math3d.Vec3::new(10.0, 1.0, 10.0),
        color_hex: 0xFFFFFF,
      },
    ],
    sculpt_layers: [],
  }
  let ray : WorldRay = {
    origin: @math3d.Vec3::new(0.0, 5.0, 0.0),
    direction: @math3d.Vec3::new(0.0, -1.0, 0.0),
  }
  assert_true(pick_document_surface_hit(doc, ray) is None)
}

///|
test "pick_document_surface_hit resolves voxel sculpt hits" {
  let doc : ModelDocument = {
    name: "sculpt-hit",
    notes: "",
    primitives: [],
    sculpt_layers: [
      {
        id: "clay_head",
        voxel_size: 0.2,
        half_extent: 1,
        color_hex: 0xFFAA88,
        muted_stamp_ids: [],
        stamps: [
          { id: "core", mode: Add, center: @math3d.Vec3::zero(), radius: 0.35 },
        ],
      },
    ],
  }
  let ray : WorldRay = {
    origin: @math3d.Vec3::new(0.0, 0.0, 2.0),
    direction: @math3d.Vec3::new(0.0, 0.0, -1.0),
  }
  match pick_document_surface_hit(doc, ray) {
    Some(hit) => {
      assert_eq(hit.target_id, "clay_head")
      assert_true(hit.point.z > 0.0)
      assert_true(hit.point.z < 0.4)
      match hit.kind {
        PrimitiveSurface => fail("expected sculpt surface hit")
        SculptSurface => fail("expected baked sculpt surface hit")
        BakedSculptSurface => ()
      }
    }
    None => fail("expected sculpt voxel hit")
  }
}

///|
test "pick_document_surface_hit chooses the nearest surface" {
  let doc : ModelDocument = {
    name: "nearest",
    notes: "",
    primitives: [
      {
        id: "far_ball",
        kind: Sphere,
        position: @math3d.Vec3::new(0.0, 0.0, -2.0),
        scale: @math3d.Vec3::new(1.0, 1.0, 1.0),
        color_hex: 0xFFFFFF,
      },
    ],
    sculpt_layers: [
      {
        id: "near_clay",
        voxel_size: 0.2,
        half_extent: 1,
        color_hex: 0xFFAA88,
        muted_stamp_ids: [],
        stamps: [
          { id: "core", mode: Add, center: @math3d.Vec3::zero(), radius: 0.35 },
        ],
      },
    ],
  }
  let ray : WorldRay = {
    origin: @math3d.Vec3::new(0.0, 0.0, 2.0),
    direction: @math3d.Vec3::new(0.0, 0.0, -1.0),
  }
  match pick_document_surface_hit(doc, ray) {
    Some(hit) => {
      assert_eq(hit.target_id, "near_clay")
      assert_true(hit.distance < 2.0)
    }
    None => fail("expected nearest hit")
  }
}
