///|
/// Tilemap-level draw-command builders.
///
/// Ebiten refs:
/// - internal/atlas/image.go
/// - internal/graphicscommand/command.go

///|
pub struct AtlasTileDrawSpec {
  atlas_key : @asset.AssetKey
  dst_region : @gfx.DstRegion
  left : Double
  top : Double
  right : Double
  bottom : Double
  uniform_dwords : Array[Int]
} derive(Show)

///|
pub struct TileAtlasEntry {
  tile_index : Int
  atlas_key : @asset.AssetKey
} derive(Show)

///|
pub struct TileAtlasTable {
  entries : Array[TileAtlasEntry]
} derive(Show)

///|
pub struct TileChunkRect {
  tile_x : Int
  tile_y : Int
  tile_width : Int
  tile_height : Int
} derive(Show)

///|
struct TileChunkOrigin {
  tile_x : Int
  tile_y : Int
} derive(Show)

///|
pub fn new_atlas_tile_draw_spec(
  atlas_key : @asset.AssetKey,
  dst_region : @gfx.DstRegion,
  left : Double,
  top : Double,
  right : Double,
  bottom : Double,
  uniform_dwords : Array[Int],
) -> AtlasTileDrawSpec {
  { atlas_key, dst_region, left, top, right, bottom, uniform_dwords }
}

///|
pub fn new_tile_atlas_entry(
  tile_index : Int,
  atlas_key : @asset.AssetKey,
) -> TileAtlasEntry {
  { tile_index, atlas_key }
}

///|
pub fn new_tile_atlas_table(entries : Array[TileAtlasEntry]) -> TileAtlasTable {
  { entries, }
}

///|
pub fn new_tile_chunk_rect(
  tile_x : Int,
  tile_y : Int,
  tile_width : Int,
  tile_height : Int,
) -> TileChunkRect {
  { tile_x, tile_y, tile_width, tile_height }
}

///|
fn safe_chunk_end(start : Int, length : Int) -> Int {
  if length <= 0 {
    start
  } else {
    start + length
  }
}

///|
fn intersect_tile_chunk_rect(
  lhs : TileChunkRect,
  rhs : TileChunkRect,
) -> TileChunkRect? {
  let left = if lhs.tile_x > rhs.tile_x { lhs.tile_x } else { rhs.tile_x }
  let top = if lhs.tile_y > rhs.tile_y { lhs.tile_y } else { rhs.tile_y }
  let lhs_right = safe_chunk_end(lhs.tile_x, lhs.tile_width)
  let rhs_right = safe_chunk_end(rhs.tile_x, rhs.tile_width)
  let lhs_bottom = safe_chunk_end(lhs.tile_y, lhs.tile_height)
  let rhs_bottom = safe_chunk_end(rhs.tile_y, rhs.tile_height)
  let right = if lhs_right < rhs_right { lhs_right } else { rhs_right }
  let bottom = if lhs_bottom < rhs_bottom { lhs_bottom } else { rhs_bottom }
  if right <= left || bottom <= top {
    None
  } else {
    Some({
      tile_x: left,
      tile_y: top,
      tile_width: right - left,
      tile_height: bottom - top,
    })
  }
}

///|
pub fn clip_tile_chunks_to_visible(
  chunks : Array[TileChunkRect],
  visible_chunk : TileChunkRect,
) -> Array[TileChunkRect] {
  let out : Array[TileChunkRect] = []
  for chunk in chunks {
    match intersect_tile_chunk_rect(chunk, visible_chunk) {
      Some(value) => out.push(value)
      None => ()
    }
  }
  out
}

///|
pub fn resolve_tile_atlas_key(
  table : TileAtlasTable,
  tile_index : Int,
) -> @asset.AssetKey? {
  let mut out : @asset.AssetKey? = None
  for entry in table.entries {
    if entry.tile_index == tile_index {
      out = Some(entry.atlas_key)
    }
  }
  out
}

///|
fn floor_to_int(value : Double) -> Int {
  let truncated = value.to_int()
  if value < truncated.to_double() {
    truncated - 1
  } else {
    truncated
  }
}

///|
pub fn estimate_visible_tile_chunk(
  map_columns : Int,
  map_rows : Int,
  origin_left : Double,
  origin_top : Double,
  tile_width : Double,
  tile_height : Double,
  view_left : Double,
  view_top : Double,
  view_right : Double,
  view_bottom : Double,
  margin_tiles : Int,
) -> TileChunkRect {
  let safe_columns = if map_columns <= 0 { 0 } else { map_columns }
  let safe_rows = if map_rows <= 0 { 0 } else { map_rows }
  if safe_columns == 0 ||
    safe_rows == 0 ||
    tile_width <= 0.0 ||
    tile_height <= 0.0 {
    { tile_x: 0, tile_y: 0, tile_width: 0, tile_height: 0 }
  } else {
    let margin = if margin_tiles < 0 { 0 } else { margin_tiles }
    let start_x = floor_to_int((view_left - origin_left) / tile_width) - margin
    let start_y = floor_to_int((view_top - origin_top) / tile_height) - margin
    let end_x = floor_to_int((view_right - origin_left) / tile_width) +
      1 +
      margin
    let end_y = floor_to_int((view_bottom - origin_top) / tile_height) +
      1 +
      margin
    let clamped_x0 = if start_x < 0 {
      0
    } else if start_x > safe_columns {
      safe_columns
    } else {
      start_x
    }
    let clamped_y0 = if start_y < 0 {
      0
    } else if start_y > safe_rows {
      safe_rows
    } else {
      start_y
    }
    let clamped_x1 = if end_x < 0 {
      0
    } else if end_x > safe_columns {
      safe_columns
    } else {
      end_x
    }
    let clamped_y1 = if end_y < 0 {
      0
    } else if end_y > safe_rows {
      safe_rows
    } else {
      end_y
    }
    let width = if clamped_x1 <= clamped_x0 {
      0
    } else {
      clamped_x1 - clamped_x0
    }
    let height = if clamped_y1 <= clamped_y0 {
      0
    } else {
      clamped_y1 - clamped_y0
    }
    {
      tile_x: clamped_x0,
      tile_y: clamped_y0,
      tile_width: width,
      tile_height: height,
    }
  }
}

///|
pub fn append_atlas_tilemap_draw_commands(
  commands : Array[@gfx.DrawTrianglesCommand],
  atlas_repository : @asset.SimpleAtlasImageRepository,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  pipeline_id : Int,
  uniform_hash : Int,
  blend : @gfx.BlendMode,
  specs : Array[AtlasTileDrawSpec],
) -> Int {
  let mut appended = 0
  for spec in specs {
    let ok = @sprite2d.append_atlas_sprite_draw_command(
      commands,
      atlas_repository,
      spec.atlas_key,
      dst,
      shader,
      spec.dst_region,
      0,
      pipeline_id,
      uniform_hash,
      blend,
      spec.left,
      spec.top,
      spec.right,
      spec.bottom,
      spec.uniform_dwords,
    )
    if ok {
      appended = appended + 1
    }
  }
  appended
}

///|
struct ResolvedTileQuad {
  page_image_id : Int
  left : Double
  top : Double
  right : Double
  bottom : Double
  u0 : Double
  v0 : Double
  u1 : Double
  v1 : Double
} derive(Show)

///|
fn normalized_positive_int(value : Int) -> Int {
  if value <= 0 {
    1
  } else {
    value
  }
}

///|
fn resolve_tile_quad(
  table : TileAtlasTable,
  atlas_repository : @asset.SimpleAtlasImageRepository,
  tile_index : Int,
  left : Double,
  top : Double,
  right : Double,
  bottom : Double,
) -> ResolvedTileQuad? {
  if tile_index < 0 {
    None
  } else {
    match resolve_tile_atlas_key(table, tile_index) {
      Some(atlas_key) =>
        match @asset.get_atlas_draw_source(atlas_repository, atlas_key) {
          Some(source) =>
            Some({
              page_image_id: source.page_image_id,
              left,
              top,
              right,
              bottom,
              u0: source.u0,
              v0: source.v0,
              u1: source.u1,
              v1: source.v1,
            })
          None => None
        }
      None => None
    }
  }
}

///|
fn collect_chunk_tile_quads(
  table : TileAtlasTable,
  atlas_repository : @asset.SimpleAtlasImageRepository,
  tile_indices : Array[Int],
  columns : Int,
  chunk_x : Int,
  chunk_y : Int,
  chunk_width : Int,
  chunk_height : Int,
  origin_left : Double,
  origin_top : Double,
  tile_width : Double,
  tile_height : Double,
) -> Array[ResolvedTileQuad] {
  let safe_columns = normalized_positive_int(columns)
  let safe_chunk_width = if chunk_width <= 0 { 0 } else { chunk_width }
  let safe_chunk_height = if chunk_height <= 0 { 0 } else { chunk_height }
  let out : Array[ResolvedTileQuad] = []
  for y in 0..<safe_chunk_height {
    let row = chunk_y + y
    if row < 0 {
      continue
    }
    for x in 0..<safe_chunk_width {
      let column = chunk_x + x
      if column < 0 {
        continue
      }
      let index = row * safe_columns + column
      if index < 0 || index >= tile_indices.length() {
        continue
      }
      let left = origin_left + column.to_double() * tile_width
      let top = origin_top + row.to_double() * tile_height
      match
        resolve_tile_quad(
          table,
          atlas_repository,
          tile_indices[index],
          left,
          top,
          left + tile_width,
          top + tile_height,
        ) {
        Some(quad) => out.push(quad)
        None => ()
      }
    }
  }
  out
}

///|
fn append_quad_payload(
  vertex_data : Array[Double],
  indices : Array[Int],
  quad : ResolvedTileQuad,
) -> Unit {
  let base = vertex_data.length() / 4
  vertex_data.push(quad.left)
  vertex_data.push(quad.top)
  vertex_data.push(quad.u0)
  vertex_data.push(quad.v0)
  vertex_data.push(quad.right)
  vertex_data.push(quad.top)
  vertex_data.push(quad.u1)
  vertex_data.push(quad.v0)
  vertex_data.push(quad.right)
  vertex_data.push(quad.bottom)
  vertex_data.push(quad.u1)
  vertex_data.push(quad.v1)
  vertex_data.push(quad.left)
  vertex_data.push(quad.bottom)
  vertex_data.push(quad.u0)
  vertex_data.push(quad.v1)
  indices.push(base)
  indices.push(base + 1)
  indices.push(base + 2)
  indices.push(base + 2)
  indices.push(base + 3)
  indices.push(base)
}

///|
fn page_slot_of(page_ids : Array[Int], page_image_id : Int) -> Int {
  let mut out = -1
  for i in 0..<page_ids.length() {
    if page_ids[i] == page_image_id {
      out = i
    }
  }
  out
}

///|
fn tile_chunk_origin_eq(lhs : TileChunkOrigin, rhs : TileChunkOrigin) -> Bool {
  lhs.tile_x == rhs.tile_x && lhs.tile_y == rhs.tile_y
}

///|
fn contains_tile_chunk_origin(
  origins : Array[TileChunkOrigin],
  origin : TileChunkOrigin,
) -> Bool {
  let mut found = false
  for current in origins {
    if tile_chunk_origin_eq(current, origin) {
      found = true
    }
  }
  found
}

///|
pub fn diff_tile_index_chunks(
  previous_tile_indices : Array[Int],
  next_tile_indices : Array[Int],
  columns : Int,
  chunk_size : Int,
) -> Array[TileChunkRect] {
  let safe_columns = normalized_positive_int(columns)
  let safe_chunk_size = normalized_positive_int(chunk_size)
  let max_len = if previous_tile_indices.length() > next_tile_indices.length() {
    previous_tile_indices.length()
  } else {
    next_tile_indices.length()
  }
  let rows = if max_len == 0 {
    0
  } else {
    (max_len + safe_columns - 1) / safe_columns
  }
  let origins : Array[TileChunkOrigin] = []
  for i in 0..<max_len {
    let previous_value = if i < previous_tile_indices.length() {
      previous_tile_indices[i]
    } else {
      -1
    }
    let next_value = if i < next_tile_indices.length() {
      next_tile_indices[i]
    } else {
      -1
    }
    if previous_value == next_value {
      continue
    }
    let column = i % safe_columns
    let row = i / safe_columns
    let origin = {
      tile_x: column / safe_chunk_size * safe_chunk_size,
      tile_y: row / safe_chunk_size * safe_chunk_size,
    }
    if !contains_tile_chunk_origin(origins, origin) {
      origins.push(origin)
    }
  }
  let out : Array[TileChunkRect] = []
  for origin in origins {
    let width = if origin.tile_x >= safe_columns {
      0
    } else if origin.tile_x + safe_chunk_size > safe_columns {
      safe_columns - origin.tile_x
    } else {
      safe_chunk_size
    }
    let height = if origin.tile_y >= rows {
      0
    } else if origin.tile_y + safe_chunk_size > rows {
      rows - origin.tile_y
    } else {
      safe_chunk_size
    }
    if width > 0 && height > 0 {
      out.push({
        tile_x: origin.tile_x,
        tile_y: origin.tile_y,
        tile_width: width,
        tile_height: height,
      })
    }
  }
  out
}

///|
pub fn diff_visible_tile_index_chunks(
  previous_tile_indices : Array[Int],
  next_tile_indices : Array[Int],
  columns : Int,
  chunk_size : Int,
  visible_chunk : TileChunkRect,
) -> Array[TileChunkRect] {
  let chunks = diff_tile_index_chunks(
    previous_tile_indices, next_tile_indices, columns, chunk_size,
  )
  clip_tile_chunks_to_visible(chunks, visible_chunk)
}

///|
pub fn append_tile_indexed_draw_commands(
  commands : Array[@gfx.DrawTrianglesCommand],
  table : TileAtlasTable,
  atlas_repository : @asset.SimpleAtlasImageRepository,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  pipeline_id : Int,
  uniform_hash : Int,
  blend : @gfx.BlendMode,
  dst_region : @gfx.DstRegion,
  tile_indices : Array[Int],
  columns : Int,
  origin_left : Double,
  origin_top : Double,
  tile_width : Double,
  tile_height : Double,
  uniform_dwords : Array[Int],
) -> Int {
  let safe_columns = normalized_positive_int(columns)
  let rows = (tile_indices.length() + safe_columns - 1) / safe_columns
  append_tile_indexed_chunk_draw_commands(
    commands, table, atlas_repository, dst, shader, pipeline_id, uniform_hash, blend,
    dst_region, tile_indices, safe_columns, 0, 0, safe_columns, rows, origin_left,
    origin_top, tile_width, tile_height, uniform_dwords,
  )
}

///|
pub fn append_tile_indexed_chunk_draw_commands(
  commands : Array[@gfx.DrawTrianglesCommand],
  table : TileAtlasTable,
  atlas_repository : @asset.SimpleAtlasImageRepository,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  pipeline_id : Int,
  uniform_hash : Int,
  blend : @gfx.BlendMode,
  dst_region : @gfx.DstRegion,
  tile_indices : Array[Int],
  columns : Int,
  chunk_x : Int,
  chunk_y : Int,
  chunk_width : Int,
  chunk_height : Int,
  origin_left : Double,
  origin_top : Double,
  tile_width : Double,
  tile_height : Double,
  uniform_dwords : Array[Int],
) -> Int {
  let quads = collect_chunk_tile_quads(
    table, atlas_repository, tile_indices, columns, chunk_x, chunk_y, chunk_width,
    chunk_height, origin_left, origin_top, tile_width, tile_height,
  )
  for quad in quads {
    let vertex_data : Array[Double] = []
    let indices : Array[Int] = []
    append_quad_payload(vertex_data, indices, quad)
    commands.push(
      @gfx.new_draw_triangles_command(
        dst,
        shader,
        [dst_region],
        0,
        pipeline_id,
        uniform_hash,
        blend,
        vertex_data,
        indices,
        [quad.page_image_id],
        uniform_dwords,
      ),
    )
  }
  quads.length()
}

///|
pub fn append_tile_indexed_chunk_batched_draw_commands(
  commands : Array[@gfx.DrawTrianglesCommand],
  table : TileAtlasTable,
  atlas_repository : @asset.SimpleAtlasImageRepository,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  pipeline_id : Int,
  uniform_hash : Int,
  blend : @gfx.BlendMode,
  dst_region : @gfx.DstRegion,
  tile_indices : Array[Int],
  columns : Int,
  chunk_x : Int,
  chunk_y : Int,
  chunk_width : Int,
  chunk_height : Int,
  origin_left : Double,
  origin_top : Double,
  tile_width : Double,
  tile_height : Double,
  uniform_dwords : Array[Int],
) -> Int {
  let quads = collect_chunk_tile_quads(
    table, atlas_repository, tile_indices, columns, chunk_x, chunk_y, chunk_width,
    chunk_height, origin_left, origin_top, tile_width, tile_height,
  )
  let page_ids : Array[Int] = []
  let page_vertex_data : Array[Array[Double]] = []
  let page_indices : Array[Array[Int]] = []
  for quad in quads {
    let mut slot = page_slot_of(page_ids, quad.page_image_id)
    if slot < 0 {
      page_ids.push(quad.page_image_id)
      page_vertex_data.push([])
      page_indices.push([])
      slot = page_ids.length() - 1
    }
    let vertex_data = page_vertex_data[slot]
    let indices = page_indices[slot]
    append_quad_payload(vertex_data, indices, quad)
    page_vertex_data[slot] = vertex_data
    page_indices[slot] = indices
  }
  for i in 0..<page_ids.length() {
    commands.push(
      @gfx.new_draw_triangles_command(
        dst,
        shader,
        [dst_region],
        0,
        pipeline_id,
        uniform_hash,
        blend,
        page_vertex_data[i],
        page_indices[i],
        [page_ids[i]],
        uniform_dwords,
      ),
    )
  }
  page_ids.length()
}

///|
pub fn append_tile_indexed_dirty_chunk_batched_draw_commands(
  commands : Array[@gfx.DrawTrianglesCommand],
  chunks : Array[TileChunkRect],
  table : TileAtlasTable,
  atlas_repository : @asset.SimpleAtlasImageRepository,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  pipeline_id : Int,
  uniform_hash : Int,
  blend : @gfx.BlendMode,
  dst_region : @gfx.DstRegion,
  tile_indices : Array[Int],
  columns : Int,
  origin_left : Double,
  origin_top : Double,
  tile_width : Double,
  tile_height : Double,
  uniform_dwords : Array[Int],
) -> Int {
  let mut appended = 0
  for chunk in chunks {
    appended = appended +
      append_tile_indexed_chunk_batched_draw_commands(
        commands,
        table,
        atlas_repository,
        dst,
        shader,
        pipeline_id,
        uniform_hash,
        blend,
        dst_region,
        tile_indices,
        columns,
        chunk.tile_x,
        chunk.tile_y,
        chunk.tile_width,
        chunk.tile_height,
        origin_left,
        origin_top,
        tile_width,
        tile_height,
        uniform_dwords,
      )
  }
  appended
}

///|
pub fn atlas_tilemap_draw_commands(
  atlas_repository : @asset.SimpleAtlasImageRepository,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  pipeline_id : Int,
  uniform_hash : Int,
  blend : @gfx.BlendMode,
  specs : Array[AtlasTileDrawSpec],
) -> Array[@gfx.DrawTrianglesCommand] {
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  let _ = append_atlas_tilemap_draw_commands(
    commands, atlas_repository, dst, shader, pipeline_id, uniform_hash, blend, specs,
  )
  commands
}

///|
pub fn tile_indexed_chunk_draw_commands(
  table : TileAtlasTable,
  atlas_repository : @asset.SimpleAtlasImageRepository,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  pipeline_id : Int,
  uniform_hash : Int,
  blend : @gfx.BlendMode,
  dst_region : @gfx.DstRegion,
  tile_indices : Array[Int],
  columns : Int,
  chunk_x : Int,
  chunk_y : Int,
  chunk_width : Int,
  chunk_height : Int,
  origin_left : Double,
  origin_top : Double,
  tile_width : Double,
  tile_height : Double,
  uniform_dwords : Array[Int],
) -> Array[@gfx.DrawTrianglesCommand] {
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  let _ = append_tile_indexed_chunk_draw_commands(
    commands, table, atlas_repository, dst, shader, pipeline_id, uniform_hash, blend,
    dst_region, tile_indices, columns, chunk_x, chunk_y, chunk_width, chunk_height,
    origin_left, origin_top, tile_width, tile_height, uniform_dwords,
  )
  commands
}

///|
pub fn tile_indexed_chunk_batched_draw_commands(
  table : TileAtlasTable,
  atlas_repository : @asset.SimpleAtlasImageRepository,
  dst : @gfx.ImageHandle,
  shader : @gfx.ShaderHandle,
  pipeline_id : Int,
  uniform_hash : Int,
  blend : @gfx.BlendMode,
  dst_region : @gfx.DstRegion,
  tile_indices : Array[Int],
  columns : Int,
  chunk_x : Int,
  chunk_y : Int,
  chunk_width : Int,
  chunk_height : Int,
  origin_left : Double,
  origin_top : Double,
  tile_width : Double,
  tile_height : Double,
  uniform_dwords : Array[Int],
) -> Array[@gfx.DrawTrianglesCommand] {
  let commands : Array[@gfx.DrawTrianglesCommand] = []
  let _ = append_tile_indexed_chunk_batched_draw_commands(
    commands, table, atlas_repository, dst, shader, pipeline_id, uniform_hash, blend,
    dst_region, tile_indices, columns, chunk_x, chunk_y, chunk_width, chunk_height,
    origin_left, origin_top, tile_width, tile_height, uniform_dwords,
  )
  commands
}
