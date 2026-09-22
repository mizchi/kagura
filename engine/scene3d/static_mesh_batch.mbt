///|
/// Index range into a shared static mesh. Use index_count for the destination
/// region and first_index for the draw command's index offset.
pub struct StaticMeshSpan {
  first_index : Int
  index_count : Int
} derive(Eq, Debug)

///|
pub extend StaticMeshSpan with Eq::{equal, not_equal}

///|
pub extend StaticMeshSpan with @moonbitlang/core/debug.Debug::{to_repr}

///|
/// Geometry copied once in source order. Treat the mesh and spans as immutable
/// after construction, so GPU backends can retain their buffers across draws.
pub struct StaticMeshBatch {
  mesh : @mesh3d.Mesh3D
  spans : Array[StaticMeshSpan]
}

///|
/// Combine same-layout meshes, preserving one span per source (including empty
/// sources). Returns None for mixed layouts, incomplete vertices/triangles or
/// out-of-bounds indices. Build during loading, not during visibility selection.
pub fn StaticMeshBatch::new(meshes : Array[@mesh3d.Mesh3D]) -> StaticMeshBatch? {
  let format = if meshes.is_empty() {
    @mesh3d.VertexFormat::standard_3d()
  } else {
    meshes[0].format
  }
  let stride = format.stride()
  if stride <= 0 {
    return None
  }
  let vertices : Array[Double] = []
  let indices : Array[Int] = []
  let spans : Array[StaticMeshSpan] = []
  for mesh in meshes {
    if mesh.format.attributes != format.attributes ||
      mesh.vertex_data.length() % stride != 0 ||
      mesh.indices.length() % 3 != 0 {
      return None
    }
    let offset = vertices.length() / stride
    let count = mesh.vertex_count()
    spans.push({
      first_index: indices.length(),
      index_count: mesh.indices.length(),
    })
    for index in mesh.indices {
      if index < 0 || index >= count {
        return None
      }
      indices.push(index + offset)
    }
    for value in mesh.vertex_data {
      vertices.push(value)
    }
  }
  Some({
    mesh: @mesh3d.Mesh3D::new_with_format(vertices, indices, format),
    spans,
  })
}

///|
/// Select visible source indices without copying vertices/indices. Adjacent
/// visible spans coalesce; an invisible nonempty span always breaks the run.
pub fn StaticMeshBatch::select(
  self : StaticMeshBatch,
  visible : (Int) -> Bool,
) -> Array[StaticMeshSpan] {
  let result : Array[StaticMeshSpan] = []
  for i, span in self.spans {
    if span.index_count == 0 || !visible(i) {
      continue
    }
    let last = result.length() - 1
    if last >= 0 &&
      result[last].first_index + result[last].index_count == span.first_index {
      result[last] = {
        first_index: result[last].first_index,
        index_count: result[last].index_count + span.index_count,
      }
    } else {
      result.push(span)
    }
  }
  result
}
