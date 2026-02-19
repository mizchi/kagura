///|
fn expect_some_image(
  value : @gfx.ImageHandle?,
  expected_id : Int,
  expected_width : Int,
  expected_height : Int,
) -> Unit raise {
  match value {
    Some(image) => {
      assert_eq(image.id, expected_id)
      assert_eq(image.width, expected_width)
      assert_eq(image.height, expected_height)
    }
    None => panic()
  }
}

///|
fn expect_some_shader(
  value : @gfx.ShaderHandle?,
  expected_id : Int,
  expected_source : String,
) -> Unit raise {
  match value {
    Some(shader) => {
      assert_eq(shader.id, expected_id)
      assert_eq(shader.source, expected_source)
    }
    None => panic()
  }
}

///|
test "simple image repository can create get and remove images" {
  let repo = new_simple_image_repository()
  let key : AssetKey = { value: "player" }
  let spec = default_image_spec(32, 16)
  let handle = repo.create_image(key, spec)

  assert_eq(handle.id, 1)
  assert_eq(handle.width, 32)
  assert_eq(handle.height, 16)
  expect_some_image(repo.get_image(key), 1, 32, 16)

  repo.remove_image(key)
  match repo.get_image(key) {
    Some(_) => panic()
    None => ()
  }
}

///|
test "simple image repository reuses handle for duplicate keys" {
  let repo = new_simple_image_repository()
  let key : AssetKey = { value: "player" }
  let first = repo.create_image(key, default_image_spec(32, 16))
  let second = repo.create_image(key, default_image_spec(64, 64))

  assert_eq(first.id, second.id)
  expect_some_image(repo.get_image(key), first.id, 32, 16)
}

///|
test "simple atlas allocator places regions with row wrap" {
  let allocator = new_simple_atlas_allocator(8, 8, 1)

  let first = match allocator.allocate(4, 4) {
    Some(region) => region
    None => panic()
  }
  assert_eq(first.x, 0)
  assert_eq(first.y, 0)

  let second = match allocator.allocate(4, 4) {
    Some(region) => region
    None => panic()
  }
  assert_eq(second.x, 4)
  assert_eq(second.y, 0)

  let third = match allocator.allocate(4, 4) {
    Some(region) => region
    None => panic()
  }
  assert_eq(third.x, 0)
  assert_eq(third.y, 4)
}

///|
test "simple atlas allocator returns none when out of capacity" {
  let allocator = new_simple_atlas_allocator(8, 8, 1)

  match allocator.allocate(9, 1) {
    Some(_) => panic()
    None => ()
  }

  let whole = match allocator.allocate(8, 8) {
    Some(region) => region
    None => panic()
  }

  match allocator.allocate(1, 1) {
    Some(_) => panic()
    None => ()
  }

  allocator.release(whole)
  assert_eq(allocator.allocated.length(), 0)
}

///|
test "simple shader repository can create get and remove shaders" {
  let repo = new_simple_shader_repository()
  let key : AssetKey = { value: "lighting" }
  let spec : ShaderSpec = {
    debug_name: "lighting",
    source: "@fragment fn fs_main() -> vec4f { return vec4f(1.0); }",
  }
  let handle = repo.create_shader(key, spec)
  assert_eq(handle.id, 1)
  assert_eq(handle.source, spec.source)
  expect_some_shader(repo.get_shader(key), 1, spec.source)

  repo.remove_shader(key)
  match repo.get_shader(key) {
    Some(_) => panic()
    None => ()
  }
}

///|
test "simple shader repository reuses handle for duplicate keys" {
  let repo = new_simple_shader_repository()
  let key : AssetKey = { value: "lighting" }
  let first = repo.create_shader(key, {
    debug_name: "lighting_a",
    source: "shader_a",
  })
  let second = repo.create_shader(key, {
    debug_name: "lighting_b",
    source: "shader_b",
  })
  assert_eq(first.id, second.id)
  expect_some_shader(repo.get_shader(key), first.id, "shader_a")
}

///|
test "simple material repository registers and overwrites material specs" {
  let repo = new_simple_material_repository()
  let key : AssetKey = { value: "sprite" }
  let shader_key : AssetKey = { value: "shader/sprite" }
  repo.register_material(key, {
    shader: shader_key,
    blend: @gfx.blend_mode_from_int(1),
    filter: @gfx.filter_mode_from_int(0),
    uniform_keys: ["u_color"],
  })
  match repo.get_material(key) {
    Some(spec) => {
      assert_eq(spec.shader.value, "shader/sprite")
      assert_eq(spec.uniform_keys.length(), 1)
      assert_eq(spec.uniform_keys[0], "u_color")
      assert_eq(@gfx.blend_mode_to_int(spec.blend), 1)
    }
    None => panic()
  }

  repo.register_material(key, {
    shader: shader_key,
    blend: @gfx.blend_mode_from_int(2),
    filter: @gfx.filter_mode_from_int(1),
    uniform_keys: ["u_color", "u_alpha"],
  })
  match repo.get_material(key) {
    Some(spec2) => {
      assert_eq(@gfx.blend_mode_to_int(spec2.blend), 2)
      assert_eq(spec2.uniform_keys.length(), 2)
      assert_eq(spec2.uniform_keys[1], "u_alpha")
    }
    None => panic()
  }
}
