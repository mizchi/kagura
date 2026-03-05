///|
/// Finalize a pending texture upload from the JS gpu object.
pub fn finalize_texture_upload(
  state : GpuState,
  gpu : @core.Any,
  device : @core.Any,
) -> Unit {
  let pending = gpu._get("_pendingTexture")
  if @core.is_nullish(pending) {
    return
  }
  let image_id = pending._get("imageId").cast_int()
  let width = pending._get("width").cast_int()
  let height = pending._get("height").cast_int()
  let pixels = pending._get("pixels")
  gpu._set("_pendingTexture", @core.null())
  if width <= 0 || height <= 0 {
    return
  }
  match state.textures.get(image_id) {
    Some(existing) =>
      if existing.width != width || existing.height != height {
        ffi_destroy(existing.texture)
        state.textures.remove(image_id)
      }
    None => ()
  }
  let queue = ffi_queue(device)
  match state.textures.get(image_id) {
    Some(entry) => {
      let tex_dest = @core.new_object()
      tex_dest._set("texture", entry.texture)
      let data_layout = @core.new_object()
      data_layout._set("bytesPerRow", @core.any(width * 4))
      queue._call("writeTexture", [
        tex_dest,
        pixels,
        data_layout,
        make_extent3d(width, height),
      ])
      |> ignore
      entry.revision = entry.revision + 1
    }
    None => {
      let tex_desc = @core.new_object()
      tex_desc._set("size", make_extent3d(width, height))
      tex_desc._set("format", @core.any("rgba8unorm"))
      tex_desc._set(
        "usage",
        @core.any(TEXTURE_USAGE_TEXTURE_BINDING | TEXTURE_USAGE_COPY_DST),
      )
      let texture = ffi_create_texture(device, tex_desc)
      let view = ffi_create_view(texture)
      let sampler_desc = @core.new_object()
      sampler_desc._set("magFilter", @core.any("nearest"))
      sampler_desc._set("minFilter", @core.any("nearest"))
      sampler_desc._set("addressModeU", @core.any("clamp-to-edge"))
      sampler_desc._set("addressModeV", @core.any("clamp-to-edge"))
      let sampler = ffi_create_sampler(device, sampler_desc)
      let tex_dest = @core.new_object()
      tex_dest._set("texture", texture)
      let data_layout = @core.new_object()
      data_layout._set("bytesPerRow", @core.any(width * 4))
      queue._call("writeTexture", [
        tex_dest,
        pixels,
        data_layout,
        make_extent3d(width, height),
      ])
      |> ignore
      let entry : TextureEntry = {
        texture,
        view,
        sampler,
        width,
        height,
        revision: 1,
      }
      state.textures.set(image_id, entry)
      let js_textures = gpu._get("textures")
      if not(@core.is_nullish(js_textures)) {
        let js_entry = @core.new_object()
        js_entry._set("texture", texture)
        js_entry._set("view", view)
        js_entry._set("sampler", sampler)
        js_entry._set("width", @core.any(width))
        js_entry._set("height", @core.any(height))
        js_entry._set("revision", @core.any(1))
        js_textures._call("set", [@core.any(image_id), js_entry]) |> ignore
      }
    }
  }
}

///|
/// Ensure an off-screen render target exists for the given imageId/dimensions
pub fn ensure_render_target(
  state : GpuState,
  device : @core.Any,
  image_id : Int,
  width : Int,
  height : Int,
) -> RenderTargetEntry {
  match state.render_targets.get(image_id) {
    Some(existing) =>
      if existing.width == width && existing.height == height {
        return existing
      } else {
        ffi_destroy(existing.texture)
      }
    None => ()
  }
  let tex_desc = @core.new_object()
  tex_desc._set("size", make_extent3d(width, height))
  tex_desc._set("format", @core.any("rgba8unorm"))
  tex_desc._set(
    "usage",
    @core.any(
      TEXTURE_USAGE_TEXTURE_BINDING |
      TEXTURE_USAGE_RENDER_ATTACHMENT |
      TEXTURE_USAGE_COPY_DST,
    ),
  )
  let texture = ffi_create_texture(device, tex_desc)
  let view = ffi_create_view(texture)
  let entry : RenderTargetEntry = { texture, view, width, height }
  state.render_targets.set(image_id, entry)
  let sampler = match state.linear_sampler {
    Some(s) => s
    None =>
      match state.default_sampler {
        Some(s) => s
        None => {
          let desc = @core.new_object()
          desc._set("magFilter", @core.any("linear"))
          desc._set("minFilter", @core.any("linear"))
          ffi_create_sampler(device, desc)
        }
      }
  }
  let tex_entry : TextureEntry = {
    texture,
    view,
    sampler,
    width,
    height,
    revision: -1,
  }
  state.textures.set(image_id, tex_entry)
  entry
}

///|
/// Ensure a depth texture exists for the given dimensions
pub fn ensure_depth_texture(
  state : GpuState,
  device : @core.Any,
  width : Int,
  height : Int,
) -> DepthTextureEntry {
  let key = "\{width}x\{height}"
  match state.depth_textures.get(key) {
    Some(existing) => return existing
    None => ()
  }
  let tex_desc = @core.new_object()
  tex_desc._set("size", make_extent3d(width, height))
  tex_desc._set("format", @core.any("depth24plus"))
  tex_desc._set("usage", @core.any(TEXTURE_USAGE_RENDER_ATTACHMENT))
  let texture = ffi_create_texture(device, tex_desc)
  let view = ffi_create_view(texture)
  let entry : DepthTextureEntry = { texture, view, width, height }
  state.depth_textures.set(key, entry)
  entry
}
