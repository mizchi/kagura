///|
test "toggle_recent_sculpt_stamp_muted flips enabled state in history order" {
  let doc = default_model_document()
  let toggled = toggle_recent_sculpt_stamp_muted(doc, 0, 0)
  let history = recent_sculpt_history(toggled, 0, 2)

  assert_eq(history.length(), 2)
  assert_eq(history[0].stamp_id, "mouth_cut")
  assert_false(history[0].enabled)
  assert_true(history[1].enabled)
}

///|
test "muted stamps are ignored by sculpt sampling" {
  let doc : ModelDocument = {
    name: "mute-sampling",
    notes: "",
    primitives: [],
    sculpt_layers: [
      {
        id: "clay",
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
  let layer = doc.sculpt_layers[0]
  let center = @math3d.Vec3::zero()
  let toggled = toggle_recent_sculpt_stamp_muted(doc, 0, 0)
  let muted_layer = toggled.sculpt_layers[0]

  assert_true(sample_sculpt_layer(layer, center))
  assert_false(sample_sculpt_layer(muted_layer, center))
}

///|
test "undo_last_sculpt_stamp removes the newest stamp from active history" {
  let doc = default_model_document()
  let reduced = undo_last_sculpt_stamp(doc, 0)
  let history = recent_sculpt_history(reduced, 0, 3)

  assert_eq(
    reduced.sculpt_layers[0].stamps.length(),
    doc.sculpt_layers[0].stamps.length() - 1,
  )
  assert_eq(history[0].stamp_id, "right_eye_socket")
}
