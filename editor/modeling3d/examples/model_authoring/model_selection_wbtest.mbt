///|
test "selection_from_surface_hit maps primitive hits to primitive selections" {
  let hit : @modeling3d.SurfaceHit = {
    kind: @modeling3d.SurfaceKind::PrimitiveSurface,
    target_id: "pedestal",
    distance: 1.2,
    point: @math3d.Vec3::new(0.0, 0.0, 0.0),
  }
  match @modeling3d.selection_from_surface_hit(Some(hit)) {
    Some(selection) => {
      assert_eq(selection.target_id, "pedestal")
      match selection.kind {
        @modeling3d.ModelSelectionKind::PrimitiveSelection => ()
        @modeling3d.ModelSelectionKind::SculptLayerSelection =>
          fail("expected primitive selection")
      }
    }
    None => fail("expected primitive selection")
  }
}

///|
test "resolve_active_sculpt_layer_index prefers hovered sculpt surface" {
  let doc : @modeling3d.ModelDocument = {
    name: "multi-layer",
    notes: "",
    primitives: [],
    sculpt_layers: [
      {
        id: "head",
        voxel_size: 0.2,
        half_extent: 1,
        color_hex: 0xFFAA88,
        muted_stamp_ids: [],
        stamps: [
          {
            id: "a",
            mode: @modeling3d.SculptMode::Add,
            center: @math3d.Vec3::zero(),
            radius: 0.3,
          },
        ],
      },
      {
        id: "horns",
        voxel_size: 0.2,
        half_extent: 1,
        color_hex: 0xCC8844,
        muted_stamp_ids: [],
        stamps: [
          {
            id: "b",
            mode: @modeling3d.SculptMode::Add,
            center: @math3d.Vec3::new(0.0, 0.5, 0.0),
            radius: 0.2,
          },
        ],
      },
    ],
  }
  let selected : @modeling3d.ModelSelection = {
    kind: @modeling3d.ModelSelectionKind::SculptLayerSelection,
    target_id: "head",
  }
  let hover_hit : @modeling3d.SurfaceHit = {
    kind: @modeling3d.SurfaceKind::BakedSculptSurface,
    target_id: "horns",
    distance: 0.4,
    point: @math3d.Vec3::new(0.0, 0.5, 0.1),
  }
  match
    @modeling3d.resolve_active_sculpt_layer_index(
      doc,
      Some(selected),
      Some(hover_hit),
    ) {
    Some(index) => assert_eq(index, 1)
    None => fail("expected hovered sculpt layer to become active")
  }
}

///|
test "selection_from_surface_hit maps baked sculpt hits to sculpt selections" {
  let hit : @modeling3d.SurfaceHit = {
    kind: @modeling3d.SurfaceKind::BakedSculptSurface,
    target_id: "clay_head",
    distance: 0.6,
    point: @math3d.Vec3::new(0.0, 0.8, 0.2),
  }
  match @modeling3d.selection_from_surface_hit(Some(hit)) {
    Some(selection) => {
      assert_eq(selection.target_id, "clay_head")
      match selection.kind {
        @modeling3d.ModelSelectionKind::SculptLayerSelection => ()
        @modeling3d.ModelSelectionKind::PrimitiveSelection =>
          fail("expected sculpt layer selection")
      }
    }
    None => fail("expected sculpt layer selection")
  }
}

///|
test "resolve_active_sculpt_layer_index falls back to selected sculpt layer" {
  let doc = default_model_document()
  let selected : @modeling3d.ModelSelection = {
    kind: @modeling3d.ModelSelectionKind::SculptLayerSelection,
    target_id: "clay_head",
  }
  let hover_hit : @modeling3d.SurfaceHit = {
    kind: @modeling3d.SurfaceKind::PrimitiveSurface,
    target_id: "pedestal",
    distance: 0.5,
    point: @math3d.Vec3::new(0.0, 0.0, 0.0),
  }
  match
    @modeling3d.resolve_active_sculpt_layer_index(
      doc,
      Some(selected),
      Some(hover_hit),
    ) {
    Some(index) => assert_eq(index, 0)
    None => fail("expected selected sculpt layer to stay active")
  }
}

///|
test "resolve_active_sculpt_layer_index falls back to first sculpt layer" {
  let doc = default_model_document()
  match @modeling3d.resolve_active_sculpt_layer_index(doc, None, None) {
    Some(index) => assert_eq(index, 0)
    None => fail("expected first sculpt layer fallback")
  }
}

///|
test "default_selection starts from the first sculpt layer" {
  let doc = default_model_document()
  match @modeling3d.default_selection(doc) {
    Some(selection) => {
      assert_eq(selection.target_id, "clay_head")
      match selection.kind {
        @modeling3d.ModelSelectionKind::SculptLayerSelection => ()
        @modeling3d.ModelSelectionKind::PrimitiveSelection =>
          fail("expected sculpt layer default selection")
      }
    }
    None => fail("expected initial sculpt layer selection")
  }
}

///|
test "recent_sculpt_history returns newest stamps first with limit" {
  let doc = default_model_document()
  let history = @modeling3d.recent_sculpt_history(doc, 0, 3)
  assert_eq(history.length(), 3)
  assert_eq(history[0].stamp_id, "mouth_cut")
  assert_true(history[0].enabled)
  match history[0].mode {
    Subtract => ()
    @modeling3d.SculptMode::Add =>
      fail("expected newest history item to keep subtract mode")
  }
  assert_eq(history[1].stamp_id, "right_eye_socket")
  assert_eq(history[2].stamp_id, "left_eye_socket")
}
