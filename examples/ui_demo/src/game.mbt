// ============================================================
// UI Demo - UITree + Layout + Focus + Hit Testing
// ============================================================

///|
let screen_w : Int = 640

///|
let screen_h : Int = 480

// Key codes
///|
let key_tab : Int = 9

///|
let key_shift_web : Int = 16

///|
let key_shift_glfw : Int = 340

// Layout sizes
///|
let header_h : Double = 40.0

///|
let footer_h : Double = 40.0

///|
let content_h : Double = 400.0

///|
let left_panel_w : Double = 200.0

///|
let panel_padding : Double = 8.0

///|
let panel_gap : Double = 8.0

///|
let btn_h : Double = 36.0

// ============================================================
// Node roles for rendering
// ============================================================

///|
enum NodeRole {
  Background
  Header
  Footer
  Panel
  Button
  Label
}

// ============================================================
// DemoState
// ============================================================

///|
struct DemoState {
  focus_mgr : @ui.UIFocusManager
  input : @inpututil.InputHelper
  node_roles : Map[Int, NodeRole]
  button_labels : Map[Int, Array[Int]]
  layouts : Array[@ui.LayoutResult]
  mut hovered_id : @ui.UINodeId?
  mut mouse_down : Bool
  mut frame : Int
}

// ============================================================
// Constructor
// ============================================================

///|
fn DemoState::new() -> DemoState {
  let tree = @ui.UITree::new()
  let node_roles : Map[Int, NodeRole] = {}
  let button_labels : Map[Int, Array[Int]] = {}
  let focusable_ids : Array[@ui.UINodeId] = []
  let sw = screen_w.to_double()

  // Derived sizes
  let content_padding = panel_padding
  let right_panel_w = sw - content_padding * 2.0 - left_panel_w - panel_gap
  let left_btn_w = left_panel_w - panel_padding * 2.0
  let right_btn_w = right_panel_w - panel_padding * 2.0

  // Helper: create a button node
  fn make_button(label_chars : Array[Int], w : Double) -> @ui.UINodeId {
    let id = tree.add_node(
      {
        ..@ui.default_node_style(),
        width: @ui.UISizing::Fixed(w),
        height: @ui.UISizing::Fixed(btn_h),
      },
      [],
    )
    node_roles[id.value] = NodeRole::Button
    button_labels[id.value] = label_chars
    focusable_ids.push(id)
    id
  }

  // Buttons for left panel
  let btn1 = make_button(ascii("BTN 1"), left_btn_w)
  let btn2 = make_button(ascii("BTN 2"), left_btn_w)
  let btn3 = make_button(ascii("BTN 3"), left_btn_w)

  // Buttons for right panel
  let btn4 = make_button(ascii("BTN 4"), right_btn_w)
  let btn5 = make_button(ascii("BTN 5"), right_btn_w)
  let btn6 = make_button(ascii("BTN 6"), right_btn_w)

  // Left panel
  let left_panel = tree.add_node(
    {
      ..@ui.default_node_style(),
      direction: @ui.UIDirection::Column,
      width: @ui.UISizing::Fixed(left_panel_w),
      height: @ui.UISizing::Fixed(content_h - content_padding * 2.0),
      padding_left: panel_padding,
      padding_right: panel_padding,
      padding_top: panel_padding,
      padding_bottom: panel_padding,
      gap: panel_gap,
    },
    [btn1, btn2, btn3],
  )
  node_roles[left_panel.value] = NodeRole::Panel

  // Right panel
  let right_panel = tree.add_node(
    {
      ..@ui.default_node_style(),
      direction: @ui.UIDirection::Column,
      width: @ui.UISizing::Fixed(right_panel_w),
      height: @ui.UISizing::Fixed(content_h - content_padding * 2.0),
      padding_left: panel_padding,
      padding_right: panel_padding,
      padding_top: panel_padding,
      padding_bottom: panel_padding,
      gap: panel_gap,
    },
    [btn4, btn5, btn6],
  )
  node_roles[right_panel.value] = NodeRole::Panel

  // Header
  let header = tree.add_node(
    {
      ..@ui.default_node_style(),
      direction: @ui.UIDirection::Row,
      width: @ui.UISizing::Fixed(sw),
      height: @ui.UISizing::Fixed(header_h),
    },
    [],
  )
  node_roles[header.value] = NodeRole::Header

  // Content area (row with two panels)
  let content = tree.add_node(
    {
      ..@ui.default_node_style(),
      direction: @ui.UIDirection::Row,
      width: @ui.UISizing::Fixed(sw),
      height: @ui.UISizing::Fixed(content_h),
      padding_left: content_padding,
      padding_right: content_padding,
      padding_top: content_padding,
      padding_bottom: content_padding,
      gap: panel_gap,
    },
    [left_panel, right_panel],
  )
  node_roles[content.value] = NodeRole::Background

  // Footer
  let footer = tree.add_node(
    {
      ..@ui.default_node_style(),
      direction: @ui.UIDirection::Row,
      width: @ui.UISizing::Fixed(sw),
      height: @ui.UISizing::Fixed(footer_h),
    },
    [],
  )
  node_roles[footer.value] = NodeRole::Footer

  // Root
  let root_id = tree.add_node(
    {
      ..@ui.default_node_style(),
      direction: @ui.UIDirection::Column,
      width: @ui.UISizing::Fixed(sw),
      height: @ui.UISizing::Fixed(screen_h.to_double()),
    },
    [header, content, footer],
  )
  node_roles[root_id.value] = NodeRole::Background

  // Focus manager
  let focus_mgr = @ui.UIFocusManager::new()
  focus_mgr.set_focusable(focusable_ids)

  // Compute initial layout
  let engine = @ui.SimpleLayoutEngine::new(tree)
  let constraint = @ui.default_layout_constraint(sw, screen_h.to_double())
  let layouts = try { engine.compute_layout(root_id, constraint) } catch {
    _ => []
  }

  {
    focus_mgr,
    input: @inpututil.new_input_helper(),
    node_roles,
    button_labels,
    layouts,
    hovered_id: None,
    mouse_down: false,
    frame: 0,
  }
}

// ============================================================
// Update
// ============================================================

///|
fn DemoState::update(self : DemoState, input : @core.InputSnapshot) -> Unit {
  self.frame = self.frame + 1
  @inpututil.update_input_helper(self.input, input)

  // Hit test for hover
  self.hovered_id = @ui.hit_test(self.layouts, input.cursor_x, input.cursor_y)

  // Mouse click -> focus (find deepest focusable node)
  if @inpututil.is_mouse_button_just_pressed(self.input.mouse_state, 0) {
    let hit_ids = @ui.hit_test_all(self.layouts, input.cursor_x, input.cursor_y)
    let mut focused = false
    for hit_id in hit_ids {
      if not(focused) {
        // Check if this node is a button (focusable)
        match self.node_roles.get(hit_id.value) {
          Some(Button) => {
            let _ = self.focus_mgr.focus(hit_id)
            focused = true
          }
          _ => ()
        }
      }
    }
    if not(focused) {
      let _ = self.focus_mgr.blur()
    }
  }
  self.mouse_down = @inpututil.is_mouse_button_pressed(
    self.input.mouse_state,
    0,
  )

  // Tab / Shift-Tab for focus navigation
  if @inpututil.is_key_just_pressed(self.input.key_state, key_tab) {
    let shift_held = @inpututil.is_key_pressed(
        self.input.key_state,
        key_shift_web,
      ) ||
      @inpututil.is_key_pressed(self.input.key_state, key_shift_glfw)
    if shift_held {
      let _ = self.focus_mgr.focus_prev()
    } else {
      let _ = self.focus_mgr.focus_next()
    }
  }
}

// ============================================================
// Draw
// ============================================================

///|
fn DemoState::draw(
  self : DemoState,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  let focused_id = self.focus_mgr.current_focus()

  // Draw in reverse order: parents first (background), children on top
  let n = self.layouts.length()
  for idx = n - 1; idx >= 0; idx = idx - 1 {
    let layout = self.layouts[idx]
    let nid = layout.node_id.value
    let r = layout.rect
    if r.width < 1.0 || r.height < 1.0 {
      continue
    }
    let role = self.node_roles.get(nid)
    let is_focused = match focused_id {
      Some(fid) => fid.value == nid
      None => false
    }
    let is_hovered = match self.hovered_id {
      Some(hid) => hid.value == nid
      None => false
    }

    match role {
      Some(Background) =>
        cmds.push(
          @debugutil.new_ndc_rect_fill_command(
            ctx.dst,
            ctx.shader,
            r.x,
            r.y,
            r.width,
            r.height,
            sw,
            sh,
            @debugutil.color_from_hex(0x1a1a2e),
            0,
          ),
        )
      Some(Header) | Some(Footer) =>
        cmds.push(
          @debugutil.new_ndc_rect_fill_command(
            ctx.dst,
            ctx.shader,
            r.x,
            r.y,
            r.width,
            r.height,
            sw,
            sh,
            @debugutil.color_from_hex(0x2a2a3e),
            0,
          ),
        )
      Some(Panel) =>
        cmds.push(
          @debugutil.new_ndc_rect_fill_command(
            ctx.dst,
            ctx.shader,
            r.x,
            r.y,
            r.width,
            r.height,
            sw,
            sh,
            @debugutil.color_from_hex(0x333350),
            0,
          ),
        )
      Some(Button) => {
        // Button color based on state
        let color = if is_focused && is_hovered && self.mouse_down {
          @debugutil.color_from_hex(0x60DD60)
        } else if is_focused {
          @debugutil.color_from_hex(0x5566AA)
        } else if is_hovered {
          @debugutil.color_from_hex(0x6a6a9a)
        } else {
          @debugutil.color_from_hex(0x4a4a6a)
        }
        // Fill
        cmds.push(
          @debugutil.new_ndc_rect_fill_command(
            ctx.dst,
            ctx.shader,
            r.x,
            r.y,
            r.width,
            r.height,
            sw,
            sh,
            color,
            0,
          ),
        )
        // Focus border
        if is_focused {
          let bw = 2.0
          let border_color = @debugutil.color_from_hex(0xFFFF00)
          // Top
          cmds.push(
            @debugutil.new_ndc_rect_fill_command(
              ctx.dst,
              ctx.shader,
              r.x,
              r.y,
              r.width,
              bw,
              sw,
              sh,
              border_color,
              0,
            ),
          )
          // Bottom
          cmds.push(
            @debugutil.new_ndc_rect_fill_command(
              ctx.dst,
              ctx.shader,
              r.x,
              r.y + r.height - bw,
              r.width,
              bw,
              sw,
              sh,
              border_color,
              0,
            ),
          )
          // Left
          cmds.push(
            @debugutil.new_ndc_rect_fill_command(
              ctx.dst,
              ctx.shader,
              r.x,
              r.y,
              bw,
              r.height,
              sw,
              sh,
              border_color,
              0,
            ),
          )
          // Right
          cmds.push(
            @debugutil.new_ndc_rect_fill_command(
              ctx.dst,
              ctx.shader,
              r.x + r.width - bw,
              r.y,
              bw,
              r.height,
              sw,
              sh,
              border_color,
              0,
            ),
          )
        }
        // Button label
        match self.button_labels.get(nid) {
          Some(chars) =>
            @debugutil.draw_dot_text(
              cmds,
              ctx.dst,
              ctx.shader,
              chars,
              r.x + r.width / 2.0,
              r.y + r.height / 2.0,
              sw,
              sh,
              @debugutil.color_white(),
              1.0,
            )
          None => ()
        }
      }
      _ => ()
    }
  }

  // Header label: "UI DEMO"
  @debugutil.draw_dot_text(
    cmds,
    ctx.dst,
    ctx.shader,
    ascii("UI DEMO"),
    60.0,
    20.0,
    sw,
    sh,
    @debugutil.color_white(),
    1.2,
  )

  // Footer label: "TAB:FOCUS CLICK:SELECT"
  @debugutil.draw_dot_text(
    cmds,
    ctx.dst,
    ctx.shader,
    ascii("TAB:FOCUS CLICK:SELECT"),
    160.0,
    sh - 20.0,
    sw,
    sh,
    @debugutil.color_from_hex(0x888888),
    1.0,
  )

  cmds
}

// ============================================================
// Utility
// ============================================================

///|
fn ascii(s : String) -> Array[Int] {
  let result : Array[Int] = []
  for i = 0; i < s.length(); i = i + 1 {
    let c = s[i].to_int()
    // glyph_pattern expects 0-9 for digits, ASCII for letters/symbols
    if c >= 48 && c <= 57 {
      result.push(c - 48)
    } else {
      result.push(c)
    }
  }
  result
}
