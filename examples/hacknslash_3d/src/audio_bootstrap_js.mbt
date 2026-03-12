///|
extern "js" fn js_install_audio_unlock() -> Unit =
  #| () => {
  #|   if (globalThis.__hacknslash3dAudioUnlockInstalled) return;
  #|   globalThis.__hacknslash3dAudioUnlockInstalled = true;
  #|   const unlock = () => {
  #|     try {
  #|       globalThis.__kaguraWebRuntime?.audio?.ctx?.resume?.();
  #|     } catch (_) {}
  #|   };
  #|   globalThis.addEventListener?.("pointerdown", unlock, { passive: true, capture: true });
  #|   globalThis.addEventListener?.("keydown", unlock, { capture: true });
  #| }

///|
fn load_hacknslash_audio_clip_js(
  state : GameState,
  cue : GameSoundCue,
  path : String,
  volume : Double,
) -> Unit {
  @asset.fetch_bytes(path, fn(bytes_opt) {
    match bytes_opt {
      Some(bytes) => {
        let clip_opt = @audio.decode_audio_clip_auto(bytes, false) catch {
          _ => None
        }
        match clip_opt {
          Some(clip) => {
            let player = state.audio_ctx.create_player(clip) catch {
              _ => {
                println("Failed to create audio player: " + path)
                return
              }
            }
            state.audio_ctx.set_volume(player, volume)
            state.audio_players.assign(cue, player)
          }
          None => println("Unsupported audio format: " + path)
        }
      }
      None => println("Failed to load audio asset: " + path)
    }
  })
}

///|
fn load_hacknslash_audio_js(state : GameState) -> Unit {
  load_hacknslash_audio_clip_js(
    state,
    SfxAttack,
    "./assets/audio/attack_slash.ogg",
    0.65,
  )
  load_hacknslash_audio_clip_js(
    state,
    SfxHurt,
    "./assets/audio/hurt_hit.ogg",
    0.85,
  )
  load_hacknslash_audio_clip_js(
    state,
    SfxPickupLoot,
    "./assets/audio/pickup_loot.ogg",
    0.55,
  )
  load_hacknslash_audio_clip_js(
    state,
    SfxPickupHealth,
    "./assets/audio/pickup_health.ogg",
    0.60,
  )
  load_hacknslash_audio_clip_js(
    state,
    SfxSpellChainLightning,
    "./assets/audio/spell_chain_lightning.ogg",
    0.90,
  )
  load_hacknslash_audio_clip_js(
    state,
    SfxSpellFireball,
    "./assets/audio/spell_fireball.ogg",
    0.75,
  )
  load_hacknslash_audio_clip_js(
    state,
    SfxSpellIceNova,
    "./assets/audio/spell_ice_nova.ogg",
    0.80,
  )
  load_hacknslash_audio_clip_js(
    state,
    SfxSpellHomingMissile,
    "./assets/audio/spell_homing_missile.ogg",
    0.78,
  )
  load_hacknslash_audio_clip_js(
    state,
    SfxFloorComplete,
    "./assets/audio/floor_complete.ogg",
    0.85,
  )
}

///|
fn init_game_audio_js(state : GameState) -> Unit {
  js_install_audio_unlock()
  load_hacknslash_audio_js(state)
}
