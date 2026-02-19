///|
fn shader_unit_to_int(unit : ShaderUnit) -> Int {
  match unit {
    ShaderUnit::Pixels => 0
    ShaderUnit::Texels => 1
  }
}

///|
test "basic shader frontend compiles and hashes source" {
  let frontend = new_basic_shader_frontend()
  let request = {
    source: "@fragment fn main() -> vec4f { return vec4f(1.0); }",
    unit_hint: Some(ShaderUnit::Pixels),
    src_image_count: 1,
    entrypoints: { vertex: "vs_main", fragment: "fs_main" },
    debug_name: "smoke",
  }
  let ir = frontend.compile_ir(request)
  let hash = frontend.calc_source_hash(request)
  assert_eq(ir.debug_name, "smoke")
  assert_eq(ir.source_hash.value, hash.value)
}

///|
test "basic canonicalizer packs and prepends uniforms" {
  let canonicalizer = new_basic_uniform_canonicalizer()
  let ir : ShaderIR = {
    source: "fn main() { let _ = u_a + u_b; }",
    unit: ShaderUnit::Pixels,
    src_image_count: 1,
    entrypoints: { vertex: "v", fragment: "f" },
    debug_name: "x",
    source_hash: { value: "1" },
  }
  let packed = build_canonical_uniforms(
    canonicalizer,
    { names: ["u_a", "u_b"], dword_counts: [1, 2], preserved_prefix_dwords: 0 },
    [
      { name: "u_a", value: UniformValue::Int(7) },
      { name: "u_b", value: UniformValue::Floats([1.0, 2.0]) },
    ],
    {
      dst_texture_size: { width: 320, height: 240 },
      dst_region: { x: 0.0, y: 0.0, width: 320.0, height: 240.0 },
      src_texture_sizes: [],
      src_regions: [],
    },
    ir,
  )
  assert_eq(packed.dwords.length(), 3)
  assert_eq(packed.dwords[0], 7)
  assert_eq(packed.dwords[1], 1)
  assert_eq(packed.dwords[2], 2)
}

///|
test "hash includes entrypoints and unit to avoid collisions" {
  let frontend = new_basic_shader_frontend()
  let source = "@fragment fn main() -> vec4f { return vec4f(1.0); }"
  let src_image_count = 1
  let debug_name = "same"
  let request_a : ShaderCompileRequest = {
    source,
    unit_hint: Some(ShaderUnit::Pixels),
    src_image_count,
    entrypoints: { vertex: "vs_a", fragment: "fs_a" },
    debug_name,
  }
  let request_b : ShaderCompileRequest = {
    source,
    unit_hint: Some(ShaderUnit::Texels),
    src_image_count,
    entrypoints: { vertex: "vs_b", fragment: "fs_b" },
    debug_name,
  }
  let hash_a = calc_shader_source_hash(frontend, request_a)
  let hash_b = calc_shader_source_hash(frontend, request_b)
  assert_true(hash_a.value != hash_b.value)
}

///|
test "kage unit directive overrides unit hint and stabilizes hash" {
  let frontend = new_basic_shader_frontend()
  let source = "//kage:unit texels\n@fragment fn main() -> vec4f { return vec4f(1.0); }"
  let request_pixels_hint : ShaderCompileRequest = {
    source,
    unit_hint: Some(ShaderUnit::Pixels),
    src_image_count: 0,
    entrypoints: { vertex: "vs_main", fragment: "fs_main" },
    debug_name: "kage_unit",
  }
  let request_texels_hint : ShaderCompileRequest = {
    source,
    unit_hint: Some(ShaderUnit::Texels),
    src_image_count: 0,
    entrypoints: { vertex: "vs_main", fragment: "fs_main" },
    debug_name: "kage_unit",
  }
  let ir = compile_shader_ir(frontend, request_pixels_hint)
  let hash_a = calc_shader_source_hash(frontend, request_pixels_hint)
  let hash_b = calc_shader_source_hash(frontend, request_texels_hint)
  assert_eq(shader_unit_to_int(ir.unit), 1)
  assert_true(ir.source.contains("// unit:texels"))
  assert_eq(hash_a.value, hash_b.value)
}

///|
test "invalid kage unit directive falls back to hint and default" {
  let frontend = new_basic_shader_frontend()
  let source = "//kage:unit unknown\n@fragment fn main() -> vec4f { return vec4f(1.0); }"
  let request_with_hint : ShaderCompileRequest = {
    source,
    unit_hint: Some(ShaderUnit::Texels),
    src_image_count: 0,
    entrypoints: { vertex: "vs_main", fragment: "fs_main" },
    debug_name: "kage_invalid_hint",
  }
  let request_default : ShaderCompileRequest = {
    source,
    unit_hint: None,
    src_image_count: 0,
    entrypoints: { vertex: "vs_main", fragment: "fs_main" },
    debug_name: "kage_invalid_default",
  }
  let ir_with_hint = compile_shader_ir(frontend, request_with_hint)
  let ir_default = compile_shader_ir(frontend, request_default)
  assert_eq(shader_unit_to_int(ir_with_hint.unit), 1)
  assert_eq(shader_unit_to_int(ir_default.unit), 0)
}

///|
test "compile_ir preprocesses source with runtime metadata header" {
  let frontend = new_basic_shader_frontend()
  let request : ShaderCompileRequest = {
    source: "@fragment fn main() -> vec4f { return vec4f(1.0); }",
    unit_hint: Some(ShaderUnit::Pixels),
    src_image_count: 0,
    entrypoints: { vertex: "vs_main", fragment: "fs_main" },
    debug_name: "preprocess",
  }
  let ir = compile_shader_ir(frontend, request)
  assert_true(ir.source != request.source)
}

///|
test "canonical uniforms length follows uniform layout contract" {
  let canonicalizer = new_basic_uniform_canonicalizer()
  let ir : ShaderIR = {
    source: "x",
    unit: ShaderUnit::Pixels,
    src_image_count: 1,
    entrypoints: { vertex: "v", fragment: "f" },
    debug_name: "x",
    source_hash: { value: "1" },
  }
  let packed = build_canonical_uniforms(
    canonicalizer,
    { names: ["u_a", "u_b"], dword_counts: [1, 2], preserved_prefix_dwords: 2 },
    [
      { name: "u_a", value: UniformValue::Int(7) },
      { name: "u_b", value: UniformValue::Floats([1.0, 2.0]) },
    ],
    {
      dst_texture_size: { width: 320, height: 240 },
      dst_region: { x: 0.0, y: 0.0, width: 320.0, height: 240.0 },
      src_texture_sizes: [],
      src_regions: [],
    },
    ir,
  )
  assert_eq(packed.dwords.length(), 5)
}

///|
test "unused uniforms are zeroed while preserved prefix is kept" {
  let canonicalizer = new_basic_uniform_canonicalizer()
  let ir : ShaderIR = {
    source: "fn main() { let _ = u_used; }",
    unit: ShaderUnit::Pixels,
    src_image_count: 1,
    entrypoints: { vertex: "v", fragment: "f" },
    debug_name: "x",
    source_hash: { value: "1" },
  }
  let packed = build_canonical_uniforms(
    canonicalizer,
    {
      names: ["u_used", "u_unused"],
      dword_counts: [1, 2],
      preserved_prefix_dwords: 2,
    },
    [
      { name: "u_used", value: UniformValue::Int(7) },
      { name: "u_unused", value: UniformValue::Ints([9, 10]) },
    ],
    {
      dst_texture_size: { width: 320, height: 240 },
      dst_region: { x: 0.0, y: 0.0, width: 320.0, height: 240.0 },
      src_texture_sizes: [],
      src_regions: [],
    },
    ir,
  )
  assert_eq(packed.dwords.length(), 5)
  assert_eq(packed.dwords[0], 320)
  assert_eq(packed.dwords[1], 240)
  assert_eq(packed.dwords[2], 7)
  assert_eq(packed.dwords[3], 0)
  assert_eq(packed.dwords[4], 0)
}

///|
test "unused filter matches uniform names by identifier boundary" {
  let canonicalizer = new_basic_uniform_canonicalizer()
  let ir : ShaderIR = {
    source: "fn main() { let _ = u_ab; }",
    unit: ShaderUnit::Pixels,
    src_image_count: 1,
    entrypoints: { vertex: "v", fragment: "f" },
    debug_name: "x",
    source_hash: { value: "1" },
  }
  let packed = build_canonical_uniforms(
    canonicalizer,
    { names: ["u_a", "u_ab"], dword_counts: [1, 1], preserved_prefix_dwords: 0 },
    [
      { name: "u_a", value: UniformValue::Int(1) },
      { name: "u_ab", value: UniformValue::Int(2) },
    ],
    {
      dst_texture_size: { width: 1, height: 1 },
      dst_region: { x: 0.0, y: 0.0, width: 1.0, height: 1.0 },
      src_texture_sizes: [],
      src_regions: [],
    },
    ir,
  )
  assert_eq(packed.dwords.length(), 2)
  assert_eq(packed.dwords[0], 0)
  assert_eq(packed.dwords[1], 2)
}

///|
test "builtin shader source differs by filter address and color_m" {
  let repo = new_basic_builtin_shader_source_repo()
  let nearest = repo.shader_source({
    filter: BuiltinShaderFilter::Nearest,
    address: BuiltinShaderAddress::Unsafe,
    use_color_m: false,
  })
  let linear = repo.shader_source({
    filter: BuiltinShaderFilter::Linear,
    address: BuiltinShaderAddress::Unsafe,
    use_color_m: false,
  })
  let repeat = repo.shader_source({
    filter: BuiltinShaderFilter::Nearest,
    address: BuiltinShaderAddress::Repeat,
    use_color_m: false,
  })
  let color_m = repo.shader_source({
    filter: BuiltinShaderFilter::Nearest,
    address: BuiltinShaderAddress::Unsafe,
    use_color_m: true,
  })
  assert_true(nearest != linear)
  assert_true(nearest != repeat)
  assert_true(nearest != color_m)
  assert_true(color_m.contains("color_m:on"))
}

///|
test "builtin shader source repo caches entries and can clear cache" {
  let repo = new_basic_builtin_shader_source_repo()
  let key : BuiltinShaderKey = {
    filter: BuiltinShaderFilter::Nearest,
    address: BuiltinShaderAddress::Unsafe,
    use_color_m: false,
  }
  assert_eq(builtin_shader_source_cache_size(repo), 0)
  let first = repo.shader_source(key)
  let second = repo.shader_source(key)
  assert_eq(first, second)
  assert_eq(builtin_shader_source_cache_size(repo), 1)

  clear_builtin_shader_source_cache(repo)
  assert_eq(builtin_shader_source_cache_size(repo), 0)
}

///|
test "builtin shader source repo evicts old entries over cache limit" {
  let repo = new_basic_builtin_shader_source_repo()
  let keys : Array[BuiltinShaderKey] = [
    {
      filter: BuiltinShaderFilter::Nearest,
      address: BuiltinShaderAddress::Unsafe,
      use_color_m: false,
    },
    {
      filter: BuiltinShaderFilter::Nearest,
      address: BuiltinShaderAddress::Unsafe,
      use_color_m: true,
    },
    {
      filter: BuiltinShaderFilter::Nearest,
      address: BuiltinShaderAddress::ClampToZero,
      use_color_m: false,
    },
    {
      filter: BuiltinShaderFilter::Nearest,
      address: BuiltinShaderAddress::ClampToZero,
      use_color_m: true,
    },
    {
      filter: BuiltinShaderFilter::Nearest,
      address: BuiltinShaderAddress::Repeat,
      use_color_m: false,
    },
    {
      filter: BuiltinShaderFilter::Nearest,
      address: BuiltinShaderAddress::Repeat,
      use_color_m: true,
    },
    {
      filter: BuiltinShaderFilter::Linear,
      address: BuiltinShaderAddress::Unsafe,
      use_color_m: false,
    },
    {
      filter: BuiltinShaderFilter::Linear,
      address: BuiltinShaderAddress::Unsafe,
      use_color_m: true,
    },
    {
      filter: BuiltinShaderFilter::Linear,
      address: BuiltinShaderAddress::Repeat,
      use_color_m: false,
    },
  ]
  for key in keys {
    let _ = repo.shader_source(key)
  }
  assert_true(
    builtin_shader_source_cache_size(repo) <=
    builtin_shader_source_cache_limit(repo),
  )
}
