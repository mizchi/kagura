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
    source: "x",
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
  assert_true(packed.dwords.length() >= 9)
}
