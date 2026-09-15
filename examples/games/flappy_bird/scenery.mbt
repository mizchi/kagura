///|
fn pixel_panel(
  x : Double,
  y : Double,
  w : Double,
  h : Double,
  color : Int,
) -> @scene.SceneNode {
  @scene.group(x~, y~, children=[
    @scene.rect(x=3.0, w=w - 6.0, h~, fill=color),
    @scene.rect(y=3.0, w~, h=h - 6.0, fill=color),
  ])
}

///|
fn sky_details(
  sw : Double,
  floor : Double,
  time : Double,
) -> Array[@scene.SceneNode] {
  let nodes = [
    @scene.rect(y=floor * 0.36, w=sw, h=floor * 0.64, fill=0xB9DFD5),
    @scene.rect(y=floor * 0.66, w=sw, h=floor * 0.34, fill=0xDDE8BE),
    pixel_panel(sw - 62.0, 24.0, 32.0, 32.0, 0xF6E7AC),
    pixel_panel(sw - 59.0, 27.0, 26.0, 26.0, 0xFFF6DA),
  ]
  for i in 0..<5 {
    let x = (i.to_double() * 87.0 + sw + 70.0 - time * 0.12) % (sw + 70.0) -
      60.0
    let y = 20.0 + (i * 37 % 75).to_double()
    nodes.push(
      @scene.group(x~, y~, children=[
        pixel_panel(0.0, 10.0, 48.0, 12.0, 0x8BBFB8),
        pixel_panel(0.0, 7.0, 48.0, 12.0, 0xFFF6DA),
        pixel_panel(9.0, 1.0, 25.0, 15.0, 0xFFF6DA),
        @scene.rect(x=16.0, w=12.0, h=3.0, fill=0xFFF6DA),
      ]),
    )
  }
  for i in 0..<((sw / 64.0).to_int() + 2) {
    let x = i.to_double() * 64.0 - time * 0.18 % 64.0
    let y = floor - 55.0 - (i * 11 % 24).to_double()
    nodes.push(@scene.rect(x=x + 12.0, y~, w=42.0, h=floor - y, fill=0x9AC5AD))
    nodes.push(
      @scene.rect(x~, y=y + 14.0, w=64.0, h=floor - y - 14.0, fill=0x9AC5AD),
    )
    nodes.push(@scene.rect(x=x + 20.0, y=y + 6.0, w=18.0, h=3.0, fill=0xB9D6B1))
  }
  for i in 0..<((sw / 45.0).to_int() + 2) {
    let x = i.to_double() * 45.0 - time * 0.38 % 45.0
    nodes.push(pixel_panel(x, floor - 24.0, 43.0, 32.0, 0x659A82))
    nodes.push(pixel_panel(x + 7.0, floor - 30.0, 23.0, 24.0, 0x659A82))
  }
  nodes
}

///|
fn ground_details(
  sw : Double,
  height : Double,
  time : Double,
) -> Array[@scene.SceneNode] {
  let nodes = [
    @scene.rect(w=sw, h=3.0, fill=0x214B4C),
    @scene.rect(y=3.0, w=sw, h=5.0, fill=0xD7DF95),
    @scene.rect(y=8.0, w=sw, h=2.0, fill=0xB99965),
  ]
  if height > 10.0 {
    nodes.push(@scene.rect(y=10.0, w=sw, h=height - 10.0, fill=0xE6D0A3))
  }
  for i in 0..<((sw / 16.0).to_int() + 1) {
    let x = i.to_double() * 16.0 - time * pipe_speed % 16.0
    nodes.push(@scene.rect(x~, y=4.0, w=7.0, h=2.0, fill=0x87AD74))
    nodes.push(@scene.rect(x=x + 5.0, y=14.0, w=3.0, h=2.0, fill=0xC6A77B))
  }
  nodes
}
