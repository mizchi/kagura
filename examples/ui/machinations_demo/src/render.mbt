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
  // border + fill
  push_rect(cmds, frame, x, y, w, h, 0x0E1116)
  push_rect(cmds, frame, x + 2.0, y + 2.0, w - 4.0, h - 4.0, node_color(node.kind))
  // label above the box
  push_text(cmds, frame, node.label, node.x, y - 9.0, 1.0, 0xCFD8E3)
  // value or kind tag inside
  match node.kind {
    Pool | Register => push_num(cmds, frame, value, node.x, node.y, 2.0, 0xFFFFFF)
    Source => push_text(cmds, frame, "SRC", node.x, node.y, 1.0, 0xDFF3E6)
    Drain => push_text(cmds, frame, "DRN", node.x, node.y, 1.0, 0xF3DADA)
    Gate => push_text(cmds, frame, "GATE", node.x, node.y, 1.0, 0xE8DDF3)
    _ => ()
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
    draw_edge(cmds, frame, a.x, a.y, b.x, b.y, e.rate, self.sim.last_flows[ei])
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
    "SPACE PLAY   RIGHT STEP   R RESET   UP DOWN SPEED",
    sw / 2.0,
    sh - 14.0,
    1.0,
    0x6E7A88,
  )
  cmds
}
