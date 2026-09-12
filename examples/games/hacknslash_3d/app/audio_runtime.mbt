///|
enum GameSoundCue {
  SfxAttack
  SfxEnemyHit
  SfxDodge
  SfxHurt
  SfxPickupLoot
  SfxPickupHealth
  SfxSpellChainLightning
  SfxSpellFireball
  SfxSpellIceNova
  SfxSpellHomingMissile
  SfxFloorComplete
} derive(Eq, Debug)

///|
pub impl Show for GameSoundCue with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
fn sound_cue_for_event(event : @game.GameEvent) -> GameSoundCue? {
  match event {
    @game.AttackTriggered => Some(SfxAttack)
    @game.HitSparks(_, _) => Some(SfxEnemyHit)
    @game.HurtTriggered => Some(SfxHurt)
    @game.ItemPickup(_, _, true) => Some(SfxPickupHealth)
    @game.ItemPickup(_, _, false) => Some(SfxPickupLoot)
    @game.ChainLightningArc(_, _, _, _) => Some(SfxSpellChainLightning)
    @game.FireballCast(_, _) => Some(SfxSpellFireball)
    @game.HomingMissileLaunch(_, _, _, _) => Some(SfxSpellHomingMissile)
    @game.IceNovaCast(_, _, _) => Some(SfxSpellIceNova)
    @game.FloorComplete => Some(SfxFloorComplete)
    _ => None
  }
}

///|
fn sound_cue_name(cue : GameSoundCue) -> String {
  match cue {
    SfxAttack => "attack"
    SfxEnemyHit => "enemy_hit"
    SfxDodge => "dodge"
    SfxHurt => "hurt"
    SfxPickupLoot => "pickup_loot"
    SfxPickupHealth => "pickup_health"
    SfxSpellChainLightning => "spell_chain_lightning"
    SfxSpellFireball => "spell_fireball"
    SfxSpellIceNova => "spell_ice_nova"
    SfxSpellHomingMissile => "spell_homing_missile"
    SfxFloorComplete => "floor_complete"
  }
}

///|
fn GameState::set_audio_muted(self : GameState, muted : Bool) -> Unit {
  self.audio_bank.set_muted(muted)
  self.audio_last_played_state = if muted { "muted" } else { "unmuted" }
}

///|
fn GameState::toggle_audio_muted(self : GameState) -> Unit {
  self.set_audio_muted(!self.audio_bank.is_muted())
}

///|
fn GameState::play_sound_cue(self : GameState, cue : GameSoundCue) -> Unit {
  self.audio_last_played_cue = sound_cue_name(cue)
  let result = self.audio_bank.play(cue) catch {
    _ => {
      self.audio_last_played_state = "failed"
      return
    }
  }
  self.audio_last_played_state = match result {
    @audio.Played => "playing"
    @audio.Suppressed => "suppressed"
    @audio.Muted => "muted"
    @audio.Missing => "missing"
  }
}

///|
fn GameState::loaded_audio_player_count(self : GameState) -> Int {
  self.audio_bank.loaded_count()
}

///|
fn GameState::playing_audio_player_count(self : GameState) -> Int {
  self.audio_bank.playing_count()
}

///|
fn GameState::play_sound_for_event(
  self : GameState,
  event : @game.GameEvent,
) -> Unit {
  match sound_cue_for_event(event) {
    Some(cue) => self.play_sound_cue(cue)
    None => ()
  }
}

///|
pub extend GameSoundCue with Eq::{not_equal, equal}

///|
pub extend GameSoundCue with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend GameSoundCue with Show::{to_string, output}
