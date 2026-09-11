///|
/// Benchmarks for the scene renderer. This is the path every 2D game in the
/// repo draws through -- `@scene.rect` / `@scene.label` build a node tree and
/// `render_scene` walks it into draw commands -- so it is where a per-quad cost
/// in `renderer2d` actually lands.
///
/// Both halves of a frame are measured separately because they regress for
/// different reasons: `build_` is the per-element node/attr allocation in
/// `elements.mbt`, `render_` is the command construction in `renderer2d`.

///|
/// A HUD-shaped tree: a background, a grid of sprites, two bars and a row of
/// labels. Deliberately text-heavy, because a label is a run of 3x5 dot glyphs
/// and so carries an order of magnitude more quads than the rect next to it.
fn bench_hud_scene(sprites : Int, labels : Int) -> SceneNode {
  let children : Array[SceneNode] = [rect(w=320.0, h=240.0, fill=0x1A2E1A)]
  for i in 0..<sprites {
    children.push(
      rect(
        x=(i % 40).to_double() * 8.0,
        y=(i / 40).to_double() * 8.0,
        w=6.0,
        h=6.0,
        fill=0xCC2222,
      ),
    )
  }
  children.push(
    group(x=4.0, y=4.0, children=[
      rect(w=60.0, h=6.0, fill=0x440000),
      rect(w=41.0, h=6.0, fill=0x00CC00),
    ]),
  )
  for i in 0..<labels {
    children.push(
      label(x=8.0, y=20.0 + i.to_double() * 12.0, content="SCORE 12345"),
    )
  }
  fragment(children)
}

///|
fn bench_hud_render(node : SceneNode) -> Array[@gfx.DrawTrianglesCommand] {
  render_scene(
    node,
    @gfx.new_image_handle(1, 320, 240),
    @gfx.new_shader_handle(1, "scene_bench"),
    320.0,
    240.0,
  )
}

///|
test "bench scene build hud 200 sprites 12 labels" (b : @bench.T) {
  b.bench(name="scene/build_hud_200x12", fn() {
    let node = bench_hud_scene(200, 12)
    b.keep(node)
  })
}

///|
test "bench scene render hud 200 sprites 12 labels" (b : @bench.T) {
  // The tree is built once, outside the closure: `moon bench` has no
  // per-iteration setup hook, so leaving the build in would measure
  // `build_hud_200x12` on top of the render every iteration.
  let node = bench_hud_scene(200, 12)
  b.bench(name="scene/render_hud_200x12", fn() {
    let cmds = bench_hud_render(node)
    b.keep(cmds.length())
  })
}

///|
/// Text only. A 12-line HUD is 132 glyphs, roughly 1,300 dots: the quad volume
/// a 2D frame in this repo is actually made of.
test "bench scene render labels only" (b : @bench.T) {
  let node = bench_hud_scene(0, 12)
  b.bench(name="scene/render_labels_12", fn() {
    let cmds = bench_hud_render(node)
    b.keep(cmds.length())
  })
}

///|
/// Rects only, same node count as the labels bench, so the two can be compared
/// directly: the difference is what dot-matrix text costs over a plain quad.
test "bench scene render rects only" (b : @bench.T) {
  let node = bench_hud_scene(12, 0)
  b.bench(name="scene/render_rects_12", fn() {
    let cmds = bench_hud_render(node)
    b.keep(cmds.length())
  })
}

///|
/// Floor for `scene/render_labels_12`: the same 12 text runs, called straight
/// into `renderer2d` with the node walk and the attribute resolution removed.
/// Subtract to price the walk -- 334.6 against 333.3 µs, so the walk and the
/// five attribute reads per label are 0.4% of the render. A label's cost is the
/// dot-matrix text, not the scene graph.
///
/// Also the stable half of a pair with
/// `primitives/append_dot_text_scene_content_12`, which issues the identical
/// call from inside `renderer2d`. Run under `moon bench -p` the two disagree by
/// about 2.5x; run under `moon bench` over the workspace they agree, and this
/// one is the half that does not move between the two.
/// See `docs/performance/dot-text-batching.md`.
test "bench scene append_dot_text direct" (b : @bench.T) {
  let frame = @renderer2d.RenderFrame2D::new(
    dst=@gfx.new_image_handle(1, 320, 240),
    shader=@gfx.new_shader_handle(1, "scene_bench"),
    screen_w=320,
    screen_h=240,
  )
  let color = @renderer2d.color_from_hex(0xFFFFFF)
  let chars = string_to_char_codes("SCORE 12345")
  b.bench(name="scene/append_dot_text_direct_12", fn() {
    let cmds : Array[@gfx.DrawTrianglesCommand] = []
    for i in 0..<12 {
      @renderer2d.append_dot_text(
        cmds,
        frame,
        @renderer2d.DotText2D::new(
          chars~,
          cx=8.0,
          cy=20.0 + i.to_double() * 12.0,
          color~,
          scale=1.0,
        ),
      )
    }
    b.keep(cmds.length())
  })
}
