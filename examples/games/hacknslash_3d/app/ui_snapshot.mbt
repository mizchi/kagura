///|
/// UI snapshot adapter. The playing HUD and menu screens are drawn through
/// `@hud.HudContext`, not an `@ui` layout tree, so the adapter reconstructs
/// the named chrome from game state using the same rects and measure path
/// the draw functions use.
fn GameState::ui_snapshot(self : GameState) -> @ui.UISnapshot {
  let sw = screen_w.to_double()
  let sh = screen_h.to_double()
  let nodes : Array[@ui.UISnapshotNode] = []
  let ctx = self.make_hud_ctx(
    @gfx.new_image_handle(0, screen_w, screen_h),
    @gfx.new_shader_handle(0, "ui-snapshot"),
  )
  match self.world.mode {
    @game.Title => collect_title_snapshot(self, ctx, nodes, sw, sh)
    @game.CharacterSelect =>
      collect_character_select_snapshot(self, ctx, nodes, sw, sh)
    @game.GameOver => collect_gameover_snapshot(self, ctx, nodes, sw, sh)
    @game.Playing => {
      collect_playing_hud_snapshot(self, ctx, nodes, sw, sh)
      match self.world.ui_mode {
        @game.Inventory => collect_inventory_snapshot(ctx, nodes, sw, sh)
        @game.Skills => collect_named_overlay_snapshot(ctx, nodes, "skills", "SKILLS")
        @game.LevelUp =>
          collect_named_overlay_snapshot(ctx, nodes, "levelup", "LEVEL UP")
        @game.UIMode::None => ()
      }
    }
  }
  {
    ..@ui.default_ui_snapshot(screen_width=sw, screen_height=sh),
    frame: self.world.frame_count,
    state: ui_snapshot_state_name(self),
    nodes,
  }
}

///|
fn ui_snapshot_state_name(state : GameState) -> String {
  match state.world.mode {
    @game.Title => "title"
    @game.CharacterSelect => "character_select"
    @game.GameOver => "gameover"
    @game.Playing =>
      match state.world.ui_mode {
        @game.Inventory => "inventory"
        @game.Skills => "skills"
        @game.LevelUp => "levelup"
        @game.UIMode::None => "playing"
      }
  }
}

///|
fn push_snapshot_rect(
  nodes : Array[@ui.UISnapshotNode],
  path : String,
  id : String,
  role : String,
  left : Double,
  top : Double,
  width : Double,
  height : Double,
) -> Unit {
  let hit : @ui.UISnapshotRect = { left, top, width, height }
  nodes.push({
    ..@ui.default_ui_snapshot_node(),
    path,
    id,
    role,
    classes: role,
    left,
    top,
    width,
    height,
    z: nodes.length(),
    hit: Some(hit),
  })
}

///|
fn push_snapshot_text(
  ctx : @hud.HudContext,
  nodes : Array[@ui.UISnapshotNode],
  path : String,
  id : String,
  text : String,
  size : Double,
  x : Double,
  y : Double,
  centered : Bool,
) -> Unit {
  if text == "" {
    return
  }
  let (tw, th) = ctx.measure_text(text, size)
  let left = if centered { x - tw / 2.0 } else { x }
  let top = if centered { y - th / 2.0 } else { y }
  let hit : @ui.UISnapshotRect = {
    left,
    top,
    width: tw,
    height: th,
  }
  let metrics : @ui.UITextMetrics = { width: tw, height: th }
  nodes.push({
    ..@ui.default_ui_snapshot_node(),
    path,
    id,
    role: "label",
    classes: id,
    left,
    top,
    width: tw,
    height: th,
    z: nodes.length(),
    text: Some(text),
    text_measured: Some(metrics),
    hit: Some(hit),
  })
}

///|
fn push_dot_label(
  nodes : Array[@ui.UISnapshotNode],
  id : String,
  text : String,
  cx : Double,
  cy : Double,
  scale : Double,
  path? : String = "",
) -> Unit {
  let n = text.iter().count().to_double()
  let tw = if n <= 0.0 { 0.0 } else { (12.0 * n - 3.0) * scale }
  let th = 15.0 * scale
  let left = cx - tw / 2.0
  let top = cy - th / 2.0
  let hit : @ui.UISnapshotRect = { left, top, width: tw, height: th }
  let metrics : @ui.UITextMetrics = { width: tw, height: th }
  nodes.push({
    ..@ui.default_ui_snapshot_node(),
    path: if path == "" { id } else { path },
    id,
    role: "label",
    classes: id,
    left,
    top,
    width: tw,
    height: th,
    z: nodes.length(),
    text: Some(text),
    text_measured: Some(metrics),
    hit: Some(hit),
  })
}

///|
fn collect_title_snapshot(
  state : GameState,
  ctx : @hud.HudContext,
  nodes : Array[@ui.UISnapshotNode],
  sw : Double,
  sh : Double,
) -> Unit {
  // Native/GPU capture has no TTF atlas; draw uses scene.label scales.
  // Measure with the same path so integrity does not see a 676px TTF box
  // around a 3x5 HUD that actually fits.
  match state.text_renderer {
    Some(_) => {
      push_snapshot_text(
        ctx,
        nodes,
        "title",
        "title",
        "HACK N SLASH",
        48.0,
        sw / 2.0,
        sh / 2.0 - 60.0,
        true,
      )
      push_snapshot_text(
        ctx,
        nodes,
        "subtitle",
        "subtitle",
        "3D",
        32.0,
        sw / 2.0,
        sh / 2.0 - 10.0,
        true,
      )
    }
    None => {
      push_dot_label(nodes, "title", "HACK N SLASH", sw / 2.0, sh / 2.0 - 60.0, 3.0)
      push_dot_label(nodes, "subtitle", "3D", sw / 2.0, sh / 2.0 - 10.0, 2.0)
    }
  }
  if state.world.frame_count / 30 % 2 == 0 {
    match state.text_renderer {
      Some(_) => push_snapshot_text(
        ctx,
        nodes,
        "prompt",
        "prompt",
        "PRESS SPACE",
        24.0,
        sw / 2.0,
        sh / 2.0 + 40.0,
        true,
      )
      None =>
        push_dot_label(
          nodes,
          "prompt",
          "PRESS SPACE",
          sw / 2.0,
          sh / 2.0 + 40.0,
          1.5,
        )
    }
  }
}

///|
fn collect_character_select_snapshot(
  _state : GameState,
  ctx : @hud.HudContext,
  nodes : Array[@ui.UISnapshotNode],
  sw : Double,
  sh : Double,
) -> Unit {
  push_snapshot_text(
    ctx,
    nodes,
    "character_select>title",
    "select_class",
    "SELECT CLASS",
    36.0,
    sw / 2.0,
    sh / 2.0 - 120.0,
    true,
  )
}

///|
fn collect_gameover_snapshot(
  state : GameState,
  ctx : @hud.HudContext,
  nodes : Array[@ui.UISnapshotNode],
  sw : Double,
  sh : Double,
) -> Unit {
  push_snapshot_text(
    ctx,
    nodes,
    "gameover",
    "gameover",
    "GAME OVER",
    48.0,
    sw / 2.0,
    sh / 2.0 - 60.0,
    true,
  )
  push_snapshot_text(
    ctx,
    nodes,
    "gameover>floor",
    "gameover_floor",
    "FLOOR " + state.world.floor.to_string(),
    24.0,
    sw / 2.0,
    sh / 2.0 + 5.0,
    true,
  )
  push_snapshot_text(
    ctx,
    nodes,
    "gameover>score",
    "gameover_score",
    "SCORE " + state.world.score.to_string(),
    32.0,
    sw / 2.0,
    sh / 2.0 + 40.0,
    true,
  )
}

///|
fn collect_playing_hud_snapshot(
  state : GameState,
  ctx : @hud.HudContext,
  nodes : Array[@ui.UISnapshotNode],
  sw : Double,
  sh : Double,
) -> Unit {
  let hp_y = sh - 46.0
  let hp_ratio = hp_bar_ratio_clamped(
    state.world.player.hp,
    state.world.player.max_hp,
  )
  push_snapshot_rect(nodes, "hud>hp_bar", "hp_bar", "bar", 8.0, hp_y, 140.0, 14.0)
  if hp_ratio > 0.0 {
    push_snapshot_rect(
      nodes,
      "hud>hp_bar>fill",
      "hp_fill",
      "bar",
      10.0,
      hp_y + 2.0,
      68.0 * hp_ratio * 2.0,
      10.0,
    )
  }
  push_snapshot_text(
    ctx,
    nodes,
    "hud>hp_label",
    "hp_label",
    "HP",
    12.0,
    8.0,
    sh - 48.0,
    false,
  )
  push_snapshot_text(
    ctx,
    nodes,
    "hud>hp_text",
    "hp_text",
    hp_status_text(state.world.player.hp, state.world.player.max_hp),
    12.0,
    152.0,
    hp_y + 1.0,
    false,
  )
  match state.text_renderer {
    Some(_) =>
      push_snapshot_text(
        ctx,
        nodes,
        "hud>floor",
        "floor",
        "FLOOR " + state.world.floor.to_string(),
        16.0,
        sw / 2.0,
        8.0,
        true,
      )
    None =>
      push_dot_label(
        nodes,
        "floor",
        "FLOOR " + state.world.floor.to_string(),
        sw / 2.0,
        14.0,
        1.2,
        path="hud>floor",
      )
  }
  push_snapshot_text(
    ctx,
    nodes,
    "hud>gold",
    "gold",
    state.world.score.to_string() + "G",
    16.0,
    8.0,
    8.0,
    false,
  )
  let mut alive_count = 0
  for enemy in state.world.enemies {
    if enemy.alive {
      alive_count = alive_count + 1
    }
  }
  push_snapshot_text(
    ctx,
    nodes,
    "hud>enemies",
    "enemies",
    "x" + alive_count.to_string(),
    12.0,
    8.0,
    24.0,
    false,
  )
  if state.paused {
    push_snapshot_text(
      ctx,
      nodes,
      "hud>paused",
      "paused",
      "PAUSED",
      24.0,
      sw / 2.0,
      sh / 2.0 - 20.0,
      true,
    )
  }
}

///|
fn collect_inventory_snapshot(
  ctx : @hud.HudContext,
  nodes : Array[@ui.UISnapshotNode],
  sw : Double,
  sh : Double,
) -> Unit {
  push_snapshot_rect(
    nodes,
    "inventory",
    "inventory",
    "panel",
    0.0,
    0.0,
    sw,
    sh,
  )
  push_snapshot_text(
    ctx,
    nodes,
    "inventory>title",
    "inventory_title",
    "INVENTORY",
    ui_font_lg,
    ui_pad,
    ui_pad,
    false,
  )
}

///|
fn collect_named_overlay_snapshot(
  ctx : @hud.HudContext,
  nodes : Array[@ui.UISnapshotNode],
  id : String,
  title : String,
) -> Unit {
  push_snapshot_rect(
    nodes,
    id,
    id,
    "panel",
    0.0,
    0.0,
    screen_w.to_double(),
    screen_h.to_double(),
  )
  push_snapshot_text(
    ctx,
    nodes,
    id + ">title",
    id + "_title",
    title,
    ui_font_lg,
    ui_pad,
    ui_pad,
    false,
  )
}
