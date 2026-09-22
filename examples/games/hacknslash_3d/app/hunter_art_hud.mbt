///|
struct HunterArtsView {
  whirling : Bool
  whirlwind_frame : Int
  whirlwind_radius : Double
  guarding : Bool
  guard_energy : Int
  guard_recovery : Int
  targeting : Bool
  target_valid : Bool
  target_x : Double
  target_y : Double
  radius : Double
  ground_remaining : Int
  dash_remaining : Int
  action : String
  action_frame : Int
  impact_pending : Bool
  feedback : String
} derive(ToJson)
///|
pub extend HunterArtsView with ToJson::{to_json}
///|
fn GameState::hunter_arts_view(self : GameState) -> HunterArtsView {
  let arts = self.world.arts
  {
    whirling: arts.whirlwind.active,
    whirlwind_frame: arts.whirlwind.frame,
    whirlwind_radius: self.world.whirlwind_radius() / tile_size,
    guarding: arts.guarding,
    guard_energy: arts.guard_energy.to_int(),
    guard_recovery: arts.guard_recovery,
    targeting: self.ground_targeting,
    target_valid: self.ground_targeting &&
    self.world.ground_strike_target_valid(
      self.ground_target_x,
      self.ground_target_y,
    ),
    target_x: self.ground_target_x / tile_size,
    target_y: self.ground_target_y / tile_size,
    radius: @game.effective_aoe_radius(
      self.world.player_stats,
      @game.AoEMastery,
      @game.ground_strike_radius,
    ) /
    tile_size,
    ground_remaining: arts.ground_cooldown,
    dash_remaining: arts.dash_cooldown,
    action: match arts.action {
      Some(action) =>
        match action.kind {
          LightningArt => "lightning"
          FlameArt => "flame"
          AstralArt => "astral"
          DashArt => "dash_strike"
          RaiseZombieArt => "raise_zombie"
          FlamingSkullArt => "flaming_skull"
        }
      None =>
        if arts.whirlwind.active {
          "whirlwind"
        } else if arts.guarding {
          "guard"
        } else {
          "none"
        }
    },
    action_frame: match arts.action {
      Some(action) => action.frame
      None =>
        if arts.whirlwind.active {
          arts.whirlwind.frame
        } else {
          arts.guard_frame
        }
    },
    impact_pending: arts.strike is Some(_),
    feedback: self.combat_feedback(),
  }
}

///|
fn GameState::combat_feedback(self : GameState) -> String {
  for i = self.combat_visuals.length() - 1; i >= 0; i = i - 1 {
    let v = self.combat_visuals[i]
    if v.age >= 28 {
      continue
    }
    match v.kind {
      Block(perfect) => return if perfect { "JUST GUARD" } else { "GUARD" }
      Impact(_) => if v.hits > 0 { return v.hits.to_string() + " HIT" }
      _ => ()
    }
  }
  ""
}
