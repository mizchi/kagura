///|
fn Game::view_app_scene(self : Game) -> @scene.SceneNode {
  let l = self.layout
  let (title, subtitle) = match self.scene {
    Title => ("EMBER ASCENT", "A ROGUELIKE DECKBUILDING ADVENTURE")
    Settings => ("SETTINGS", "YOUR CHOICES APPLY TO THE CURRENT RUN")
    CharacterSelect =>
      ("CHOOSE YOUR CHARACTER", "A DIFFERENT DECK. A DIFFERENT WAY TO CLIMB.")
    StageSelect =>
      (
        "CHOOSE YOUR STAGE",
        character_name(self.character).to_upper() + " IS READY",
      )
    Playing => ("", "")
  }
  let items : Array[(String, String, Int)] = match self.scene {
    Title =>
      [
        ("BEGIN ASCENT", "CHOOSE A CHARACTER AND A STAGE", gold),
        ("SETTINGS", "MOTION AND CONTROLLER GUIDE", cyan),
      ]
    Settings =>
      [
        (
          "MOTION: " +
          (match self.motion_mode {
            System => "SYSTEM"
            Reduced => "REDUCED"
            Full => "FULL"
          }),
          "SELECT TO CYCLE / ACTION PAUSES ARE PRESERVED",
          cyan,
        ),
        ("BACK", "RETURN TO YOUR PREVIOUS SCREEN", gold),
      ]
    CharacterSelect =>
      [
        ("IRONCLAD", "80 HP / STRIKES AND BASH / BURNING BLOOD", 0xFFB0A5),
        ("WARDEN", "96 HP / DEFENDS AND BODY SLAM / ANCHOR", cyan),
        ("BACK", "RETURN TO TITLE", muted_ink),
      ]
    StageSelect =>
      [
        (
          "ACT I - THE ASCENT", "START AT FLOOR 1 / BUILD YOUR DECK TO THE SUMMIT",
          gold,
        ),
        ("ACT II - THE CITY", "START AT FLOOR 16 / HARDER ENCOUNTERS", cyan),
        (
          "BOSS TRIAL - THE GUARDIAN", "FLOOR 15 / A SINGLE BOSS CHALLENGE", 0xFFB0A5,
        ),
        ("BACK", "CHOOSE ANOTHER CHARACTER", muted_ink),
      ]
    Playing => []
  }
  let nodes = [
    @scene.rect(w=l.w, h=l.h, fill=0x10151C),
    @scene.rect(x=12.0, y=16.0, w=l.w - 24.0, h=l.h - 32.0, fill=0x151E2A),
    @scene.rect_outline(
      x=16.0,
      y=20.0,
      w=l.w - 32.0,
      h=l.h - 40.0,
      color=0x456277,
    ),
    fit_text(
      "scene_title",
      l.w / 2.0,
      66.0,
      title,
      l.w - 48.0,
      scale=1.65,
      color=gold,
    ),
    fit_text(
      "scene_subtitle",
      l.w / 2.0,
      98.0,
      subtitle,
      l.w - 48.0,
      scale=0.65,
      color=muted_ink,
    ),
  ]
  for i, item in items {
    let r = l.scene_item_rect(i, items.length())
    let focused = self.scene_focus == i
    let children = [
      fit_text(
        "name",
        r.w / 2.0,
        r.h * 0.35,
        item.0,
        r.w - 28.0,
        scale=0.95,
        color=item.2,
      ),
      fit_text(
        "description",
        r.w / 2.0,
        r.h * 0.73,
        item.1,
        r.w - 28.0,
        scale=0.5,
        color=muted_ink,
      ),
    ]
    if focused {
      children.push(
        @scene.rect_outline(
          x=4.0,
          y=4.0,
          w=r.w - 8.0,
          h=r.h - 8.0,
          line_width=2.0,
          color=item.2,
        ),
      )
    }
    nodes.push(
      ui_panel(
        "scene_choice_" + i.to_string(),
        r,
        if focused {
          0x303B4C
        } else {
          0x202E3E
        },
        item.2,
        children,
        role="button",
        focused~,
        focusable=true,
        focus_index=i,
      ),
    )
  }
  nodes.push(
    fit_text(
      "scene_controls",
      l.w / 2.0,
      l.h - 28.0,
      "ARROWS / STICK: CHOOSE   A / ENTER: CONFIRM   B / ESC: BACK",
      l.w - 48.0,
      scale=0.5,
      color=cyan,
    ),
  )
  if self.scene == Settings && l.h >= 440.0 {
    nodes.push(
      fit_text(
        "controller_guide",
        l.w / 2.0,
        122.0,
        "X: DECK / LB: DRAW / RB: DISCARD / Y: END / START: SETTINGS",
        l.w - 48.0,
        scale=0.5,
        color=cyan,
      ),
    )
  }
  @scene.fragment(nodes)
}
