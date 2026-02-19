///|
/// Shader pipeline contracts (outline only).
///
/// Ebiten refs:
/// - shader.go
/// - internal/graphics/shader.go
/// - internal/shader/shader.go
/// - internal/ui/shader.go
/// - internal/shaderir/program.go
/// - internal/graphicscommand/commandqueue.go
/// - internal/builtinshader/shader.go

///|
pub enum ShaderUnit {
  Pixels
  Texels
} derive(Show)

///|
pub struct ShaderEntrypoints {
  vertex : String
  fragment : String
} derive(Show)

///|
pub struct ShaderCompileRequest {
  source : String
  unit_hint : ShaderUnit?
  src_image_count : Int
  entrypoints : ShaderEntrypoints
  debug_name : String
} derive(Show)

///|
pub struct ShaderIR {
  source : String
  unit : ShaderUnit
  src_image_count : Int
  entrypoints : ShaderEntrypoints
  debug_name : String
  source_hash : ShaderSourceHash
} derive(Show)

///|
pub struct ShaderSourceHash {
  value : String
} derive(Show)

///|
pub enum UniformValue {
  Bool(Bool)
  Int(Int)
  Float(Double)
  Bools(Array[Bool])
  Ints(Array[Int])
  Floats(Array[Double])
} derive(Show)

///|
pub struct NamedUniform {
  name : String
  value : UniformValue
} derive(Show)

///|
pub struct UniformLayout {
  names : Array[String]
  dword_counts : Array[Int]
  preserved_prefix_dwords : Int
} derive(Show)

///|
pub struct IntSize {
  width : Int
  height : Int
} derive(Show)

///|
pub struct FloatRect {
  x : Double
  y : Double
  width : Double
  height : Double
} derive(Show)

///|
pub struct PreservedUniformContext {
  dst_texture_size : IntSize
  dst_region : FloatRect
  src_texture_sizes : Array[IntSize]
  src_regions : Array[FloatRect]
} derive(Show)

///|
pub struct PackedUniforms {
  dwords : Array[Int]
} derive(Show)

///|
pub enum BuiltinShaderFilter {
  Nearest
  Linear
  Pixelated
} derive(Show)

///|
pub enum BuiltinShaderAddress {
  Unsafe
  ClampToZero
  Repeat
} derive(Show)

///|
pub struct BuiltinShaderKey {
  filter : BuiltinShaderFilter
  address : BuiltinShaderAddress
  use_color_m : Bool
} derive(Show)

///|
pub trait ShaderFrontend {
  /// Ebiten ref: internal/graphics/shader.go (CompileShader)
  compile_ir(Self, request : ShaderCompileRequest) -> ShaderIR raise

  /// Ebiten ref: internal/graphics/shader.go (CalcSourceHash)
  calc_source_hash(Self, request : ShaderCompileRequest) -> ShaderSourceHash raise
}

///|
pub trait UniformCanonicalizer {
  /// Ebiten ref: internal/ui/shader.go (AppendUniforms)
  append_user_uniforms(
    Self,
    layout : UniformLayout,
    uniforms : Array[NamedUniform],
  ) -> PackedUniforms raise

  /// Ebiten ref: internal/graphicscommand/commandqueue.go (prependPreservedUniforms)
  prepend_preserved_uniforms(
    Self,
    uniforms : PackedUniforms,
    context : PreservedUniformContext,
  ) -> PackedUniforms

  /// Ebiten ref: internal/shaderir/program.go (FilterUniformVariables)
  filter_unused_uniforms(Self, ir : ShaderIR, uniforms : PackedUniforms) -> PackedUniforms
}

///|
pub trait BuiltinShaderSourceRepo {
  /// Ebiten ref: internal/builtinshader/shader.go (ShaderSource/ClearShaderSource)
  shader_source(Self, key : BuiltinShaderKey) -> String
}

///|
pub fn[T : ShaderFrontend] compile_shader_ir(
  frontend : T,
  request : ShaderCompileRequest,
) -> ShaderIR raise {
  frontend.compile_ir(request)
}

///|
pub fn[T : ShaderFrontend] calc_shader_source_hash(
  frontend : T,
  request : ShaderCompileRequest,
) -> ShaderSourceHash raise {
  frontend.calc_source_hash(request)
}

///|
pub fn[T : UniformCanonicalizer] build_canonical_uniforms(
  canonicalizer : T,
  layout : UniformLayout,
  user_uniforms : Array[NamedUniform],
  context : PreservedUniformContext,
  ir : ShaderIR,
) -> PackedUniforms raise {
  let user = canonicalizer.append_user_uniforms(layout, user_uniforms)
  let preserved = canonicalizer.prepend_preserved_uniforms(user, context)
  canonicalizer.filter_unused_uniforms(ir, preserved)
}

///|
pub struct BasicShaderFrontend {}

///|
pub struct BasicUniformCanonicalizer {}

///|
pub struct BasicBuiltinShaderSourceRepo {}

///|
pub fn new_basic_shader_frontend() -> BasicShaderFrontend {
  BasicShaderFrontend::{  }
}

///|
pub fn new_basic_uniform_canonicalizer() -> BasicUniformCanonicalizer {
  BasicUniformCanonicalizer::{  }
}

///|
pub fn new_basic_builtin_shader_source_repo() -> BasicBuiltinShaderSourceRepo {
  BasicBuiltinShaderSourceRepo::{  }
}

///|
fn uniform_to_dwords(value : UniformValue) -> Array[Int] {
  match value {
    Bool(v) => [if v { 1 } else { 0 }]
    Int(v) => [v]
    Float(v) => [v.to_int()]
    Bools(vs) => vs.map(fn(v) { if v { 1 } else { 0 } })
    Ints(vs) => vs
    Floats(vs) => vs.map(fn(v) { v.to_int() })
  }
}

///|
fn find_named_uniform(
  uniforms : Array[NamedUniform],
  name : String,
) -> UniformValue? {
  for uniform in uniforms {
    if uniform.name == name {
      return Some(uniform.value)
    }
  }
  None
}

///|
fn simple_hash_value(
  source : String,
  debug_name : String,
  src_image_count : Int,
) -> String {
  let seed = source.length() * 131 + debug_name.length() * 17 + src_image_count
  seed.to_string()
}

///|
pub impl ShaderFrontend for BasicShaderFrontend with compile_ir(_self, request) {
  let unit = match request.unit_hint {
    Some(unit) => unit
    None => ShaderUnit::Pixels
  }
  let hash = {
    value: simple_hash_value(
      request.source,
      request.debug_name,
      request.src_image_count,
    ),
  }
  {
    source: request.source,
    unit,
    src_image_count: request.src_image_count,
    entrypoints: request.entrypoints,
    debug_name: request.debug_name,
    source_hash: hash,
  }
}

///|
pub impl ShaderFrontend for BasicShaderFrontend with calc_source_hash(
  _self,
  request,
) {
  {
    value: simple_hash_value(
      request.source,
      request.debug_name,
      request.src_image_count,
    ),
  }
}

///|
pub impl UniformCanonicalizer for BasicUniformCanonicalizer with append_user_uniforms(
  _self,
  layout,
  uniforms,
) {
  let dwords : Array[Int] = []
  for i in 0..<layout.names.length() {
    let name = layout.names[i]
    let expected = layout.dword_counts[i]
    match find_named_uniform(uniforms, name) {
      Some(value) => {
        let encoded = uniform_to_dwords(value)
        let mut written = 0
        for v in encoded {
          if written >= expected {
            break
          }
          dwords.push(v)
          written = written + 1
        }
        while written < expected {
          dwords.push(0)
          written = written + 1
        }
      }
      None =>
        for _ in 0..<expected {
          dwords.push(0)
        }
    }
  }
  { dwords, }
}

///|
pub impl UniformCanonicalizer for BasicUniformCanonicalizer with prepend_preserved_uniforms(
  _self,
  uniforms,
  context,
) {
  let prefix : Array[Int] = [
    context.dst_texture_size.width,
    context.dst_texture_size.height,
  ]
  prefix.push(context.dst_region.x.to_int())
  prefix.push(context.dst_region.y.to_int())
  prefix.push(context.dst_region.width.to_int())
  prefix.push(context.dst_region.height.to_int())
  for size in context.src_texture_sizes {
    prefix.push(size.width)
    prefix.push(size.height)
  }
  for region in context.src_regions {
    prefix.push(region.x.to_int())
    prefix.push(region.y.to_int())
    prefix.push(region.width.to_int())
    prefix.push(region.height.to_int())
  }
  let out = prefix
  for value in uniforms.dwords {
    out.push(value)
  }
  { dwords: out }
}

///|
pub impl UniformCanonicalizer for BasicUniformCanonicalizer with filter_unused_uniforms(
  _self,
  _ir,
  uniforms,
) {
  uniforms
}

///|
pub impl BuiltinShaderSourceRepo for BasicBuiltinShaderSourceRepo with shader_source(
  _self,
  key,
) {
  let _ = key.address
  let _ = key.use_color_m
  match key.filter {
    Nearest => "builtin:nearest"
    Linear => "builtin:linear"
    Pixelated => "builtin:pixelated"
  }
}
