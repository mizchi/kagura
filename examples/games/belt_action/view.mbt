///|
let ink = 0x101b25

///|
let cream = 0xf8e8c3

///|
let amber = 0xffc568

///|
let coral = 0xf17870

///|
let cyan = 0x83d9ce

///|
fn box(
  nodes : Array[@scene.SceneNode],
  x : Double,
  y : Double,
  w : Double,
  h : Double,
  color : Int32,
  alpha~ : Double = 1,
) -> Unit {
  nodes.push(@scene.rect(x~, y~, w~, h~, fill=color, alpha~))
}

///|
fn text(
  nodes : Array[@scene.SceneNode],
  x : Double,
  y : Double,
  content : String,
  color~ : Int32 = cream,
  scale~ : Double = 2,
) -> Unit {
  let content = content.to_upper()
  let scale = scale * 0.5
  let (w, h) = @renderer2d.dot_text_size(content.length(), scale~)
  nodes.push(@scene.label(x=x + w / 2, y=y + h / 2, content~, color~, scale~))
}

///|
fn stroke(
  nodes : Array[@scene.SceneNode],
  x0 : Double,
  y0 : Double,
  x1 : Double,
  y1 : Double,
  color : Int32,
  width~ : Double = 2,
) -> Unit {
  nodes.push(@scene.line(x0~, y0~, x1~, y1~, color~, width~))
}

///|
fn backdrop(g : @sim.Game) -> @scene.SceneNode {
  let n : Array[@scene.SceneNode] = []
  box(n, 0, 0, 960, 540, ink)
  box(n, 0, 93, 960, 190, 0x172c35)
  for i = 0; i < 18; i = i + 1 {
    let x = i.to_double() * 84 - g.camera * 0.22 % 84
    let h = (i * 37 % 80 + 54).to_double()
    box(n, x, 242 - h, 66, h, 0x1d3840)
    for j = 0; j < 3; j = j + 1 {
      box(n, x + 12 + j.to_double() * 16, 257 - h, 5, 3, 0x456066)
    }
  }
  // Repeated loading bays establish lateral progress; scenery stays behind the combat silhouettes.
  for i = 0; i < 9; i = i + 1 {
    let x = i.to_double() * 270 - g.camera * 0.65
    box(n, x, 138, 230, 144, 0x10262d)
    box(n, x + 10, 150, 210, 127, 0x233b40)
    for j = 0; j < 9; j = j + 1 {
      stroke(
        n,
        x + 11,
        163 + j.to_double() * 13,
        x + 220,
        163 + j.to_double() * 13,
        0x2c464a,
        width=1,
      )
    }
    box(n, x + 67, 128, 96, 4, 0x92aca2)
    text(n, x + 92, 180, "0\{i + 1}", color=0x516c6b, scale=4)
  }
  box(n, 0, 278, 960, 8, 0x99a79a)
  box(n, 0, 286, 960, 181, 0x34494a)
  for i = 0; i < 14; i = i + 1 {
    let x = i.to_double() * 120 - g.camera % 120
    stroke(n, x, 287, x - 135, 467, 0x405758, width=1)
  }
  for y in [306.0, 346.0, 398.0, 460.0] {
    stroke(n, 0, y, 960, y, 0x405758, width=1)
  }
  box(n, 0, 468, 960, 72, 0x12232b)
  for i = 0; i < 24; i = i + 1 {
    let x = i.to_double() * 64 - g.camera * 1.1 % 64
    box(n, x, 468, 34, 6, 0x9e8b5d)
  }
  let gate = g.gate_x() - g.camera
  if g.remaining() > 0 {
    for j = 0; j < 5; j = j + 1 {
      box(n, gate, 290 + j.to_double() * 34, 5, 18, coral, alpha=0.45)
    }
    text(n, gate - 33, 275, "LOCKED", color=coral, scale=1.5)
  } else if g.stage < 2 {
    text(n, 768, 294, "GO  >>", color=amber, scale=3)
    stroke(n, 820, 368, 883, 368, amber, width=4)
    stroke(n, 870, 356, 884, 368, amber, width=4)
    stroke(n, 870, 380, 884, 368, amber, width=4)
  }
  @scene.group(key="dock", children=n)
}

///|
fn fighter(
  x : Double,
  y : Double,
  facing : Double,
  action : String,
  age : Int32,
  kind : Int32,
  flash : Bool,
  tick : Int32,
) -> @scene.SceneNode {
  let n : Array[@scene.SceneNode] = []
  let boss = kind == 3
  let scale = if boss { 1.32 } else { 1.0 }
  let hero = kind < 0
  let coat = if flash {
    cream
  } else if hero {
    amber
  } else if kind == 1 {
    0x8198a1
  } else if kind == 2 {
    0x9ca386
  } else {
    coral
  }
  let trousers = if hero { 0x243944 } else { 0x272c39 }
  let swing = @math.sin(tick.to_double() * 0.19 + x * 0.03) *
    (if action == "idle" || action == "approach" { 7.0 } else { 1.5 })
  let attack = action == "strike" || action == "breaker" || action == "active"
  let heavy = action == "breaker"
  let extended = if action == "strike" {
    age >= 4 && age <= 10
  } else if heavy {
    age >= 13 && age <= 22
  } else {
    action == "active"
  }
  let windup = action == "windup" || (heavy && age < 13)
  let low = action == "evade" ||
    action == "stunned" ||
    action == "hurt" ||
    action == "recover"
  let lean = if extended {
    10.0
  } else if windup {
    -7.0
  } else if low {
    9.0
  } else {
    0.0
  }
  fn px(v : Double) -> Double {
    facing * v * scale
  }
  fn py(v : Double) -> Double {
    (v + (if low { 13.0 } else { 0.0 })) * scale
  }
  // Ground shadow fixes the foot position even while the upper body leans.
  box(n, -23 * scale, -3, 46 * scale, 7, 0x122a30, alpha=0.65)
  stroke(n, px(-6), py(-34), px(-12 - swing), -6, trousers, width=10 * scale)
  stroke(n, px(7), py(-34), px(15 + swing), -6, trousers, width=10 * scale)
  box(n, px(-12 - swing) - 7, -7, 15, 6, cream)
  box(n, px(15 + swing) - 5, -7, 18, 6, cream)
  // Far arm, waist, jacket, collar.
  stroke(
    n,
    px(-7 + lean),
    py(-66),
    px(-18 + lean),
    py(-42),
    coat,
    width=10 * scale,
  )
  box(n, px(lean) - 14 * scale, py(-72), 29 * scale, 39 * scale, coat)
  box(n, px(lean) - 14 * scale, py(-39), 29 * scale, 5 * scale, 0xedd5b5)
  box(n, px(lean) - 6 * scale, py(-76), 11 * scale, 13 * scale, cream)
  box(
    n,
    px(lean) - 11 * scale,
    py(-95),
    22 * scale,
    23 * scale,
    if flash {
      cream
    } else {
      0xe1b79a
    },
  )
  box(
    n,
    px(lean) - 12 * scale,
    py(-99),
    25 * scale,
    8 * scale,
    if hero {
      0x172b35
    } else {
      0x402e39
    },
  )
  box(n, px(lean + 6) - 3, py(-87), 4, 3, ink)
  if hero {
    box(n, px(lean) - 13, py(-90), 25, 4, cream)
    stroke(
      n,
      px(lean - 10),
      py(-87),
      px(lean - 27),
      py(-78 + swing),
      cream,
      width=3,
    )
    box(n, px(lean) - 13, py(-67), 5, 12, 0xeaf0d2)
  }
  let fist_x = if extended { 58.0 } else if windup { -17.0 } else { 20.0 }
  let fist_y = if extended { -61.0 } else if windup { -76.0 } else { -51.0 }
  stroke(
    n,
    px(lean + 6),
    py(-66),
    px(fist_x - 9),
    py(fist_y + 4),
    coat,
    width=12 * scale,
  )
  box(
    n,
    px(fist_x) - 8 * scale,
    py(fist_y) - 6 * scale,
    16 * scale,
    13 * scale,
    if hero {
      cream
    } else {
      0xc7b4a4
    },
  )
  if kind == 1 && action == "approach" {
    box(n, px(23) - 4, py(-74), 12, 43, cyan)
    box(n, px(23), py(-68), 4, 30, 0x355d65)
  }
  if (kind == 1 || kind == 3) &&
    (action == "windup" || action == "active" || action == "reset") {
    stroke(n, px(22), py(-77), px(30), py(-77), cyan, width=3)
    stroke(n, px(30), py(-77), px(30), py(-38), cyan, width=3)
    stroke(n, px(30), py(-38), px(22), py(-38), cyan, width=3)
  }
  if boss {
    box(n, px(lean) - 16, py(-104), 35, 7, amber)
    box(n, px(lean) - 11, py(-111), 25, 9, amber)
  }
  if windup {
    // Draw the warning symbol directly: the shared 3x5 font has no '!'.
    let warning_x = if boss { 42.0 } else { 0.0 }
    box(n, (warning_x - 2) * scale, -124 * scale, 4 * scale, 7 * scale, amber)
    box(n, (warning_x - 2) * scale, -115 * scale, 4 * scale, 2 * scale, amber)
    stroke(n, px(-26), py(-72), px(-34), py(-81), amber)
  }
  if attack && extended {
    stroke(
      n,
      px(37),
      py(-85),
      px(76),
      py(-60),
      if heavy {
        cyan
      } else {
        cream
      },
      width=4,
    )
    stroke(
      n,
      px(76),
      py(-60),
      px(40),
      py(-34),
      if heavy {
        cyan
      } else {
        amber
      },
      width=3,
    )
  }
  @scene.group(x~, y~, children=n)
}

///|
fn enemy_view(g : @sim.Game, e : @sim.Enemy) -> @scene.SceneNode {
  let n : Array[@scene.SceneNode] = []
  if e.hp <= 0 {
    if e.death_age < 20 {
      box(n, -26, -14, 52, 12, coral, alpha=1 - e.death_age.to_double() / 20)
      stroke(n, -28, -3, 27, -3, 0xc7b4a4, width=5)
    }
  } else {
    n.push(fighter(0, 0, e.facing, e.action, 0, e.kind, e.flash > 0, g.tick))
    let w = if e.kind == 3 { 70.0 } else { 42.0 }
    let top = if e.kind == 3 { -169.0 } else { -137.0 }
    if e.kind == 3 {
      text(n, -35, top - 13, "FOREMAN", color=coral, scale=1.5)
    }
    if e.kind == 1 || e.kind == 3 {
      if e.braced() || e.open() {
        text(
          n,
          -29,
          top - (if e.kind == 3 { 29.0 } else { 17.0 }),
          if e.braced() {
            "BRACED"
          } else {
            "OPEN"
          },
          color=cyan,
          scale=2,
        )
      }
    }
    box(n, -w / 2, top, w, 4, 0x142831)
    box(
      n,
      -w / 2,
      top,
      w * e.hp.to_double() / e.max_hp.to_double(),
      4,
      if e.kind == 1 {
        cyan
      } else {
        coral
      },
    )
    if e.action == "windup" || e.open() {
      box(n, -w / 2, top + 8, w, 4, ink)
      box(
        n,
        -w / 2,
        top + 8,
        w *
        (if e.action == "windup" {
          1 - e.phase_remaining()
        } else {
          e.phase_remaining()
        }),
        4,
        if e.action == "windup" {
          amber
        } else {
          cyan
        },
      )
    }
  }
  @scene.subject(
    "enemy:\{e.id}",
    @scene.group(key="enemy-\{e.id}", x=e.x - g.camera, y=e.z, children=n),
  )
}

///|
fn view(g : @sim.Game) -> @scene.SceneNode {
  let world : Array[@scene.SceneNode] = [backdrop(g)]
  for e in g.enemies {
    if e.hp > 0 && (e.action == "windup" || e.action == "active") {
      let x = e.x - g.camera
      let edge = x + e.facing * e.attack_reach()
      let from = x - e.facing * 12
      let depth = e.attack_depth()
      let y = e.aim_z
      let c = if e.action == "active" { coral } else { amber }
      world.push(
        @scene.rect(
          key="attack-lane-\{e.id}",
          x=from.min(edge),
          y=y - depth,
          w=(edge - from).abs(),
          h=depth * 2,
          fill=c,
          alpha=0.13,
        ),
      )
      stroke(world, from, y - depth, edge, y - depth, c)
      stroke(world, from, y + depth, edge, y + depth, c)
      stroke(world, edge, y - depth, edge, y + depth, c)
    }
  }
  let actors : Array[(Double, Int32)] = [(g.player.z, -1)]
  for i = 0; i < g.enemies.length(); i = i + 1 {
    actors.push((g.enemies[i].z, i))
  }
  actors.sort_by((a, b) => a.0.compare(b.0))
  for (_, id) in actors {
    if id < 0 {
      let p = g.player
      if p.invulnerable == 0 || p.action == "evade" || g.tick % 6 < 4 {
        if p.action == "evade" {
          box(
            world,
            p.x - g.camera - p.evade_x * 24 - 16,
            p.z - 60,
            28,
            52,
            cyan,
            alpha=0.2,
          )
        }
        world.push(
          @scene.subject(
            "player",
            fighter(
              p.x - g.camera,
              p.z,
              p.facing,
              p.action,
              p.age,
              -1,
              p.action == "hurt",
              g.tick,
            ),
          ),
        )
      }
    } else {
      world.push(enemy_view(g, g.enemies[id]))
    }
  }
  for b in g.bursts {
    if b.kind == "hit" ||
      b.kind == "heavy" ||
      b.kind == "break" ||
      b.kind == "block" ||
      b.kind == "hurt" {
      let x = b.x - g.camera
      let y = b.z - 58
      let r = 13.0 + b.age.to_double() * 1.8
      let c = if b.kind == "block" || b.kind == "break" { cyan } else { cream }
      if b.age < 12 {
        for i = 0; i < 8; i = i + 1 {
          let a = i.to_double() * @math.PI / 4
          stroke(
            world,
            x + @math.cos(a) * r * 0.5,
            y + @math.sin(a) * r * 0.5,
            x + @math.cos(a) * r,
            y + @math.sin(a) * r,
            c,
            width=if i % 2 == 0 { 4.0 } else { 2.0 },
          )
        }
        if b.kind == "block" {
          text(world, x - 25, y - 41, "GUARD", color=cyan, scale=1.5)
        }
        if b.kind == "break" {
          text(world, x - 25, y - 41, "BREAK!", color=cyan, scale=1.5)
        }
      }
    }
  }
  let n : Array[@scene.SceneNode] = [
    @scene.rect(w=960, h=540, fill=ink),
    @scene.group(
      key="world",
      x=if g.shake > 0 && g.mode == "playing" {
        (if g.frames % 2 == 0 { -1.0 } else { 1.0 }) * g.shake.to_double() * 0.4
      } else {
        0.0
      },
      children=world,
    ),
  ]
  // HUD lives outside the shake group.
  box(n, 0, 0, 960, 86, ink)
  box(n, 28, 24, 4, 38, amber)
  text(n, 42, 22, "AFTERSHIFT", scale=2.5)
  text(n, 42, 47, "LAST SHIFT. FIRST PUNCH.", color=0x8da9aa, scale=1.25)
  text(n, 280, 20, "HEALTH", color=0x8da9aa, scale=1.25)
  for i = 0; i < 6; i = i + 1 {
    box(
      n,
      280 + i.to_double() * 27,
      40,
      22,
      12,
      if i < g.player.hp {
        amber
      } else {
        0x30454c
      },
    )
  }
  text(n, 476, 20, "EVADE", color=0x8da9aa, scale=1.25)
  box(n, 476, 40, 94, 5, 0x30454c)
  box(n, 476, 40, 94 * (1 - g.player.evade_cooldown.to_double() / 58), 5, cyan)
  text(
    n,
    476,
    55,
    if g.player.evade_cooldown == 0 {
      "READY"
    } else {
      "RECHARGING"
    },
    color=cyan,
    scale=1,
  )
  text(n, 630, 20, "SECTOR", color=0x8da9aa, scale=1.25)
  text(n, 630, 40, "0\{g.stage + 1} / 03", scale=2)
  text(n, 811, 20, "SCORE", color=0x8da9aa, scale=1.25)
  text(n, 811, 40, "\{g.score}", color=amber, scale=2)
  if g.chain > 1 && g.mode == "playing" {
    text(n, 44, 120, "\{g.chain} HITS", color=amber, scale=3)
  }
  if g.announce > 0 && g.mode == "playing" {
    text(
      n,
      344,
      110,
      match g.stage {
        0 => "01 / LOADING BAY"
        1 => "02 / SECURITY"
        _ => "03 / THE FOREMAN"
      },
      color=amber,
      scale=2,
    )
  }
  text(n, 30, 490, "MOVE  WASD / ARROWS", color=0xa9b9b5, scale=1.5)
  text(n, 302, 490, "J  COMBO", color=cream, scale=1.5)
  text(n, 462, 490, "K  GUARD BREAK", color=cyan, scale=1.5)
  text(n, 700, 490, "SPACE  EVADE", color=cream, scale=1.5)
  text(
    n,
    30,
    518,
    if g.stage == 0 {
      "READ THE WINDUP. STEP OUT. HIT BACK."
    } else {
      "BRACED: EVADE. OPEN: HIT BACK."
    },
    color=0x718e91,
    scale=1.25,
  )
  text(n, 766, 518, "ESC  PAUSE", color=0x718e91, scale=1.25)
  if g.mode != "playing" {
    box(n, 52, 104, 584, 176, ink, alpha=0.97)
    box(n, 52, 104, 4, 176, amber)
    let title = match g.mode {
      "title" => "CLOCK OUT."
      "paused" => "ON A BREAK."
      "cleared" => "SHIFT COMPLETE."
      _ => "ONE MORE SHIFT?"
    }
    text(n, 78, 128, title, color=amber, scale=4)
    let line = match g.mode {
      "title" => "Three sectors. One foreman. Find your way home."
      "paused" => "Take your time. Your shift can wait."
      "cleared" => "\{g.score} POINTS   /   BEST CHAIN \{g.best_combo}"
      _ => "\{g.score} POINTS   /   SECTOR 0\{g.stage + 1}"
    }
    text(n, 78, 181, line, color=cream, scale=1.5)
    text(
      n,
      78,
      211,
      if g.mode == "title" {
        "Hold J for a three-hit combo. K breaks shields."
      } else if g.mode == "paused" {
        "Enter resumes. R starts a fresh shift."
      } else {
        "Enter to play again. R restarts immediately."
      },
      color=0xa4b9b6,
      scale=1.5,
    )
    text(
      n,
      78,
      246,
      if g.mode == "paused" {
        "PRESS ENTER / ESC TO RESUME"
      } else if g.mode == "title" {
        "PRESS ENTER OR J TO START  >>"
      } else {
        "PRESS ENTER TO RETRY  >>"
      },
      color=cyan,
      scale=1.5,
    )
  }
  @scene.group(key="aftershift", name="AFTERSHIFT", children=n)
}
