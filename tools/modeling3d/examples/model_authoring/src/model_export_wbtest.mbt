///|
fn assert_vec4_approx_eq(
  actual : @math3d.Vec4,
  expected : @math3d.Vec4,
  epsilon : Double,
) -> Unit raise {
  assert_true((actual.x - expected.x).abs() <= epsilon)
  assert_true((actual.y - expected.y).abs() <= epsilon)
  assert_true((actual.z - expected.z).abs() <= epsilon)
  assert_true((actual.w - expected.w).abs() <= epsilon)
}

///|
test "document_glb_bytes round-trips default document as scene graph" {
  let doc = default_model_document()
  let glb = document_glb_bytes(doc)
  let (json, buffers) = @gltf.parse_glb(glb)
  let graph = @gltf.scene_graph_from_gltf(json, buffers)

  let ground = graph.get_node(0).unwrap()
  let pedestal = graph.get_node(1).unwrap()
  let guide_orb = graph.get_node(2).unwrap()
  let sculpt = graph.get_node(3).unwrap()

  assert_true(
    ground.transform.position.approx_eq(doc.primitives[0].position, 1.0e-6),
  )
  assert_true(ground.transform.scale.approx_eq(doc.primitives[0].scale, 1.0e-6))
  assert_vec4_approx_eq(
    ground.color,
    hex_to_vec4(doc.primitives[0].color_hex),
    1.0e-6,
  )

  assert_true(
    pedestal.transform.position.approx_eq(doc.primitives[1].position, 1.0e-6),
  )
  assert_true(
    pedestal.transform.scale.approx_eq(doc.primitives[1].scale, 1.0e-6),
  )
  assert_eq(
    pedestal.mesh.unwrap().triangle_count(),
    primitive_mesh(doc.primitives[1].kind).triangle_count(),
  )

  assert_true(
    guide_orb.transform.position.approx_eq(doc.primitives[2].position, 1.0e-6),
  )
  assert_true(
    guide_orb.transform.scale.approx_eq(doc.primitives[2].scale, 1.0e-6),
  )
  assert_eq(
    guide_orb.mesh.unwrap().triangle_count(),
    primitive_mesh(doc.primitives[2].kind).triangle_count(),
  )

  assert_true(sculpt.transform.position.approx_eq(@math3d.Vec3::zero(), 1.0e-6))
  assert_true(sculpt.transform.scale.approx_eq(@math3d.Vec3::one(), 1.0e-6))
  assert_eq(
    sculpt.mesh.unwrap().triangle_count(),
    sculpt_layer_baked_mesh(doc.sculpt_layers[0]).triangle_count(),
  )
  assert_vec4_approx_eq(
    sculpt.color,
    hex_to_vec4(doc.sculpt_layers[0].color_hex),
    1.0e-6,
  )
}

///|
test "document_export_filename normalizes unsafe characters" {
  let doc = { ..default_model_document(), name: "My Clay Totem / v1?" }
  assert_eq(document_export_filename(doc), "My-Clay-Totem-_-v1_.glb")
}

///|
test "document_glb_bytes includes kagura extras for round-trip metadata" {
  let doc = default_model_document()
  let glb = document_glb_bytes(doc)
  let (json, _buffers) = @gltf.parse_glb(glb)

  assert_true(json.contains("\"generator\":\"kagura-model-authoring\""))
  assert_true(
    json.contains("\"extras\":{\"kagura_document_name\":\"vlm_clay_totem\""),
  )
  assert_true(json.contains("\"kagura_node_kind\":\"primitive\""))
  assert_true(json.contains("\"kagura_node_kind\":\"sculpt_layer\""))
  assert_true(json.contains("\"kagura_source_id\":\"pedestal\""))
  assert_true(json.contains("\"kagura_primitive_kind\":\"cube\""))
  assert_true(json.contains("\"kagura_stamp_count\":6"))
  assert_true(json.contains("\"doubleSided\":true"))
}
