///|
priv struct Sound {
  players : Array[@audio.PlayerId]
  mut next : Int
}

///|
let mixer : @audio.MixerAudioContext = @audio.MixerAudioContext::new(44100)

///|
let sounds : Map[String, Sound] = Map([])

///|
let muted : Ref[Bool] = Ref(false)

///|
let music_volume : Ref[Double] = Ref(0.23)

///|
let effects_volume : Ref[Double] = Ref(0.7)

///|
pub fn set_volumes(music : Double, effects : Double) -> Unit {
  music_volume.val = @sim.clamp(music, 0.0, 1.0)
  effects_volume.val = @sim.clamp(effects, 0.0, 1.0)
  set_muted(muted.val)
}

///|
pub fn register_audio(name : String, bytes : Bytes) -> Bool {
  let clip = @audio.decode_wav_clip(bytes, name == "battle") catch {
    _ => return false
  }
  let players : Array[@audio.PlayerId] = []
  for _ in 0..<(if name == "battle" { 1 } else { 4 }) {
    let id = mixer.create_player(clip) catch { _ => return false }
    mixer.set_volume(
      id,
      if name == "battle" {
        music_volume.val
      } else {
        effects_volume.val
      },
    )
    players.push(id)
  }
  sounds[name] = { players, next: 0 }
  true
}

///|
pub fn set_muted(value : Bool) -> Unit {
  muted.val = value
  sounds.each(fn(name, s) {
    for id in s.players {
      mixer.set_volume(
        id,
        if value {
          0.0
        } else if name == "battle" {
          music_volume.val
        } else {
          effects_volume.val
        },
      )
    }
  })
}

///|
fn play_sound(name : String, restart? : Bool = true) -> Unit {
  if sounds.get(name) is Some(s) {
    let id = s.players[s.next]
    s.next = (s.next + 1) % s.players.length()
    if restart {
      mixer.seek(id, 0.0) catch {
        _ => ()
      }
    }
    mixer.play(id) catch {
      _ => ()
    }
  }
}

///|
fn pause_audio() -> Unit {
  sounds.each(fn(_, s) {
    for id in s.players {
      mixer.pause(id) catch {
        _ => ()
      }
    }
  })
}
