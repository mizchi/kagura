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
    noperspective: false,
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
  assert_eq(packed.dwords[1], 0x3F800000) // 1.0 as f32 bits
  assert_eq(packed.dwords[2], 0x40000000) // 2.0 as f32 bits
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
    noperspective: false,
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
    noperspective: false,
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
    noperspective: false,
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
test "MirrorRepeat address tag and snippet" {
  let tag = builtin_address_tag(BuiltinShaderAddress::MirrorRepeat)
  assert_eq(tag, "mirror_repeat")
  let snippet = builtin_address_snippet(BuiltinShaderAddress::MirrorRepeat)
  assert_true(snippet.contains("mirror_repeat"))
  assert_true(snippet.contains("fract"))
  assert_true(snippet.contains("abs"))
}

///|
test "default_sampler_spec returns unsafe nearest" {
  let spec = default_sampler_spec()
  assert_true(builtin_filter_eq(spec.filter, BuiltinShaderFilter::Nearest))
  assert_true(builtin_address_eq(spec.address_u, BuiltinShaderAddress::Unsafe))
  assert_true(builtin_address_eq(spec.address_v, BuiltinShaderAddress::Unsafe))
}

///|
test "sampler_spec sets both axes" {
  let spec = sampler_spec(
    BuiltinShaderFilter::Linear,
    BuiltinShaderAddress::Repeat,
  )
  assert_true(builtin_filter_eq(spec.filter, BuiltinShaderFilter::Linear))
  assert_true(builtin_address_eq(spec.address_u, BuiltinShaderAddress::Repeat))
  assert_true(builtin_address_eq(spec.address_v, BuiltinShaderAddress::Repeat))
}

///|
test "builtin_key_to_ex converts classic to extended" {
  let key : BuiltinShaderKey = {
    filter: BuiltinShaderFilter::Linear,
    address: BuiltinShaderAddress::ClampToZero,
    use_color_m: true,
  }
  let ex = builtin_key_to_ex(key)
  assert_true(builtin_filter_eq(ex.sampler.filter, BuiltinShaderFilter::Linear))
  assert_true(
    builtin_address_eq(ex.sampler.address_u, BuiltinShaderAddress::ClampToZero),
  )
  assert_true(
    builtin_address_eq(ex.sampler.address_v, BuiltinShaderAddress::ClampToZero),
  )
  assert_eq(ex.use_color_m, true)
}

///|
test "per-axis address snippet same axes uses shared snippet" {
  let spec = sampler_spec(
    BuiltinShaderFilter::Nearest,
    BuiltinShaderAddress::Repeat,
  )
  let snippet = builtin_address_snippet_per_axis(spec)
  // Same axes: should use the shared snippet
  assert_true(snippet.contains("fract"))
  assert_true(snippet.contains("sample_uv"))
}

///|
test "per-axis address snippet different axes" {
  let spec : SamplerSpec = {
    filter: BuiltinShaderFilter::Nearest,
    address_u: BuiltinShaderAddress::Repeat,
    address_v: BuiltinShaderAddress::MirrorRepeat,
  }
  let snippet = builtin_address_snippet_per_axis(spec)
  // Different axes: should generate per-axis vec2f
  assert_true(snippet.contains("vec2f"))
  assert_true(snippet.contains("fract(uv.x)"))
  assert_true(snippet.contains("abs(fract(uv.y"))
}

///|
test "build_builtin_shader_source_ex with same axes matches classic" {
  let key : BuiltinShaderKey = {
    filter: BuiltinShaderFilter::Nearest,
    address: BuiltinShaderAddress::Repeat,
    use_color_m: false,
  }
  let ex = builtin_key_to_ex(key)
  let source_ex = build_builtin_shader_source_ex(ex)
  // Extended uses address_u/address_v header instead of single address
  assert_true(source_ex.contains("address_u:repeat"))
  assert_true(source_ex.contains("address_v:repeat"))
  assert_true(source_ex.contains("fract"))
  assert_true(source_ex.contains("fs_main"))
}

///|
test "build_builtin_shader_source_ex per-axis different" {
  let ex : BuiltinShaderKeyEx = {
    sampler: {
      filter: BuiltinShaderFilter::Linear,
      address_u: BuiltinShaderAddress::ClampToZero,
      address_v: BuiltinShaderAddress::MirrorRepeat,
    },
    use_color_m: true,
  }
  let source = build_builtin_shader_source_ex(ex)
  assert_true(source.contains("address_u:clamp_to_zero"))
  assert_true(source.contains("address_v:mirror_repeat"))
  assert_true(source.contains("vec2f"))
  assert_true(source.contains("color_m:on"))
  assert_true(source.contains("color_m * color"))
}

///|
test "builtin shader source with MirrorRepeat via repo" {
  let repo = new_basic_builtin_shader_source_repo()
  let source = repo.shader_source({
    filter: BuiltinShaderFilter::Nearest,
    address: BuiltinShaderAddress::MirrorRepeat,
    use_color_m: false,
  })
  assert_true(source.contains("mirror_repeat"))
  assert_true(source.contains("abs"))
  assert_true(source.contains("fract"))
}

///|
test "validate_shader_compile_request rejects empty source" {
  let request : ShaderCompileRequest = {
    source: "",
    unit_hint: None,
    src_image_count: 0,
    entrypoints: { vertex: "vs", fragment: "fs" },
    debug_name: "empty",
  }
  match validate_shader_compile_request(request) {
    Some(msg) => assert_true(msg.contains("source"))
    None => panic()
  }
}

///|
test "validate_shader_compile_request rejects empty vertex entrypoint" {
  let request : ShaderCompileRequest = {
    source: "fn main() {}",
    unit_hint: None,
    src_image_count: 0,
    entrypoints: { vertex: "", fragment: "fs" },
    debug_name: "no_vs",
  }
  match validate_shader_compile_request(request) {
    Some(msg) => assert_true(msg.contains("vertex"))
    None => panic()
  }
}

///|
test "validate_shader_compile_request rejects empty fragment entrypoint" {
  let request : ShaderCompileRequest = {
    source: "fn main() {}",
    unit_hint: None,
    src_image_count: 0,
    entrypoints: { vertex: "vs", fragment: "" },
    debug_name: "no_fs",
  }
  match validate_shader_compile_request(request) {
    Some(msg) => assert_true(msg.contains("fragment"))
    None => panic()
  }
}

///|
test "validate_shader_compile_request rejects negative src_image_count" {
  let request : ShaderCompileRequest = {
    source: "fn main() {}",
    unit_hint: None,
    src_image_count: -1,
    entrypoints: { vertex: "vs", fragment: "fs" },
    debug_name: "neg",
  }
  match validate_shader_compile_request(request) {
    Some(msg) => assert_true(msg.contains("negative"))
    None => panic()
  }
}

///|
test "validate_shader_compile_request accepts valid request" {
  let request : ShaderCompileRequest = {
    source: "fn main() { }",
    unit_hint: Some(ShaderUnit::Pixels),
    src_image_count: 1,
    entrypoints: { vertex: "vs_main", fragment: "fs_main" },
    debug_name: "valid",
  }
  match validate_shader_compile_request(request) {
    Some(_) => panic()
    None => ()
  }
}

///|
test "shader_unit_eq compares units" {
  assert_true(shader_unit_eq(ShaderUnit::Pixels, ShaderUnit::Pixels))
  assert_true(shader_unit_eq(ShaderUnit::Texels, ShaderUnit::Texels))
  assert_true(!shader_unit_eq(ShaderUnit::Pixels, ShaderUnit::Texels))
  assert_true(!shader_unit_eq(ShaderUnit::Texels, ShaderUnit::Pixels))
}

///|
test "shader_hash_eq compares hash values" {
  assert_true(shader_hash_eq({ value: "abc" }, { value: "abc" }))
  assert_true(!shader_hash_eq({ value: "abc" }, { value: "def" }))
}

///|
test "validate_uniform_layout rejects mismatched lengths" {
  match
    validate_uniform_layout({
      names: ["a", "b"],
      dword_counts: [1],
      preserved_prefix_dwords: 0,
    }) {
    Some(msg) => assert_true(msg.contains("length"))
    None => panic()
  }
}

///|
test "validate_uniform_layout rejects duplicate names" {
  match
    validate_uniform_layout({
      names: ["u_a", "u_b", "u_a"],
      dword_counts: [1, 1, 1],
      preserved_prefix_dwords: 0,
    }) {
    Some(msg) => assert_true(msg.contains("duplicate"))
    None => panic()
  }
}

///|
test "validate_uniform_layout rejects negative dword_counts" {
  match
    validate_uniform_layout({
      names: ["u_a"],
      dword_counts: [-2],
      preserved_prefix_dwords: 0,
    }) {
    Some(msg) => assert_true(msg.contains("negative"))
    None => panic()
  }
}

///|
test "validate_uniform_layout rejects negative preserved_prefix_dwords" {
  match
    validate_uniform_layout({
      names: [],
      dword_counts: [],
      preserved_prefix_dwords: -1,
    }) {
    Some(msg) => assert_true(msg.contains("negative"))
    None => panic()
  }
}

///|
test "validate_uniform_layout accepts valid layout" {
  match
    validate_uniform_layout({
      names: ["u_a", "u_b"],
      dword_counts: [1, 4],
      preserved_prefix_dwords: 6,
    }) {
    Some(_) => panic()
    None => ()
  }
}

///|
test "compute_expected_preserved_dwords matches context" {
  // dst_size(2) + dst_region(4) + 0 src = 6
  let ctx0 : PreservedUniformContext = {
    dst_texture_size: { width: 320, height: 240 },
    dst_region: { x: 0.0, y: 0.0, width: 320.0, height: 240.0 },
    src_texture_sizes: [],
    src_regions: [],
  }
  assert_eq(compute_expected_preserved_dwords(ctx0), 6)
  // dst(6) + 2 src * 6 = 18
  let ctx2 : PreservedUniformContext = {
    dst_texture_size: { width: 64, height: 64 },
    dst_region: { x: 0.0, y: 0.0, width: 64.0, height: 64.0 },
    src_texture_sizes: [{ width: 32, height: 32 }, { width: 16, height: 16 }],
    src_regions: [
      { x: 0.0, y: 0.0, width: 32.0, height: 32.0 },
      { x: 0.0, y: 0.0, width: 16.0, height: 16.0 },
    ],
  }
  assert_eq(compute_expected_preserved_dwords(ctx2), 18)
}

///|
test "validate_preserved_uniform_context rejects mismatched src arrays" {
  let ctx : PreservedUniformContext = {
    dst_texture_size: { width: 64, height: 64 },
    dst_region: { x: 0.0, y: 0.0, width: 64.0, height: 64.0 },
    src_texture_sizes: [{ width: 32, height: 32 }],
    src_regions: [],
  }
  match validate_preserved_uniform_context(ctx) {
    Some(msg) => assert_true(msg.contains("length"))
    None => panic()
  }
}

///|
test "validate_preserved_uniform_context rejects zero dst size" {
  let ctx : PreservedUniformContext = {
    dst_texture_size: { width: 0, height: 64 },
    dst_region: { x: 0.0, y: 0.0, width: 64.0, height: 64.0 },
    src_texture_sizes: [],
    src_regions: [],
  }
  match validate_preserved_uniform_context(ctx) {
    Some(msg) => assert_true(msg.contains("positive"))
    None => panic()
  }
}

///|
test "validate_preserved_uniform_context accepts valid context" {
  let ctx : PreservedUniformContext = {
    dst_texture_size: { width: 128, height: 128 },
    dst_region: { x: 0.0, y: 0.0, width: 128.0, height: 128.0 },
    src_texture_sizes: [{ width: 64, height: 64 }],
    src_regions: [{ x: 0.0, y: 0.0, width: 64.0, height: 64.0 }],
  }
  match validate_preserved_uniform_context(ctx) {
    Some(_) => panic()
    None => ()
  }
}

///|
test "shader_source_ex caches extended key and returns same source" {
  let repo = new_basic_builtin_shader_source_repo()
  let key : BuiltinShaderKeyEx = {
    sampler: {
      filter: BuiltinShaderFilter::Linear,
      address_u: BuiltinShaderAddress::Repeat,
      address_v: BuiltinShaderAddress::MirrorRepeat,
    },
    use_color_m: false,
  }
  let source1 = repo.shader_source_ex(key)
  let source2 = repo.shader_source_ex(key)
  assert_eq(source1, source2)
  assert_true(source1.contains("address_u:repeat"))
  assert_true(source1.contains("address_v:mirror_repeat"))
}

///|
test "shader_source_ex cache hit increments hit_count" {
  let repo = new_basic_builtin_shader_source_repo()
  let key : BuiltinShaderKeyEx = {
    sampler: default_sampler_spec(),
    use_color_m: false,
  }
  let _ = repo.shader_source_ex(key)
  let stats1 = builtin_shader_cache_stats(repo)
  assert_eq(stats1.miss_count, 1)
  assert_eq(stats1.hit_count, 0)
  let _ = repo.shader_source_ex(key)
  let stats2 = builtin_shader_cache_stats(repo)
  assert_eq(stats2.miss_count, 1)
  assert_eq(stats2.hit_count, 1)
}

///|
test "shader_source classic hit also increments hit_count" {
  let repo = new_basic_builtin_shader_source_repo()
  let key : BuiltinShaderKey = {
    filter: BuiltinShaderFilter::Nearest,
    address: BuiltinShaderAddress::Unsafe,
    use_color_m: false,
  }
  let _ = repo.shader_source(key)
  let _ = repo.shader_source(key)
  let stats = builtin_shader_cache_stats(repo)
  assert_eq(stats.miss_count, 1)
  assert_eq(stats.hit_count, 1)
}

///|
test "clear_builtin_shader_source_cache resets stats" {
  let repo = new_basic_builtin_shader_source_repo()
  let key : BuiltinShaderKeyEx = {
    sampler: default_sampler_spec(),
    use_color_m: false,
  }
  let _ = repo.shader_source_ex(key)
  let _ = repo.shader_source_ex(key)
  clear_builtin_shader_source_cache(repo)
  let stats = builtin_shader_cache_stats(repo)
  assert_eq(stats.hit_count, 0)
  assert_eq(stats.miss_count, 0)
  assert_eq(builtin_shader_source_cache_size(repo), 0)
}

///|
test "mixed classic and extended cache shares eviction pool" {
  let repo = new_basic_builtin_shader_source_repo()
  // Fill 4 classic entries
  for i in 0..<4 {
    let key : BuiltinShaderKey = {
      filter: if i % 2 == 0 {
        BuiltinShaderFilter::Nearest
      } else {
        BuiltinShaderFilter::Linear
      },
      address: if i < 2 {
        BuiltinShaderAddress::Unsafe
      } else {
        BuiltinShaderAddress::ClampToZero
      },
      use_color_m: false,
    }
    let _ = repo.shader_source(key)
  }
  // Fill 5 extended entries (total 9 > limit 8)
  let addresses = [
    BuiltinShaderAddress::Unsafe,
    BuiltinShaderAddress::ClampToZero,
    BuiltinShaderAddress::Repeat,
    BuiltinShaderAddress::MirrorRepeat,
    BuiltinShaderAddress::Unsafe,
  ]
  for i in 0..<5 {
    let key : BuiltinShaderKeyEx = {
      sampler: {
        filter: BuiltinShaderFilter::Pixelated,
        address_u: addresses[i],
        address_v: BuiltinShaderAddress::Repeat,
      },
      use_color_m: i == 4,
    }
    let _ = repo.shader_source_ex(key)
  }
  assert_true(
    builtin_shader_source_cache_size(repo) <=
    builtin_shader_source_cache_limit(repo),
  )
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

///|
test "double_to_f32_bits encodes common values" {
  assert_eq(double_to_f32_bits(0.0), 0)
  assert_eq(double_to_f32_bits(1.0), 0x3F800000)
  assert_eq(double_to_f32_bits(0.5), 0x3F000000)
  // -1.0 f32 bits = 0xBF800000 = -1082130432 signed
  assert_eq(double_to_f32_bits(-1.0), -1082130432)
}

///|
test "double_to_f32_bits handles edge cases" {
  // +infinity
  assert_eq(double_to_f32_bits(1.0 / 0.0), 0x7F800000)
  // negative zero: 0x80000000 = -2147483648 signed
  assert_eq(double_to_f32_bits(-0.0), -2147483648)
}

///|
test "f32_bits_to_double roundtrip" {
  let values : Array[Double] = [0.0, 1.0, 0.5, -1.0, 0.25, 100.0, -0.125]
  for v in values {
    let bits = double_to_f32_bits(v)
    let back = f32_bits_to_double(bits)
    assert_eq(back, v)
  }
}

///|
test "uniform_to_dwords encodes floats as f32 bits" {
  let dwords = uniform_to_dwords(UniformValue::Float(0.5))
  assert_eq(dwords.length(), 1)
  assert_eq(dwords[0], 0x3F000000)
  let dwords2 = uniform_to_dwords(UniformValue::Floats([1.0, 2.0]))
  assert_eq(dwords2.length(), 2)
  assert_eq(dwords2[0], 0x3F800000)
  assert_eq(dwords2[1], 0x40000000)
}

///|
test "ClampToEdge address snippet" {
  let source = build_builtin_shader_source({
    filter: BuiltinShaderFilter::Nearest,
    address: BuiltinShaderAddress::ClampToEdge,
    use_color_m: false,
  })
  assert_true(source.contains("clamp(uv"))
  assert_true(source.contains("clamp_to_edge"))
}

///|
test "ClampToEdge per-axis snippet" {
  let spec : SamplerSpec = {
    filter: BuiltinShaderFilter::Nearest,
    address_u: BuiltinShaderAddress::ClampToEdge,
    address_v: BuiltinShaderAddress::Repeat,
  }
  let snippet = builtin_address_snippet_per_axis(spec)
  assert_true(snippet.contains("clamp(uv.x"))
  assert_true(snippet.contains("fract(uv.y)"))
}

///|
test "builtin_filter roundtrip" {
  let filters = [
    BuiltinShaderFilter::Nearest,
    BuiltinShaderFilter::Linear,
    BuiltinShaderFilter::Pixelated,
  ]
  for f in filters {
    let i = builtin_filter_to_int(f)
    let back = builtin_filter_from_int(i)
    assert_true(builtin_filter_eq(f, back))
  }
}

///|
test "builtin_address roundtrip" {
  let addresses = [
    BuiltinShaderAddress::Unsafe,
    BuiltinShaderAddress::ClampToZero,
    BuiltinShaderAddress::ClampToEdge,
    BuiltinShaderAddress::Repeat,
    BuiltinShaderAddress::MirrorRepeat,
  ]
  for a in addresses {
    let i = builtin_address_to_int(a)
    let back = builtin_address_from_int(i)
    assert_true(builtin_address_eq(a, back))
  }
}

///|
test "default_shader_entrypoints" {
  let ep = default_shader_entrypoints()
  assert_eq(ep.vertex, "vs_main")
  assert_eq(ep.fragment, "fs_main")
}

///|
test "noperspective directive parsed into ShaderIR" {
  let frontend = new_basic_shader_frontend()
  let request_with : ShaderCompileRequest = {
    source: "//kage:noperspective\n@fragment fn main() -> vec4f { return vec4f(1.0); }",
    unit_hint: Some(ShaderUnit::Pixels),
    src_image_count: 0,
    entrypoints: { vertex: "vs_main", fragment: "fs_main" },
    debug_name: "nopersp",
  }
  let request_without : ShaderCompileRequest = {
    source: "@fragment fn main() -> vec4f { return vec4f(1.0); }",
    unit_hint: Some(ShaderUnit::Pixels),
    src_image_count: 0,
    entrypoints: { vertex: "vs_main", fragment: "fs_main" },
    debug_name: "nopersp",
  }
  let ir_with = compile_shader_ir(frontend, request_with)
  let ir_without = compile_shader_ir(frontend, request_without)
  assert_eq(ir_with.noperspective, true)
  assert_eq(ir_without.noperspective, false)
}
