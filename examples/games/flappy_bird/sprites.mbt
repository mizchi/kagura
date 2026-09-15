///|
fn pipe_view(
  x : Double,
  y : Double,
  height : Double,
  upper : Bool,
) -> @scene.SceneNode {
  let rim = if height < 8.0 { height } else { 8.0 }
  let rim_y = if upper { height - rim } else { 0.0 }
  @scene.rect(x~, y~, w=pipe_width, h=height, fill=0x214B4C, children=[
    @scene.rect(x=2.0, w=pipe_width - 4.0, h=height, fill=0x5D9F81),
    @scene.rect(x=4.0, w=6.0, h=height, fill=0xB9D78C),
    @scene.rect(x=10.0, w=3.0, h=height, fill=0x87BB87),
    @scene.rect(x=pipe_width - 8.0, w=5.0, h=height, fill=0x407878),
    @scene.rect(y=rim_y, w=pipe_width, h=rim, fill=0x214B4C),
    @scene.rect(
      x=2.0,
      y=rim_y + rim * 0.25,
      w=pipe_width - 4.0,
      h=rim * 0.5,
      fill=0x87BB87,
    ),
    @scene.rect(x=4.0, y=rim_y + rim * 0.25, w=7.0, h=rim * 0.25, fill=0xD7DF95),
  ])
}

///|
fn bird_details(
  w : Double,
  h : Double,
  color : Int,
  frame : Int,
  velocity : Double,
  dead : Bool,
) -> Array[@scene.SceneNode] {
  let wing_y = if dead { 7.0 } else if frame / 6 % 2 == 0 { 5.0 } else { 8.0 }
  let beak_y = if velocity > 2.0 { 7.0 } else { 5.0 }
  let pixels : Array[(Double, Double, Double, Double, Int)] = [
    (2.0, 0.0, 7.0, 1.0, 0x7B493D),
    (1.0, 1.0, 9.0, 1.0, 0x7B493D),
    (0.0, 3.0, 1.0, 6.0, 0x7B493D),
    (1.0, 2.0, 9.0, 8.0, color),
    (2.0, 10.0, 7.0, 1.0, 0x7B493D),
    (3.0, 11.0, 4.0, 1.0, 0x7B493D),
    (2.0, 2.0, 5.0, 2.0, 0xFFE6A2),
    (4.0, 7.0, 5.0, 3.0, 0xFFF6DA),
    (7.0, 2.0, 3.0, 4.0, 0xFFF6DA),
    (9.0, 3.0, 1.0, 2.0, 0x214B4C),
    (9.0, beak_y, 3.0, 2.0, 0xE68848),
    (10.0, beak_y + 2.0, 2.0, 1.0, 0x9A4F35),
    (0.0, wing_y, 5.0, 3.0, 0x9A4F35),
    (1.0, wing_y, 3.0, 2.0, 0xFFE6A2),
  ]
  pixels.map(fn(pixel) {
    let (x, y, pw, ph, fill) = pixel
    @scene.rect(
      x=x * w / 12.0,
      y=y * h / 12.0,
      w=pw * w / 12.0,
      h=ph * h / 12.0,
      fill~,
    )
  })
}
