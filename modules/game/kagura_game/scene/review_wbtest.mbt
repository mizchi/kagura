///|
fn scene_get_attr(
  attrs : Array[(String, @ui.Attr[Unit, SceneAttrValue])],
  key : String,
) -> SceneAttrValue? {
  for pair in attrs {
    let (attr_key, attr_value) = pair
    if attr_key == key {
      match attr_value {
        VStatic(value) => return Some(value)
        VDynamic(getter) => return Some(getter())
        VHandler(_) => ()
      }
    }
  }
  None
}

///|
test "scene rect stores numeric attributes without string conversion" {
  let node = rect(x=12.5, y=3.5, w=40.0, h=18.0, fill=0x112233, alpha=0.25)
  match node {
    Element(el) => {
      match scene_get_attr(el.attrs, "x") {
        Some(SceneDouble(value)) => assert_eq(value.to_int(), 12)
        _ => fail("expected SceneDouble x attribute")
      }
      match scene_get_attr(el.attrs, "fill") {
        Some(SceneInt(value)) => assert_eq(value, 0x112233)
        _ => fail("expected SceneInt fill attribute")
      }
      match scene_get_attr(el.attrs, "alpha") {
        Some(SceneDouble(value)) => assert_true((value - 0.25).abs() < 1.0e-6)
        _ => fail("expected SceneDouble alpha attribute")
      }
    }
    _ => fail("expected Element")
  }
}

///|
test "scene render_scene consumes typed attributes" {
  let dst = @gfx.new_image_handle(1, 320, 240)
  let shader = @gfx.new_shader_handle(2, "scene")
  let cmds = render_scene(
    fragment([
      rect(x=4.0, y=5.0, w=16.0, h=12.0, fill=0x00FF00),
      label(x=8.0, y=10.0, content="OK", color=0xFFFFFF, scale=1.0),
    ]),
    dst,
    shader,
    320.0,
    240.0,
  )
  assert_true(cmds.length() > 1)
}
