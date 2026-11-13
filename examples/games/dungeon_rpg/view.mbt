///|
fn shade(color : Int32, amount : Double) -> Int32 {
  let r = ((color >> 16) & 255).to_double() * amount
  let g = ((color >> 8) & 255).to_double() * amount
  let b = (color & 255).to_double() * amount
  (r.to_int().min(255) << 16) | (g.to_int().min(255) << 8) | b.to_int().min(255)
}

///|
fn text(
  nodes : Array[@scene.SceneNode],
  x : Double,
  y : Double,
  content : String,
  scale : Double,
  color : Int32,
) -> Unit {
  nodes.push(@scene.label(x~, y~, content~, scale~, color~))
}

///|
fn wall_view(g : @sim.Game, nodes : Array[@scene.SceneNode]) -> Unit {
  // Static turn-based view: render only when the authoritative revision changes.
  nodes.push(@scene.rect(w=960, h=600, fill=0x0d1116))
  for i in 0..<18 {
    let a = i.to_double() / 18
    nodes.push(
      @scene.rect(
        x=0,
        y=a * 300,
        w=960,
        h=18,
        fill=shade(0x34383a, 0.15 + a * 0.3),
      ),
    )
    nodes.push(
      @scene.rect(
        x=0,
        y=300 + a * 300,
        w=960,
        h=18,
        fill=shade(0x454039, 0.14 + a * 0.5),
      ),
    )
  }
  for j in 1..<10 {
    let y = 300.0 + j.to_double() * j.to_double() * 3.7
    nodes.push(@scene.line(x0=0, y0=y, x1=960, y1=y, color=0x292826))
  }
  let base = g.facing.to_double() * @math.PI / 2 - @math.PI / 2
  let px = g.x.to_double() + 0.5
  let pz = g.z.to_double() + 0.5
  for col in 0..<240 {
    let offset = (col.to_double() / 239.0 - 0.5) * 1.13
    let angle = base + offset
    let dx = @math.cos(angle)
    let dz = @math.sin(angle)
    let mut distance = 0.035
    let mut hx = px
    let mut hz = pz
    while distance < 14 {
      hx = px + dx * distance
      hz = pz + dz * distance
      if g.blocked(hx.to_int(), hz.to_int()) {
        break
      }
      distance += 0.035
    }
    let corrected = (distance * @math.cos(offset)).max(0.12)
    let height = (470.0 / corrected).min(2000)
    let top = 300.0 - height / 2
    let fx = hx - hx.to_int().to_double()
    let fz = hz - hz.to_int().to_double()
    let side = fx < 0.06 || fx > 0.94
    let u = if side { fz } else { fx }
    let door = @sim.tile(g.floor, hx.to_int(), hz.to_int()) == @sim.Door
    let light = if g.light > 0 {
      1.2 / (1 + corrected * 0.23)
    } else {
      0.56 / (1 + corrected * 0.3)
    }
    let light = light * (if side { 0.79 } else { 1.0 })
    let stone = if door {
      0x73553a
    } else if g.floor == 0 {
      0x7e7566
    } else {
      0x566d71
    }
    nodes.push(
      @scene.rect(
        x=col.to_double() * 4,
        y=top,
        w=4.1,
        h=height,
        fill=shade(stone, light),
      ),
    )
    for row in 0..<6 {
      let y = top + height * row.to_double() / 6
      nodes.push(
        @scene.rect(
          x=col.to_double() * 4,
          y~,
          w=4.1,
          h=(height / 120).max(1),
          fill=shade(0x211f20, light),
        ),
      )
      let joint = u * 4 + (if row % 2 == 0 { 0.0 } else { 0.5 })
      if joint - joint.to_int().to_double() < 0.045 {
        nodes.push(
          @scene.rect(
            x=col.to_double() * 4,
            y~,
            w=4.1,
            h=height / 6,
            fill=shade(0x211f20, light),
          ),
        )
      }
    }
    if door && u > 0.69 && u < 0.75 {
      nodes.push(
        @scene.rect(
          x=col.to_double() * 4,
          y=300,
          w=4.1,
          h=height * 0.04,
          fill=0xb9a36a,
        ),
      )
    }
  }
  // Foreground light and stone framing keep orientation readable.
  nodes.push(@scene.rect(x=0, y=0, w=960, h=7, fill=0x13181a))
  nodes.push(@scene.rect(x=0, y=593, w=960, h=7, fill=0x13181a))
  for x in [60.0, 892.0] {
    nodes.push(@scene.rect(x~, y=360, w=8, h=65, fill=0x42392e))
    nodes.push(
      @scene.rect(
        x=x - 7,
        y=337,
        w=22,
        h=28,
        fill=if g.light > 0 { 0xaa592c } else { 0x34302b },
      ),
    )
    if g.light > 0 {
      nodes.push(@scene.rect(x=x - 2, y=328, w=12, h=28, fill=0xf2c878))
    }
  }
  let current = @sim.tile(g.floor, g.x, g.z)
  if g.mode != @sim.Fighting {
    if current == @sim.Down || current == @sim.Up || current == @sim.Exit {
      for i in 0..<6 {
        nodes.push(
          @scene.rect(
            x=340 - i.to_double() * 13,
            y=422 + i.to_double() * 18,
            w=280 + i.to_double() * 26,
            h=12,
            fill=shade(0x8d8571, 0.45 + i.to_double() * 0.05),
          ),
        )
      }
    }
    if current == @sim.Chest &&
      !g.looted.contains(@sim.cell_id(g.floor, g.x, g.z)) {
      nodes.push(@scene.rect(x=370, y=369, w=220, h=100, fill=0x53372c))
      nodes.push(@scene.rect(x=370, y=351, w=220, h=31, fill=0x795536))
      for x in [392.0, 550.0] {
        nodes.push(@scene.rect(x~, y=351, w=17, h=118, fill=0xb8a06b))
      }
      nodes.push(@scene.rect(x=467, y=391, w=26, h=31, fill=0xd0b979))
    }
    if current == @sim.Shrine {
      nodes.push(@scene.rect(x=425, y=402, w=110, h=87, fill=0x777d76))
      nodes.push(@scene.rect(x=405, y=390, w=150, h=20, fill=0xa6aaa0))
      nodes.push(@scene.rect(x=467, y=320, w=26, h=70, fill=0x8dbbad))
      nodes.push(@scene.rect(x=455, y=330, w=50, h=18, fill=0xb2e2cc))
    }
  }
}

///|
let beast : Array[String] = [
  "................", "..33........33..", "..333......333..", "...3333333333...",
  "..333333333333..", ".33333333333333.", ".33343333433333.", ".33311331133333.",
  "..333355333333..", "...3333333333...", "..222222222222..", ".22222222222222.",
  "2222222222222222", "2222222222222222", ".22222222222222.", "..22..2222..22..",
  ".222..2222..222.", "................",
]

///|
let skeleton : Array[String] = [
  ".....333333.....", "....33333333....", "....31133113....", "....31133113....",
  ".....333333.....", ".....313313.....", "......3333......", "..3....33....3..",
  ".33333333333333.", "...3..3333..3...", "...3.331133.3...", "...3..3333..3...",
  "...3...33...3...", "......3333......", ".....33..33.....", "....33....33....",
  "...333....333...", "................",
]

///|
let guardian : Array[String] = [
  "..44........44..", "..344......443..", "..333444444333..", "...3333333333...",
  "..333113311333..", "..333443344333..", "...3333333333...", ".22223333332222.",
  "2222222222222222", "2233222222223322", "2233222442223322", "2233222442223322",
  ".23322222222332.", ".23322222222332.", "..332222222233..", "..333222222333..",
  "...3333..3333...", "...3333..3333...", "..33333..33333..", "................",
]

///|
fn sprite(
  nodes : Array[@scene.SceneNode],
  kind : Int32,
  cx : Double,
  bottom : Double,
  scale : Double,
  alive : Bool,
  aspect : Double,
) -> Unit {
  let pattern = if kind == 4 {
    guardian
  } else if kind == 1 || kind == 3 || kind == 5 {
    skeleton
  } else {
    beast
  }
  let colors = if kind == 4 {
    [0x000000, 0xf5c67e, 0x344550, 0x8d9a9d, 0xbe955e, 0xe6b678]
  } else if kind == 1 {
    [0x000000, 0x1d2529, 0x585d5a, 0xc6c7ac, 0xf5d890, 0x847f6c]
  } else if kind == 3 {
    [0x000000, 0xf3ae77, 0x5d3c59, 0x988296, 0xecd5bb, 0xdfb884]
  } else if kind == 5 {
    [0x000000, 0xf6ecb3, 0x4e747e, 0xa2c9bb, 0xd5f2cd, 0xf8dda0]
  } else if kind == 2 {
    [0x000000, 0xffe0a1, 0x425d52, 0x78967a, 0xb9d0a0, 0xaac09b]
  } else {
    [0x000000, 0x191c22, 0x4a4344, 0x98806a, 0xf4c98d, 0xc09c7c]
  }
  let scale_y = scale * aspect / 1.6

  nodes.push(
    @scene.rect(
      x=cx - 8 * scale,
      y=bottom - 5,
      w=16 * scale,
      h=10,
      fill=0x0d1217,
      alpha=0.7,
    ),
  )
  for y in 0..<pattern.length() {
    for x in 0..<16 {
      let code = pattern[y][x].to_int() - 48
      if code > 0 && code < 6 {
        nodes.push(
          @scene.rect(
            x=cx + (x.to_double() - 8) * scale,
            y=bottom + (y - pattern.length()).to_double() * scale_y,
            w=scale + 0.2,
            h=scale_y + 0.2,
            fill=if alive { colors[code] } else { shade(colors[code], 0.5) },
            alpha=if alive { 1 } else { 0.35 },
          ),
        )
      }
    }
  }
}

///|
fn town_view(nodes : Array[@scene.SceneNode]) -> Unit {
  nodes.push(@scene.rect(w=960, h=600, fill=0x121d26))
  for i in 0..<65 {
    let x = ((i * 167 + 89) % 960).to_double()
    let y = ((i * 79 + 17) % 290).to_double()
    nodes.push(
      @scene.rect(
        x~,
        y~,
        w=2,
        h=2,
        fill=if i % 3 == 0 { 0x82989a } else { 0x526873 },
      ),
    )
  }
  nodes.push(@scene.rect(x=675, y=75, w=60, h=60, fill=0xdac49a))
  nodes.push(@scene.rect(x=689, y=66, w=57, h=58, fill=0x121d26))
  for i in 0..<15 {
    let x = i.to_double() * 75 - 30
    nodes.push(
      @scene.rect(
        x~,
        y=330 - (i * 37 % 80).to_double(),
        w=95,
        h=250,
        fill=0x25302e,
      ),
    )
    nodes.push(
      @scene.rect(
        x=x + 12,
        y=285 - (i * 23 % 50).to_double(),
        w=60,
        h=180,
        fill=0x26332e,
      ),
    )
  }
  nodes.push(@scene.rect(x=0, y=505, w=960, h=95, fill=0x30332d))
  for i in 0..<8 {
    nodes.push(
      @scene.rect(
        x=570 - i.to_double() * 12,
        y=506 + i.to_double() * 13,
        w=180 + i.to_double() * 24,
        h=10,
        fill=0x4a483d,
      ),
    )
  }
  for x in [515.0, 755.0] {
    nodes.push(@scene.rect(x~, y=188, w=80, h=335, fill=0x575c55))
    nodes.push(@scene.rect(x=x - 7, y=177, w=94, h=24, fill=0x7b7b68))
    nodes.push(@scene.rect(x=x + 14, y=214, w=49, h=8, fill=0x727362))
    for i in 0..<9 {
      nodes.push(
        @scene.rect(x~, y=240 + i.to_double() * 31, w=80, h=2, fill=0x373f3b),
      )
    }
    nodes.push(@scene.rect(x=x + 33, y=340, w=14, h=52, fill=0x2b302e))
    nodes.push(@scene.rect(x=x + 29, y=321, w=22, h=30, fill=0xc17b3d))
    nodes.push(@scene.rect(x=x + 35, y=314, w=10, h=29, fill=0xf5d391))
  }
  nodes.push(@scene.rect(x=595, y=216, w=160, h=291, fill=0x090f13))
  nodes.push(@scene.rect(x=595, y=191, w=160, h=30, fill=0x686c5e))
  nodes.push(@scene.rect(x=616, y=177, w=118, h=23, fill=0x686c5e))
  nodes.push(@scene.rect(x=637, y=164, w=75, h=17, fill=0x797c69))
  for x in [611.0, 639.0, 667.0, 695.0, 723.0] {
    nodes.push(@scene.rect(x~, y=228, w=5, h=275, fill=0x303936))
  }
  for y in [301.0, 407.0] {
    nodes.push(@scene.rect(x=601, y~, w=148, h=5, fill=0x464d41))
  }
  text(nodes, 674, 265, "FATHOM", 0.7, 0xcfbb8c)
}

///|
fn view(g : @sim.Game, aspect : Double, height : Double) -> @scene.SceneNode {
  let nodes : Array[@scene.SceneNode] = []
  if g.mode == @sim.Town || g.mode == @sim.Cleared {
    town_view(nodes)
  } else {
    let walls : Array[@scene.SceneNode] = []
    wall_view(g, walls)
    nodes.push(@scene.group(y=-80, children=walls))
    if g.battle is Some(b) {
      for i in 0..<b.foes.length() {
        let f = b.foes[i]
        if f.hp <= 0 && b.phase != @sim.Report && b.phase != @sim.Won {
          continue
        }
        let pose = @sim.enemy_pose(
          f.kind,
          b.foes.length(),
          i,
          aspect * height,
          height,
        )
        sprite(
          nodes,
          f.kind,
          pose.x,
          pose.baseline,
          pose.scale_x,
          f.hp > 0,
          aspect,
        )
      }
    } else if g.mode == @sim.Warning {
      sprite(nodes, 4, 480, 280, if aspect < 1 { 11 } else { 8 }, true, aspect)
    }
    text(
      nodes,
      480,
      44,
      "B\{g.floor+1}  /  \{["N","E","S","W"][g.facing]}",
      0.7,
      0xbfb69e,
    )
  }
  platform_overlay(g, nodes)
  @scene.group(children=nodes)
}
