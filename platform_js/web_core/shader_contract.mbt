///|
/// Shader layout/command policy, independent of WebGPU device ownership.
let position_pattern : @regexp.RegExp = @regexp.RegExp::new(
  "position\\s*:\\s*vec3<f32>",
)

///|
let joints_pattern : @regexp.RegExp = @regexp.RegExp::new(
  "joints\\s*:\\s*vec4<f32>",
)

///|
let weights_pattern : @regexp.RegExp = @regexp.RegExp::new(
  "weights\\s*:\\s*vec4<f32>",
)

///|
pub fn is_stride32(source : String) -> Bool {
  position_pattern.test_(source)
}

///|
pub fn is_stride64(source : String) -> Bool {
  is_stride32(source) &&
  joints_pattern.test_(source) &&
  weights_pattern.test_(source)
}

///|
pub fn is_3d_shader(source : String) -> Bool {
  is_stride32(source) || is_stride64(source)
}

///|
pub fn command_needs_depth(command : @core.Any) -> Bool {
  let hint = number_field(command, "vertexStrideHint", 0)
  truthy(command._get("isCustom")) &&
  (if hint > 0 {
    hint >= 8
  } else {
    is_3d_shader(command._get("shaderSource").cast())
  })
}

///|
pub fn parse_texture_bindings(source : String) -> @core.Any {
  let pattern = @regexp.RegExp::new(
    "@binding\\((\\d+)\\)\\s+var\\s+\\w+\\s*:\\s*(texture_2d<f32>|texture_2d|sampler)",
    flags="g",
  )
  let bindings : Array[(Int, String)] = []
  while true {
    let matched = pattern.to_any()._call("exec", [@core.any(source)])
    if @core.is_nullish(matched) {
      break
    }
    let text : String = matched._get_by_index(1).cast()
    let mut index = 0
    for character in text {
      index = index * 10 + character.to_int() - 48
    }
    let raw : String = matched._get_by_index(2).cast()
    bindings.push(
      (index, if raw.has_prefix("texture") { "texture" } else { "sampler" }),
    )
  }
  bindings.sort_by(fn(a, b) { a.0.compare(b.0) })
  @core.any(
    bindings.map(fn(binding) {
      @core.from_entries([
        ("binding", @core.any(binding.0)),
        ("type", @core.any(binding.1)),
      ])
    }),
  )
}

///|
extern "js" fn to_i32(value : @core.Any) -> Int =
  #| (value) => value | 0

///|
pub fn get_instance_count(command : @core.Any) -> Int {
  let raw = fallback(
    field(command, "instanceCount"),
    field(command, "instance_count"),
  )
  if finite(raw) {
    to_i32(raw).max(1)
  } else {
    1
  }
}

///|
pub fn get_resource_cache_key(command : @core.Any) -> Int {
  let raw = fallback(
    field(command, "resourceCacheKey"),
    field(command, "resource_cache_key"),
  )
  if finite(raw) {
    to_i32(raw)
  } else {
    0
  }
}

///|
/// Compare typed-array words in place; never copy or JSON-encode hot buffers.
pub fn equal_dwords(a : @core.Any, b : @core.Any, count : @core.Any) -> Bool {
  if @core.equal(a, b) {
    return true
  }
  if @core.is_nullish(a) || @core.is_nullish(b) {
    return false
  }
  let count = argument(count, b._get("length"))
  if !@core.equal(a._get("length"), count) ||
    number(b._get("length")) < number(count) {
    return false
  }
  let count : Int = count.cast()
  for i = 0; i < count; i = i + 1 {
    if !@core.equal(a._get_by_index(i), b._get_by_index(i)) {
      return false
    }
  }
  true
}

///|
extern "js" fn replace_first(
  source : String,
  from : String,
  to : String,
) -> String =
  #| (source, from, to) => source.replace(from, to)

///|
/// Opt-in adapter for Standard/depth WGSL. Preserve command ordering.
pub fn instance_uniform_shader(source : String, dwords : @core.Any) -> String {
  if !safe_integer(dwords) ||
    number(dwords) < 4 ||
    number(dwords) > 128 ||
    number(dwords) % 4 != 0 {
    range_error("Invalid instance uniform layout")
  }
  let replacements = [
    (
      "@group(0) @binding(0) var<uniform> uniforms: Uniforms;", "struct InstanceUniforms { values: array<Uniforms, 32>, };\n@group(0) @binding(0) var<uniform> instance_uniforms: InstanceUniforms;\nvar<private> uniforms: Uniforms;",
    ),
    (
      "struct VertexOutput {", "struct VertexOutput {\n  @location(7) @interpolate(flat) instance_id: u32,",
    ),
    (
      "@vertex fn vs_main(input: VertexInput) -> VertexOutput {", "@vertex fn vs_main(input: VertexInput, @builtin(instance_index) instance_id: u32) -> VertexOutput {\n  uniforms = instance_uniforms.values[instance_id];",
    ),
    (
      "var out: VertexOutput;", "var out: VertexOutput;\n  out.instance_id = instance_id;",
    ),
    (
      "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {", "@fragment fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {\n  uniforms = instance_uniforms.values[in.instance_id];",
    ),
  ]
  let mut result = source
  for (from, to) in replacements {
    if !result.contains(from) {
      @core.throw_error(
        "Unsupported instance shader entry-point contract: " + from,
      )
    }
    result = replace_first(result, from, to)
  }
  "// kagura-instance-dwords: " + dwords.to_string() + "\n" + result
}
