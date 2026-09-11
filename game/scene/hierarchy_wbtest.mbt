///|
test "2D resolved scene shares one dynamic evaluation with rendering and hierarchy" {
  let mut calls = 0
  let scene = resolve(
    group(key="world", children=[
      rect(key="bird", w=12.0, h=12.0),
      for_each(fn() {
        calls += 1
        [rect(key="pipe", w=20.0, h=80.0)]
      }),
    ]),
  )
  assert_eq(calls, 1)
  assert_eq(scene.hierarchy[0].children[0].id, "world/bird")
  assert_true(scene.hierarchy[0].children[1].generated)
  let _ = render_scene(
    scene.node,
    @gfx.new_image_handle(1, 320, 240),
    @gfx.new_shader_handle(2, "scene"),
    320.0,
    240.0,
  )
  assert_eq(calls, 1)
  let rejected = try {
    let _ = resolve(
      group(key="world", children=[
        rect(key="a", w=1.0, h=1.0),
        rect(key="a", w=1.0, h=1.0),
      ]),
    )
    false
  } catch {
    _ => true
  }
  assert_true(rejected)
}
