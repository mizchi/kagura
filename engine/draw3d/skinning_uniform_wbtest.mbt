///|
// Append-based ABI oracle, independent of the production offset writer.
fn append_test_matrices(
  words : Array[Int],
  matrices : Array[@math3d.Mat4],
) -> Unit {
  for i in 0..<64 {
    for j in 0..<16 {
      words.push(
        if i < matrices.length() {
          f32(matrices[i].elements[j])
        } else {
          0
        },
      )
    }
  }
}

///|
fn test_skin_matrices(count : Int) -> Array[@math3d.Mat4] {
  Array::makei(count, i => {
    @math3d.Mat4::translation(i.to_double() * 0.037, -0.25, 1.7).multiply(
      @math3d.Mat4::scaling(0.6, 1.1, 1.3),
    )
  })
}

///|
test "matrix uniform writer preserves offset boundaries and f32 bits" {
  let matrix = test_skin_matrices(2)[1]
  let words = Array::make(24, 17)
  write_mat4_uniform_dwords(words, 4, matrix)
  assert_eq(words[:4].to_array(), [17, 17, 17, 17])
  assert_eq(words[4:20].to_array(), mat4_to_uniform_dwords(matrix))
  assert_eq(words[20:].to_array(), [17, 17, 17, 17])
}

///|
test "skinned draw uniform ABI matches append encoding including empty and excess bones" {
  let model = test_skin_matrices(2)[1]
  let vp = @math3d.Mat4::perspective(0.7, 1.4, 0.1, 700.0)
  let light = @light3d.LightingEnvironment::default()
  for count in [0, 1, 18, 63, 64, 65] {
    let bones = test_skin_matrices(count)
    let expected = lit_uniform_dwords(model, vp, light)
    expected.append([f32(count.to_double()), 0, 0, 0])
    append_test_matrices(expected, bones)
    let command = new_skinned_lit_mesh_draw_command(
      @gfx.new_image_handle(1, 800, 600),
      @gfx.new_shader_handle(1, "skin"),
      @gfx.new_dst_region(0, 0, 800, 600, 3),
      0,
      0,
      0,
      @gfx.BlendMode::from_int(0),
      [],
      [0, 1, 2],
      model,
      vp,
      light,
      bones,
      [],
    )
    assert_eq(command.uniform_dwords, expected)
    assert_eq(command.uniform_dwords.length(), 1084)
  }
}

///|
test "monochrome skinned uniform ABI preserves palette instances color and zero padding" {
  let vp = @math3d.Mat4::perspective(0.7, 1.4, 0.1, 700.0)
  let light = @light3d.LightingEnvironment::default()
  let color = @math3d.Vec4::new(0.3, 0.6, 0.9, 0.75)
  for bone_count in [0, 1, 18, 64, 65] {
    let bones = test_skin_matrices(bone_count)
    for instance_count in [0, 1, 8, 64, 65] {
      let models = test_skin_matrices(instance_count)
      let expected = mat4_to_uniform_dwords(vp)
      expected.append(@light3d.light_uniform_dwords(light))
      expected.append([f32(bone_count.min(64).to_double()), 0, 0, 0])
      append_test_matrices(expected, bones)
      expected.append([f32(instance_count.min(64).to_double()), 0, 0, 0])
      expected.append([f32(color.x), f32(color.y), f32(color.z), f32(color.w)])
      append_test_matrices(expected, models)
      let actual = skinned_instanced_monochrome_lit_uniform_dwords(
        vp, light, bones, models, color,
      )
      assert_eq(actual, expected)
      assert_eq(actual.length(), 2088)
      // Returned storage belongs to the command, not to a shared scratch buffer.
      let next = skinned_instanced_monochrome_lit_uniform_dwords(
        vp,
        light,
        [],
        [],
        color,
      )
      next[0] = 7
      assert_eq(actual, expected)
    }
  }
}
