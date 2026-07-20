///|
/// Texture binding info parsed from WGSL source
pub(all) struct TextureBinding {
  binding : Int
  type_ : String // "texture" or "sampler"
}

///|
/// Check if the shader source uses vec3<f32> positions (3D / 32-byte stride)
pub fn is_stride32(source : String) -> Bool {
  js_regex_test("position\\s*:\\s*vec3<f32>", source)
}

///|
/// Check if the shader source uses skinned 3D vertex layout:
/// position(3) + normal(3) + uv(2) + joints(4) + weights(4) = 64 bytes.
pub fn is_stride64(source : String) -> Bool {
  is_stride32(source) &&
  js_regex_test("joints\\s*:\\s*vec4<f32>", source) &&
  js_regex_test("weights\\s*:\\s*vec4<f32>", source)
}

///|
/// Check if shader should be treated as a 3D pipeline (depth/culling enabled).
pub fn is_3d_shader(source : String) -> Bool {
  is_stride32(source) || is_stride64(source)
}

///|
/// Parse texture/sampler bindings from WGSL shader source
pub fn parse_texture_bindings(source : String) -> Array[TextureBinding] {
  let raw = js_parse_texture_bindings(source)
  let len = raw._get("length").cast_int()
  let results : Array[TextureBinding] = []
  for i = 0; i < len; i = i + 1 {
    let item = raw._get_by_index(i)
    let binding = item._get("binding").cast_int()
    let type_ = item._get("type").cast_string()
    results.push({ binding, type_ })
  }
  results
}

///|
/// JS regex test helper
fn js_regex_test(pattern : String, source : String) -> Bool {
  // Use JS RegExp to test
  let regexp = @core.new(@core.global_this()._get("RegExp"), [
    @core.Any::string(pattern),
  ])
  regexp._call("test", [@core.Any::string(source)]).cast_bool()
}

///|
/// JS helper to parse texture bindings using RegExp
fn js_parse_texture_bindings(source : String) -> @core.Any {
  // Execute regex in JS to find all @binding(N) var name : texture_2d<f32>|sampler
  let code = @core.Any::string(source)
  let results = @core.new_array()
  // Use JS function to do regex matching
  let re = @core.new(@core.global_this()._get("RegExp"), [
    @core.Any::string(
      "@binding\\((\\d+)\\)\\s+var\\s+\\w+\\s*:\\s*(texture_2d<f32>|texture_2d|sampler)",
    ),
    @core.Any::string("g"),
  ])
  // Loop through matches
  while true {
    let m = re._call("exec", [code])
    if @core.is_null(m) || @core.is_nullish(m) {
      break
    }
    let binding_str = m._get_by_index(1).cast_string()
    let raw_type = m._get_by_index(2).cast_string()
    let obj = @core.new_object()
    obj._set("binding", @core.Any::int(js_parse_int(binding_str)))
    let type_ = if raw_type.has_prefix("texture") {
      "texture"
    } else {
      "sampler"
    }
    obj._set("type", @core.Any::string(type_))
    results._call("push", [obj]) |> ignore
  }
  // Sort by binding number
  let sort_fn = @core.from_fn2(fn(a : @core.Any, b : @core.Any) -> @core.Any {
    let ab = a._get("binding").cast_int()
    let bb = b._get("binding").cast_int()
    @core.Any::int(ab - bb)
  })
  results._call("sort", [sort_fn]) |> ignore
  results
}

///|
/// Parse integer from string via JS
fn js_parse_int(s : String) -> Int {
  @core.global_this()
  ._get("parseInt")
  ._invoke([@core.Any::string(s), @core.Any::int(10)])
  .cast_int()
}

///|
/// Helper extension methods for @core.Any type conversions
fn @core.Any::cast_int(self : @core.Any) -> Int {
  self.cast()
}

///|
fn @core.Any::cast_string(self : @core.Any) -> String {
  self.cast()
}

///|
fn @core.Any::cast_bool(self : @core.Any) -> Bool {
  self.cast()
}

///|
fn @core.Any::string(s : String) -> @core.Any {
  @core.any(s)
}

///|
fn @core.Any::int(i : Int) -> @core.Any {
  @core.any(i)
}

///|
fn @core.Any::float(f : Double) -> @core.Any {
  @core.any(f)
}
