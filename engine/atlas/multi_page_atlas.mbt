///|
pub fn new_multi_page_atlas_repository(
  page_width : Int32,
  page_height : Int32,
) -> MultiPageAtlasRepository {
  let safe_width = if page_width <= 0 { 1 } else { page_width }
  let safe_height = if page_height <= 0 { 1 } else { page_height }
  {
    page_width: safe_width,
    page_height: safe_height,
    next_page_id: 100,
    pages: [],
    key_page_index: [],
  }
}

///|
pub fn multi_page_count(repo : MultiPageAtlasRepository) -> Int32 {
  repo.pages.length()
}

///|
pub fn multi_page_image_count(repo : MultiPageAtlasRepository) -> Int32 {
  let mut total = 0
  for page in repo.pages {
    total = total + page.images.length()
  }
  total
}

///|
fn find_key_page_index(
  index : Array[(String, Int32)],
  key : AssetKey,
) -> Int32? {
  for entry in index {
    if entry.0 == key.value {
      return Some(entry.1)
    }
  }
  None
}

///|
fn add_key_page_index(
  repo : MultiPageAtlasRepository,
  key : AssetKey,
  page_index : Int32,
) -> Unit {
  repo.key_page_index.push((key.value, page_index))
}

///|
fn remove_key_page_index(
  repo : MultiPageAtlasRepository,
  key : AssetKey,
) -> Unit {
  let next : Array[(String, Int32)] = []
  for entry in repo.key_page_index {
    if entry.0 != key.value {
      next.push(entry)
    }
  }
  repo.key_page_index = next
}

///|
fn ensure_page(repo : MultiPageAtlasRepository) -> Int32 {
  if repo.pages.length() == 0 {
    let page_id = repo.next_page_id
    repo.next_page_id = repo.next_page_id + 1
    repo.pages.push(
      new_simple_atlas_image_repository(
        repo.page_width,
        repo.page_height,
        page_id,
      ),
    )
  }
  repo.pages.length() - 1
}

///|
fn add_new_page(repo : MultiPageAtlasRepository) -> Int32 {
  let page_id = repo.next_page_id
  repo.next_page_id = repo.next_page_id + 1
  repo.pages.push(
    new_simple_atlas_image_repository(
      repo.page_width,
      repo.page_height,
      page_id,
    ),
  )
  repo.pages.length() - 1
}

///|
pub fn multi_page_create_image(
  repo : MultiPageAtlasRepository,
  key : AssetKey,
  spec : ImageSpec,
) -> @gfx.ImageHandle? {
  // Check if key already exists
  match find_key_page_index(repo.key_page_index, key) {
    Some(page_idx) =>
      if page_idx < repo.pages.length() {
        for entry in repo.pages[page_idx].images {
          if asset_key_eq(entry.key, key) {
            return Some(entry.handle)
          }
        }
      }
    None => ()
  }
  // Try current (last) page first
  let last_idx = ensure_page(repo)
  match create_atlas_image(repo.pages[last_idx], key, spec) {
    Some(handle) => {
      add_key_page_index(repo, key, last_idx)
      Some(handle)
    }
    None => {
      // Current page full, create new page and retry
      let new_idx = add_new_page(repo)
      match create_atlas_image(repo.pages[new_idx], key, spec) {
        Some(handle) => {
          add_key_page_index(repo, key, new_idx)
          Some(handle)
        }
        None => None // Image too large for a single page
      }
    }
  }
}

///|
pub fn multi_page_get_draw_source(
  repo : MultiPageAtlasRepository,
  key : AssetKey,
) -> AtlasDrawSource? {
  match find_key_page_index(repo.key_page_index, key) {
    Some(page_idx) =>
      if page_idx < repo.pages.length() {
        get_atlas_draw_source(repo.pages[page_idx], key)
      } else {
        None
      }
    None => None
  }
}

///|
pub fn multi_page_get_region(
  repo : MultiPageAtlasRepository,
  key : AssetKey,
) -> AtlasRegion? {
  match find_key_page_index(repo.key_page_index, key) {
    Some(page_idx) =>
      if page_idx < repo.pages.length() {
        get_atlas_image_region(repo.pages[page_idx], key)
      } else {
        None
      }
    None => None
  }
}

///|
pub fn multi_page_update_image_spec(
  repo : MultiPageAtlasRepository,
  key : AssetKey,
  spec : ImageSpec,
) -> @gfx.ImageHandle? {
  match find_key_page_index(repo.key_page_index, key) {
    Some(page_idx) =>
      if page_idx < repo.pages.length() {
        update_atlas_image_spec(repo.pages[page_idx], key, spec)
      } else {
        None
      }
    None => None
  }
}

///|
pub fn multi_page_remove_image(
  repo : MultiPageAtlasRepository,
  key : AssetKey,
) -> Unit {
  match find_key_page_index(repo.key_page_index, key) {
    Some(page_idx) =>
      if page_idx < repo.pages.length() {
        remove_atlas_image(repo.pages[page_idx], key)
        remove_key_page_index(repo, key)
      }
    None => ()
  }
}

///|
pub fn multi_page_list_dirty_bindings(
  repo : MultiPageAtlasRepository,
) -> Array[SourceImageBinding] {
  let bindings : Array[SourceImageBinding] = []
  for page in repo.pages {
    let page_bindings = list_dirty_atlas_page_bindings(page)
    for binding in page_bindings {
      bindings.push(binding)
    }
  }
  bindings
}

///|
pub fn multi_page_clear_dirty_flags(repo : MultiPageAtlasRepository) -> Int32 {
  let mut cleared = 0
  for page in repo.pages {
    cleared = cleared + clear_dirty_atlas_page_flags(page)
  }
  cleared
}

///|
pub fn multi_page_get_page_ids(repo : MultiPageAtlasRepository) -> Array[Int32] {
  let ids : Array[Int32] = []
  for page in repo.pages {
    ids.push(page.atlas_id)
  }
  ids
}

///|
pub fn multi_page_compact(
  repo : MultiPageAtlasRepository,
) -> AtlasCompactResult {
  let removed_page_ids : Array[Int32] = []
  // Collect indices of empty pages (reverse order for safe removal)
  let empty_indices : Array[Int32] = []
  for i in 0..<repo.pages.length() {
    if repo.pages[i].images.length() == 0 {
      removed_page_ids.push(repo.pages[i].atlas_id)
      empty_indices.push(i)
    }
  }
  // Remove empty pages from back to front
  let mut i = empty_indices.length() - 1
  while i >= 0 {
    let _ = repo.pages.remove(empty_indices[i])
    i = i - 1
  }
  // Rebuild key_page_index
  let next_index : Array[(String, Int32)] = []
  for page_idx in 0..<repo.pages.length() {
    let page = repo.pages[page_idx]
    for entry in page.images {
      next_index.push((entry.key.value, page_idx))
    }
  }
  repo.key_page_index = next_index
  {
    removed_page_ids,
    removed_page_count: removed_page_ids.length(),
    remaining_page_count: repo.pages.length(),
  }
}

///|
pub fn multi_page_stats(
  repo : MultiPageAtlasRepository,
) -> Array[AtlasPageStats] {
  let stats : Array[AtlasPageStats] = []
  for page in repo.pages {
    stats.push(atlas_page_stats(page))
  }
  stats
}
