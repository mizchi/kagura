// Visualization (Vis-A): draw the diagram, live pool values, edges with
// arrowheads + rate labels, and a HUD. Uses renderer2d primitives only.

///|
fn push_rect(
  cmds : Array[@gfx.DrawTrianglesCommand],
  frame : @renderer2d.RenderFrame2D,
  x : Double,
  y : Double,
  w : Double,
  h : Double,
  hex : Int,
) -> Unit {
  @renderer2d.append_rect_fill(
    cmds,
    frame,
    @renderer2d.RectFill2D::new(x~, y~, w~, h~, color=@renderer2d.color_from_hex(hex)),
  )
}

///|
fn push_line(
  cmds : Array[@gfx.DrawTrianglesCommand],
  frame : @renderer2d.RenderFrame2D,
  x0 : Double,
  y0 : Double,
  x1 : Double,
  y1 : Double,
  width : Double,
  hex : Int,
) -> Unit {
  @renderer2d.append_line(
    cmds,
    frame,
    @renderer2d.Line2D::new(
      x0~,
      y0~,
      x1~,
      y1~,
      width~,
      color=@renderer2d.color_from_hex(hex),
    ),
  )
}

///|
fn push_text(
  cmds : Array[@gfx.DrawTrianglesCommand],
  frame : @renderer2d.RenderFrame2D,
  s : String,
  cx : Double,
  cy : Double,
  scale : Double,
  hex : Int,
) -> Unit {
  let chars : Array[Int] = []
  for ch in s {
    chars.push(ch.to_int())
  }
  @renderer2d.append_dot_text(
    cmds,
    frame,
    @renderer2d.DotText2D::new(
      chars~,
      cx~,
      cy~,
      color=@renderer2d.color_from_hex(hex),
      scale~,
    ),
  )
}

///|
fn push_num(
  cmds : Array[@gfx.DrawTrianglesCommand],
  frame : @renderer2d.RenderFrame2D,
  n : Int,
  cx : Double,
  cy : Double,
  scale : Double,
  hex : Int,
) -> Unit {
  @renderer2d.append_number(
    cmds,
    frame,
    @renderer2d.Number2D::new(
      number=n,
      cx~,
      cy~,
      color=@renderer2d.color_from_hex(hex),
      scale~,
    ),
  )
}

///|
fn node_color(kind : @mac.NodeKind) -> Int {
  match kind {
    Source => 0x2E8B57
    Pool => 0x33597F
    Drain => 0x8A3A3A
    Gate => 0x6A4A8A
    Converter => 0xA0742A
    Trader => 0x2A7A8A
    Delay | Queue => 0x4D5663
    Register => 0x444A55
  }
}

///|
fn draw_edge(
  cmds : Array[@gfx.DrawTrianglesCommand],
  frame : @renderer2d.RenderFrame2D,
  ax : Double,
  ay : Double,
  bx : Double,
  by : Double,
  rate : @mac.Rate,
  flow : Int,
  anim : Double,
) -> Unit {
  let dx = bx - ax
  let dy = by - ay
  let len = (dx * dx + dy * dy).sqrt()
  let ux = if len > 0.0 { dx / len } else { 0.0 }
  let uy = if len > 0.0 { dy / len } else { 0.0 }
  // Trim the line to the node boxes so it does not run under them.
  let sx = ax + ux * 50.0
  let sy = ay + uy * 28.0
  let ex = bx - ux * 50.0
  let ey = by - uy * 28.0
  let active = flow > 0
  let line_col = if active { 0x8FE3A0 } else { 0x49545F }
  push_line(cmds, frame, sx, sy, ex, ey, 2.0, line_col)
  // Arrowhead: a small V at the target end (no trig needed).
  let basex = ex - ux * 12.0
  let basey = ey - uy * 12.0
  let perpx = -uy
  let perpy = ux
  push_line(
    cmds,
    frame,
    ex,
    ey,
    basex + perpx * 6.0,
    basey + perpy * 6.0,
    2.0,
    line_col,
  )
  push_line(
    cmds,
    frame,
    ex,
    ey,
    basex - perpx * 6.0,
    basey - perpy * 6.0,
    2.0,
    line_col,
  )
  // Rate label at the midpoint.
  let mx = (sx + ex) / 2.0
  let my = (sy + ey) / 2.0 - 10.0
  match rate {
    Fixed(n) => push_num(cmds, frame, n, mx, my, 1.0, 0xC8D2DE)
    All => push_text(cmds, frame, "ALL", mx, my, 1.0, 0xC8D2DE)
    Dice(_, _) => push_text(cmds, frame, "DIE", mx, my, 1.0, 0xC8D2DE)
    Interval(_) => push_text(cmds, frame, "INT", mx, my, 1.0, 0xC8D2DE)
  }
  // Flow particle: a dot travelling source -> target while the edge is active.
  if active {
    let px = sx + (ex - sx) * anim
    let py = sy + (ey - sy) * anim
    push_rect(cmds, frame, px - 3.0, py - 3.0, 6.0, 6.0, 0xC8FFD2)
  }
}

///|
fn draw_node(
  cmds : Array[@gfx.DrawTrianglesCommand],
  frame : @renderer2d.RenderFrame2D,
  node : @mac.Node,
  value : Int,
) -> Unit {
  let w = 88.0
  let h = 50.0
  let x = node.x - w / 2.0
  let y = node.y - h / 2.0
  let interactive = match node.activation {
    Interactive => true
    _ => false
  }
  // border (gold + thicker for clickable nodes) + fill
  let border = if interactive { 0xE8C84A } else { 0x0E1116 }
  let bw = if interactive { 4.0 } else { 2.0 }
  push_rect(cmds, frame, x, y, w, h, border)
  push_rect(
    cmds,
    frame,
    x + bw,
    y + bw,
    w - bw * 2.0,
    h - bw * 2.0,
    node_color(node.kind),
  )
  // label above the box
  push_text(cmds, frame, node.label, node.x, y - 9.0, 1.0, 0xCFD8E3)
  // value or kind tag inside
  match node.kind {
    Pool | Register => push_num(cmds, frame, value, node.x, node.y, 2.0, 0xFFFFFF)
    Source =>
      if interactive {
        push_text(cmds, frame, "CLICK", node.x, node.y, 1.0, 0xFFE9A8)
      } else {
        push_text(cmds, frame, "TIME", node.x, node.y, 1.0, 0xDFF3E6)
      }
    Drain => push_text(cmds, frame, "DRN", node.x, node.y, 1.0, 0xF3DADA)
    Gate => push_text(cmds, frame, "GATE", node.x, node.y, 1.0, 0xE8DDF3)
    Converter => push_text(cmds, frame, "BUY", node.x, node.y, 1.0, 0xFFE9C8)
    Trader => push_text(cmds, frame, "TRADE", node.x, node.y, 1.0, 0xCFE8EC)
    Delay => push_text(cmds, frame, "DELAY", node.x, node.y, 1.0, 0xD8DCE2)
    Queue => push_text(cmds, frame, "QUEUE", node.x, node.y, 1.0, 0xD8DCE2)
  }
}

///|
fn DemoState::draw(
  self : DemoState,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let frame = @renderer2d.RenderFrame2D::new(
    dst=ctx.dst,
    shader=ctx.shader,
    screen_w=ctx.screen_w,
    screen_h=ctx.screen_h,
  )
  let sw = ctx.screen_w.to_double()
  let sh = ctx.screen_h.to_double()
  push_rect(cmds, frame, 0.0, 0.0, sw, sh, 0x1A1E24)
  // edges behind nodes
  for ei in 0..<self.diagram.resources.length() {
    let e = self.diagram.resources[ei]
    let a = self.diagram.nodes[e.from]
    let b = self.diagram.nodes[e.to]
    draw_edge(
      cmds,
      frame,
      a.x,
      a.y,
      b.x,
      b.y,
      e.rate,
      self.sim.last_flows[ei],
      self.anim,
    )
  }
  // state connections (modifier/activator) as thin gold links
  for si in 0..<self.diagram.states.length() {
    let se = self.diagram.states[si]
    let from = self.diagram.nodes[se.from]
    let (tx, ty) = match se.to_edge {
      Some(ei) => {
        let e = self.diagram.resources[ei]
        let a = self.diagram.nodes[e.from]
        let b = self.diagram.nodes[e.to]
        ((a.x + b.x) / 2.0, (a.y + b.y) / 2.0)
      }
      None =>
        match se.to_node {
          Some(ni) => (self.diagram.nodes[ni].x, self.diagram.nodes[ni].y)
          None => (from.x, from.y)
        }
    }
    push_line(cmds, frame, from.x, from.y, tx, ty, 1.0, 0xB89A3A)
    let sym = match se.kind {
      Modifier => "+"
      Activator => "?"
      _ => "*"
    }
    push_text(cmds, frame, sym, tx, ty - 11.0, 1.0, 0xE8C84A)
  }
  // nodes
  for i in 0..<self.diagram.nodes.length() {
    draw_node(cmds, frame, self.diagram.nodes[i], self.sim.values[i])
  }
  // HUD
  push_text(cmds, frame, "STEP", 44.0, 18.0, 1.0, 0x8893A0)
  push_num(cmds, frame, self.sim.step, 92.0, 18.0, 1.0, 0xE6ECF2)
  push_text(
    cmds,
    frame,
    if self.playing { "PLAYING" } else { "PAUSED" },
    180.0,
    18.0,
    1.0,
    if self.playing { 0x8FE3A0 } else { 0xC0A24A },
  )
  push_text(cmds, frame, "SPD", 300.0, 18.0, 1.0, 0x8893A0)
  push_num(cmds, frame, self.frames_per_step, 340.0, 18.0, 1.0, 0xE6ECF2)
  push_text(
    cmds,
    frame,
    "CLICK GOLD NODES   SPACE PLAY   RIGHT STEP   R RESET   UP DOWN SPEED",
    sw / 2.0,
    sh - 14.0,
    1.0,
    0x6E7A88,
  )
  self.draw_chart(cmds, frame, 20.0, 360.0, sw - 40.0, 92.0)
  self.draw_inspector(cmds, frame)
  cmds
}

///|
fn is_pool(kind : @mac.NodeKind) -> Bool {
  match kind {
    Pool | Register => true
    _ => false
  }
}

///|
fn chart_color(i : Int) -> Int {
  let pal = [0x6FB7FF, 0x8FE3A0, 0xF0B85A, 0xE57AB0, 0x9D8DF0, 0x5FD0C8]
  pal[i % pal.length()]
}

///|
fn kind_name(k : @mac.NodeKind) -> String {
  match k {
    Pool => "POOL"
    Source => "SOURCE"
    Drain => "DRAIN"
    Gate => "GATE"
    Converter => "CONVERTER"
    Trader => "TRADER"
    Delay => "DELAY"
    Queue => "QUEUE"
    Register => "REGISTER"
  }
}

///|
fn act_name(a : @mac.Activation) -> String {
  match a {
    Passive => "PASSIVE"
    Automatic => "AUTO"
    Interactive => "INTERACTIVE"
    OnTrigger => "ON TRIGGER"
    Start => "START"
  }
}

///|
/// Time-series chart of pool/register values (Vis-C).
fn DemoState::draw_chart(
  self : DemoState,
  cmds : Array[@gfx.DrawTrianglesCommand],
  frame : @renderer2d.RenderFrame2D,
  x : Double,
  y : Double,
  w : Double,
  h : Double,
) -> Unit {
  push_rect(cmds, frame, x, y, w, h, 0x10141A)
  push_rect(cmds, frame, x, y, w, 2.0, 0x2A323C)
  if self.hist_len < 2 {
    push_text(cmds, frame, "POOLS OVER TIME", x + 70.0, y + 14.0, 1.0, 0x6E7A88)
    return
  }
  let mut maxv = 1
  for i in 0..<self.diagram.nodes.length() {
    if is_pool(self.diagram.nodes[i].kind) {
      for k in 0..<self.hist_len {
        let v = self.sample(i, k)
        if v > maxv {
          maxv = v
        }
      }
    }
  }
  let denom = (self.hist_len - 1).to_double()
  let mut legx = x + 8.0
  for i in 0..<self.diagram.nodes.length() {
    let node = self.diagram.nodes[i]
    if !is_pool(node.kind) {
      continue
    }
    let col = chart_color(i)
    for k in 1..<self.hist_len {
      let v0 = self.sample(i, k - 1).to_double()
      let v1 = self.sample(i, k).to_double()
      let x0 = x + (k - 1).to_double() / denom * w
      let x1 = x + k.to_double() / denom * w
      let y0 = y + h - v0 / maxv.to_double() * (h - 8.0)
      let y1 = y + h - v1 / maxv.to_double() * (h - 8.0)
      push_line(cmds, frame, x0, y0, x1, y1, 1.5, col)
    }
    push_rect(cmds, frame, legx, y + 6.0, 8.0, 8.0, col)
    push_text(cmds, frame, node.label, legx + 40.0, y + 10.0, 1.0, col)
    push_num(cmds, frame, self.sim.values[i], legx + 98.0, y + 10.0, 1.0, 0xE6ECF2)
    legx = legx + 138.0
  }
  push_text(cmds, frame, "MAX", x + w - 56.0, y + 10.0, 1.0, 0x6E7A88)
  push_num(cmds, frame, maxv, x + w - 18.0, y + 10.0, 1.0, 0x8893A0)
}

///|
/// Hovered-node inspector panel (Vis-B).
fn DemoState::draw_inspector(
  self : DemoState,
  cmds : Array[@gfx.DrawTrianglesCommand],
  frame : @renderer2d.RenderFrame2D,
) -> Unit {
  if self.hovered < 0 {
    return
  }
  let n = self.diagram.nodes[self.hovered]
  let pw = 188.0
  let ph = 98.0
  let px = screen_w.to_double() - pw - 12.0
  let py = 30.0
  push_rect(cmds, frame, px, py, pw, ph, 0x0E1116)
  push_rect(cmds, frame, px + 2.0, py + 2.0, pw - 4.0, ph - 4.0, 0x1C222B)
  let cx = px + pw / 2.0
  push_text(cmds, frame, n.label, cx, py + 14.0, 1.0, 0xE6ECF2)
  push_text(cmds, frame, kind_name(n.kind), cx, py + 30.0, 1.0, 0x9AA6B2)
  push_text(cmds, frame, "VAL", px + 28.0, py + 52.0, 1.0, 0x6E7A88)
  push_num(cmds, frame, self.sim.values[self.hovered], px + 74.0, py + 52.0, 1.0, 0xFFFFFF)
  push_text(cmds, frame, act_name(n.activation), cx, py + 72.0, 1.0, 0x8FB0E0)
  match n.capacity {
    Some(c) => {
      push_text(cmds, frame, "CAP", px + 28.0, py + 88.0, 1.0, 0x6E7A88)
      push_num(cmds, frame, c, px + 74.0, py + 88.0, 1.0, 0xC8D2DE)
    }
    None => ()
  }
}
