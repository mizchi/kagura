///|
enum GameSoundCue {
  SfxAttack
  SfxHurt
  SfxPickupLoot
  SfxPickupHealth
  SfxSpellChainLightning
  SfxSpellFireball
  SfxSpellIceNova
  SfxSpellHomingMissile
  SfxFloorComplete
} derive(Eq, Show)

///|
struct GameAudioPlayers {
  mut attack : @audio.PlayerId?
  mut hurt : @audio.PlayerId?
  mut pickup_loot : @audio.PlayerId?
  mut pickup_health : @audio.PlayerId?
  mut spell_chain_lightning : @audio.PlayerId?
  mut spell_fireball : @audio.PlayerId?
  mut spell_ice_nova : @audio.PlayerId?
  mut spell_homing_missile : @audio.PlayerId?
  mut floor_complete : @audio.PlayerId?
}

///|
fn default_game_audio_players() -> GameAudioPlayers {
  {
    attack: None,
    hurt: None,
    pickup_loot: None,
    pickup_health: None,
    spell_chain_lightning: None,
    spell_fireball: None,
    spell_ice_nova: None,
    spell_homing_missile: None,
    floor_complete: None,
  }
}

///|
fn sound_cue_for_event(event : @game.GameEvent) -> GameSoundCue? {
  match event {
    @game.AttackTriggered => Some(SfxAttack)
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
fn GameAudioPlayers::lookup(
  self : GameAudioPlayers,
  cue : GameSoundCue,
) -> @audio.PlayerId? {
  match cue {
    SfxAttack => self.attack
    SfxHurt => self.hurt
    SfxPickupLoot => self.pickup_loot
    SfxPickupHealth => self.pickup_health
    SfxSpellChainLightning => self.spell_chain_lightning
    SfxSpellFireball => self.spell_fireball
    SfxSpellIceNova => self.spell_ice_nova
    SfxSpellHomingMissile => self.spell_homing_missile
    SfxFloorComplete => self.floor_complete
  }
}

///|
fn GameAudioPlayers::assign(
  self : GameAudioPlayers,
  cue : GameSoundCue,
  player : @audio.PlayerId,
) -> Unit {
  match cue {
    SfxAttack => self.attack = Some(player)
    SfxHurt => self.hurt = Some(player)
    SfxPickupLoot => self.pickup_loot = Some(player)
    SfxPickupHealth => self.pickup_health = Some(player)
    SfxSpellChainLightning => self.spell_chain_lightning = Some(player)
    SfxSpellFireball => self.spell_fireball = Some(player)
    SfxSpellIceNova => self.spell_ice_nova = Some(player)
    SfxSpellHomingMissile => self.spell_homing_missile = Some(player)
    SfxFloorComplete => self.floor_complete = Some(player)
  }
}

///|
fn GameState::play_sound_cue(self : GameState, cue : GameSoundCue) -> Unit {
  match self.audio_players.lookup(cue) {
    Some(player) => {
      self.audio_ctx.seek(player, 0.0) catch {
        _ => ()
      }
      self.audio_ctx.play(player) catch {
        _ => ()
      }
    }
    None => ()
  }
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
