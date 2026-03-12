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
extern "js" fn js_decode_audio_url_to_pcm_payload(
  url : String,
  cb : (Bytes) -> Unit,
) -> Unit =
  #| (url, cb) => {
  #|   const fail = () => cb(new Uint8Array(0));
  #|   try {
  #|     const AC =
  #|       globalThis.__kaguraWebRuntime?.audio?.ctx?.constructor ??
  #|       globalThis.AudioContext ??
  #|       globalThis.webkitAudioContext;
  #|     if (!AC || typeof fetch !== "function") return fail();
  #|     let decodeCtx = globalThis.__hacknslashDecodeAudioCtx ?? null;
  #|     if (decodeCtx == null) {
  #|       decodeCtx = new AC();
  #|       globalThis.__hacknslashDecodeAudioCtx = decodeCtx;
  #|     }
  #|     fetch(url)
  #|       .then((response) => {
  #|         if (!response.ok) throw new Error(String(response.status));
  #|         return response.arrayBuffer();
  #|       })
  #|       .then((buffer) => decodeCtx.decodeAudioData(buffer.slice(0)))
  #|       .then((audioBuffer) => {
  #|         const channels = Math.max(1, audioBuffer.numberOfChannels | 0);
  #|         const sampleRate = Math.max(1, audioBuffer.sampleRate | 0);
  #|         const frames = Math.max(0, audioBuffer.length | 0);
  #|         const headerBytes = 12;
  #|         const out = new Uint8Array(headerBytes + frames * channels * 2);
  #|         const view = new DataView(out.buffer);
  #|         view.setUint32(0, sampleRate, true);
  #|         view.setUint32(4, channels, true);
  #|         view.setUint32(8, frames, true);
  #|         const channelData = [];
  #|         for (let ch = 0; ch < channels; ch++) {
  #|           channelData.push(audioBuffer.getChannelData(ch));
  #|         }
  #|         let offset = headerBytes;
  #|         for (let frame = 0; frame < frames; frame++) {
  #|           for (let ch = 0; ch < channels; ch++) {
  #|             const sample = channelData[ch][frame] ?? 0;
  #|             const clamped = Math.max(-1, Math.min(1, sample));
  #|             const i16 = clamped < 0
  #|               ? Math.round(clamped * 32768)
  #|               : Math.round(clamped * 32767);
  #|             view.setInt16(offset, i16, true);
  #|             offset += 2;
  #|           }
  #|         }
  #|         cb(out);
  #|       })
  #|       .catch(() => fail());
  #|   } catch (_) {
  #|     fail();
  #|   }
  #| }

///|
let decoded_pcm_payload_header_bytes : Int = 12

///|
fn decoded_pcm_payload_u32_le(payload : Bytes, offset : Int) -> Int {
  if offset < 0 || offset + 3 >= payload.length() {
    0
  } else {
    payload[offset].to_int() |
    (payload[offset + 1].to_int() << 8) |
    (payload[offset + 2].to_int() << 16) |
    (payload[offset + 3].to_int() << 24)
  }
}

///|
fn decoded_pcm_payload_to_audio_clip(
  payload : Bytes,
  loop_ : Bool,
) -> @audio.AudioClip? {
  if payload.length() < decoded_pcm_payload_header_bytes {
    return None
  }
  let sample_rate = decoded_pcm_payload_u32_le(payload, 0)
  let channels = decoded_pcm_payload_u32_le(payload, 4)
  let frames = decoded_pcm_payload_u32_le(payload, 8)
  if sample_rate <= 0 || channels <= 0 || frames < 0 {
    return None
  }
  let pcm_bytes = frames * channels * 2
  if payload.length() < decoded_pcm_payload_header_bytes + pcm_bytes {
    return None
  }
  let pcm : Array[Byte] = []
  for i in 0..<pcm_bytes {
    pcm.push(payload[decoded_pcm_payload_header_bytes + i])
  }
  Some(
    @audio.new_audio_clip(
      @audio.pcm16_format(sample_rate, channels),
      Bytes::from_array(pcm),
      loop_,
    ),
  )
}

///|
fn load_hacknslash_audio_clip_browser_decoded_js(
  state : GameState,
  cue : GameSoundCue,
  path : String,
  volume : Double,
) -> Unit {
  js_decode_audio_url_to_pcm_payload(path, fn(payload) {
    let clip_opt = decoded_pcm_payload_to_audio_clip(payload, false)
    match clip_opt {
      Some(clip) => {
        let player = state.audio_ctx.create_player(clip) catch {
          _ => {
            println("Failed to create audio player: " + path)
            state.audio_failed_paths.push(path + " (create_player)")
            return
          }
        }
        state.audio_ctx.set_volume(player, volume)
        state.audio_players.assign(cue, player)
      }
      None => {
        println("Failed to decode browser audio payload: " + path)
        state.audio_failed_paths.push(path + " (browser_decode)")
      }
    }
  })
}

///|
fn load_hacknslash_audio_clip_js(
  state : GameState,
  cue : GameSoundCue,
  path : String,
  volume : Double,
) -> Unit {
  load_hacknslash_audio_clip_browser_decoded_js(state, cue, path, volume)
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
