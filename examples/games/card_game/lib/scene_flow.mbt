///|
/// Application entry keeps battle construction available for simulation/fixtures.
pub fn Game::new_app() -> Game {
  let game = Game::new()
  game.scene = Title
  game
}

///|
fn Game::switch_scene(self : Game, scene : AppScene) -> Unit {
  self.cancel_card()
  self.combat_focus = None
  self.scene = scene
  self.scene_focus = 0
}

///|
fn Game::open_settings(self : Game) -> Unit {
  self.scene_return = self.scene
  self.travel(SwitchScene(Settings))
}

///|
fn Game::apply_motion_mode(self : Game) -> Unit {
  self.reduced_motion = match self.motion_mode {
    Reduced => true
    Full => false
    System => prefers_reduced_motion().unwrap_or(false)
  }
}

///|
fn Game::scene_item_count(self : Game) -> Int {
  match self.scene {
    Title | Settings => 2
    CharacterSelect => 3
    StageSelect => 4
    Playing => 0
  }
}

///|
fn GameLayout::scene_item_rect(
  self : GameLayout,
  index : Int,
  count : Int,
) -> UiRect {
  let width = ui_min(520.0, self.w - 48.0)
  let gap = if count == 4 { 6.0 } else { 10.0 }
  let top = if count == 4 { 120.0 } else { 128.0 }
  let available = self.h - top - 46.0
  let height = ui_min(
    74.0,
    (available - (count - 1).to_double() * gap) / count.to_double(),
  )
  let total = height * count.to_double() + gap * (count - 1).to_double()
  {
    x: (self.w - width) / 2.0,
    y: top + (available - total) / 2.0 + index.to_double() * (height + gap),
    w: width,
    h: height,
  }
}

///|
fn Game::scene_back(self : Game) -> Unit {
  match self.scene {
    Title => ()
    Settings => self.travel(SwitchScene(self.scene_return))
    CharacterSelect => self.travel(SwitchScene(Title))
    StageSelect => self.travel(SwitchScene(CharacterSelect))
    Playing => ()
  }
}

///|
fn Game::activate_scene_item(self : Game) -> Unit {
  match self.scene {
    Title =>
      if self.scene_focus == 0 {
        self.travel(SwitchScene(CharacterSelect))
      } else {
        self.open_settings()
      }
    Settings =>
      if self.scene_focus == 0 {
        self.motion_mode = match self.motion_mode {
          System => Reduced
          Reduced => Full
          Full => System
        }
        self.apply_motion_mode()
      } else {
        self.scene_back()
      }
    CharacterSelect =>
      if self.scene_focus < 2 {
        self.character = if self.scene_focus == 0 { Ironclad } else { Warden }
        self.travel(SwitchScene(StageSelect))
      } else {
        self.scene_back()
      }
    StageSelect =>
      if self.scene_focus < 3 {
        let stage = match self.scene_focus {
          0 => Ascent
          1 => ActTwo
          _ => GuardianTrial
        }
        self.travel(
          StartAdventure(self.character, stage, self.run.get().rng_seed + 1),
        )
      } else {
        self.scene_back()
      }
    Playing => ()
  }
}

///|
fn Game::update_app_scene(
  self : Game,
  navigation : Array[@ui.UINavigationEvent],
  pressed : Bool,
) -> Bool {
  if self.scene == Playing {
    return false
  }
  let count = self.scene_item_count()
  for event in navigation {
    match event {
      Move(Left | Up) =>
        self.scene_focus = (self.scene_focus + count - 1) % count
      Move(Right | Down) => self.scene_focus = (self.scene_focus + 1) % count
      Cancel => {
        self.scene_back()
        return true
      }
      Confirm => {
        self.activate_scene_item()
        return true
      }
      _ => ()
    }
  }
  if pressed {
    for i in 0..<count {
      if self.layout
        .scene_item_rect(i, count)
        .contains(self.cursor_x, self.cursor_y) {
        self.scene_focus = i
        self.activate_scene_item()
        return true
      }
    }
  }
  true
}
