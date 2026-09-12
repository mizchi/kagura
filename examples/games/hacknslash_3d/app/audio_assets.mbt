///|
struct GameSoundAsset {
  cue : GameSoundCue
  path : String
  volume : Double
}

///|
fn game_sound_assets() -> Array[GameSoundAsset] {
  [
    { cue: SfxAttack, path: "./assets/audio/attack_slash.ogg", volume: 0.60, },
    { cue: SfxEnemyHit, path: "./assets/audio/enemy_hit.ogg", volume: 0.52, },
    { cue: SfxDodge, path: "./assets/audio/dodge_cloak.ogg", volume: 0.48, },
    { cue: SfxHurt, path: "./assets/audio/hurt_hit.ogg", volume: 0.65, },
    {
      cue: SfxPickupLoot,
      path: "./assets/audio/pickup_loot.ogg",
      volume: 0.42,
    },
    {
      cue: SfxPickupHealth,
      path: "./assets/audio/pickup_health.ogg",
      volume: 0.48,
    },
    {
      cue: SfxSpellChainLightning,
      path: "./assets/audio/spell_chain_lightning.ogg",
      volume: 0.56,
    },
    {
      cue: SfxSpellFireball,
      path: "./assets/audio/spell_fireball.ogg",
      volume: 0.60,
    },
    {
      cue: SfxSpellIceNova,
      path: "./assets/audio/spell_ice_nova.ogg",
      volume: 0.56,
    },
    {
      cue: SfxSpellHomingMissile,
      path: "./assets/audio/spell_homing_missile.ogg",
      volume: 0.48,
    },
    {
      cue: SfxFloorComplete,
      path: "./assets/audio/floor_complete.ogg",
      volume: 0.62,
    },
  ]
}
