///|
fn main {
  @web_hooks.install("#app")
  let text_renderer = @text.load_text_renderer(
    "assets/Tiny5-Regular.ttf", 512, 500, 0,
  )
  let demo = DemoState::{ text_renderer, }
  @engine.run(
    update=fn(_input) {  },
    draw=fn(ctx) {
      let cmds = draw_frame(ctx, demo)
      flush_text_atlas_js(demo)
      cmds
    },
    width=screen_w,
    height=screen_h,
    title="Crater Renderer",
    canvas="#app",
  )
}

///|
fn flush_text_atlas_js(demo : DemoState) -> Unit {
  let renderer = match demo.text_renderer {
    Some(r) => r
    None => return
  }
  let dirty_pages = renderer.flush_dirty_pages()
  if dirty_pages.length() > 0 {
    let bindings : Array[@asset.SourceImageBinding] = []
    for page_info in dirty_pages {
      let page_idx = page_info.page_id - renderer.get_page_id()
      let page = renderer.get_page(page_idx)
      bindings.push(
        @asset.new_source_image_binding(
          page_info.page_id,
          page_info.width,
          page_info.height,
          1,
          Some(
            @asset.new_source_image_dirty_rect(
              0,
              0,
              page_info.width,
              page_info.height,
            ),
          ),
          @image_palette.checker_palette_from_seed(page_info.page_id),
          page.get_pixels(),
        ),
      )
    }
    let _ = @web_hooks.sync_source_images(bindings)
  }
}
