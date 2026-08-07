///|
/// Vertex attribute types for 3D mesh data.
pub enum VertexAttribute {
  Position3 // 3 floats: x, y, z
  Normal3 // 3 floats: nx, ny, nz
  TexCoord2 // 2 floats: u, v
  Joints4 // 4 floats: joint indices
  Weights4 // 4 floats: bone weights
  Tangent4 // 4 floats: tx, ty, tz, sign
  Color4 // 4 floats: r, g, b, a
} derive(Eq, Debug)

///|
pub impl Show for VertexAttribute with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
/// Number of float components for a vertex attribute.
pub fn VertexAttribute::size(self : VertexAttribute) -> Int {
  match self {
    Position3 => 3
    Normal3 => 3
    TexCoord2 => 2
    Joints4 => 4
    Weights4 => 4
    Tangent4 => 4
    Color4 => 4
  }
}

///|
/// Describes the layout of vertex data as an ordered list of attributes.
pub struct VertexFormat {
  attributes : Array[VertexAttribute]
} derive(Debug)

///|
pub impl Show for VertexFormat with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
/// Total number of floats per vertex.
pub fn VertexFormat::stride(self : VertexFormat) -> Int {
  let mut s = 0
  for attr in self.attributes {
    s += attr.size()
  }
  s
}

///|
/// Byte offset of an attribute in the vertex layout.
/// Returns -1 if the attribute is not present.
pub fn VertexFormat::offset_of(
  self : VertexFormat,
  target : VertexAttribute,
) -> Int {
  let mut off = 0
  for attr in self.attributes {
    if attr == target {
      return off
    }
    off += attr.size()
  }
  -1
}

///|
/// Whether this format contains the given attribute.
pub fn VertexFormat::has(self : VertexFormat, target : VertexAttribute) -> Bool {
  for attr in self.attributes {
    if attr == target {
      return true
    }
  }
  false
}

///|
/// Standard 3D format: position(3) + normal(3) + uv(2) = stride 8.
pub fn VertexFormat::standard_3d() -> VertexFormat {
  { attributes: [Position3, Normal3, TexCoord2] }
}

///|
/// Skinned 3D format: position(3) + normal(3) + uv(2) + joints(4) + weights(4) = stride 16.
pub fn VertexFormat::skinned_3d() -> VertexFormat {
  { attributes: [Position3, Normal3, TexCoord2, Joints4, Weights4] }
}

///|
pub extend VertexAttribute with Eq::{not_equal, equal}

///|
pub extend VertexAttribute with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend VertexAttribute with Show::{to_string, output}

///|
pub extend VertexFormat with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend VertexFormat with Show::{to_string, output}
