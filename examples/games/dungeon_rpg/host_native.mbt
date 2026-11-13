///|
fn install_platform() -> Unit {
  ()
}

///|
fn install_host(
  _read : () -> String,
  _command : (String, Int32) -> String,
  _save : () -> String,
  _load : (String) -> String,
  _paused : () -> Bool,
  _pose : (Int32, Int32, Int32) -> String,
  _read_agent : () -> String,
  _step_agent : (Int32, String) -> String,
  _reset_agent : (Int32, String, String) -> String,
  _load_master : (String) -> String,
  _read_master : () -> String,
  _read_experience : (Int32) -> String,
) -> Unit {
  ()
}

///|
fn App::register_inspection(_self : App) -> Unit {
  ()
}

///|
fn App::platform_update(self : App, raw : @core.InputSnapshot) -> Unit {
  let keys = raw.pressed_keys
  for key in keys {
    if native_keys.keys.contains(key) {
      continue
    }
    let g = self.game
    let action = if g.mode == @sim.Town || g.mode == @sim.Cleared {
      match key {
        257 | 13 => "enter"
        82 => "rest"
        66 => "buy"
        _ => ""
      }
    } else if g.mode == @sim.Exploring {
      match key {
        87 | 265 => "forward"
        83 | 264 => "backward"
        65 | 263 => "left"
        68 | 262 => "right"
        81 => "strafe-left"
        69 => "strafe-right"
        257 | 13 => "interact"
        82 => "recall"
        51 => "field-heal"
        53 => "field-potion"
        _ => ""
      }
    } else if g.mode == @sim.Warning {
      match key {
        257 | 13 => "challenge"
        256 | 27 => "back"
        _ => ""
      }
    } else if g.mode == @sim.Looting {
      match key {
        257 | 13 => "loot"
        256 | 27 => "back"
        _ => ""
      }
    } else {
      let b = g.battle.unwrap()
      match key {
        257 | 13 =>
          if b.phase == @sim.Review {
            "resolve"
          } else if b.phase == @sim.Report || b.phase == @sim.Won {
            "continue"
          } else {
            ""
          }
        70 => "all-attack"
        49 => "attack"
        50 => "guard"
        51 => "heal"
        52 => "flame"
        53 => "potion"
        88 => "flee"
        259 | 8 => "undo"
        _ => ""
      }
    }
    if action != "" {
      let mut arg = -1
      if action == "loot" {
        arg = 0
      }
      if action == "attack" {
        if g.battle is Some(b) {
          for i in 0..<b.foes.length() {
            if b.foes[i].hp > 0 {
              arg = i
              break
            }
          }
        }
      }
      if action == "heal" ||
        action == "potion" ||
        action == "field-heal" ||
        action == "field-potion" {
        for i in 0..<6 {
          if g.party[i].hp > 0 && (arg < 0 || g.party[i].hp < g.party[arg].hp) {
            arg = i
          }
        }
      }
      ignore(self.command(action, arg))
    }
  }
  native_keys.keys = keys.copy()
}

///|
fn platform_overlay(g : @sim.Game, nodes : Array[@scene.SceneNode]) -> Unit {
  let town = g.mode == @sim.Town || g.mode == @sim.Cleared
  if town {
    nodes.push(@scene.rect(x=30, y=90, w=450, h=310, fill=0x152026, alpha=0.95))
    text(nodes, 250, 135, "FATHOM", 1.7, 0xd7b77b)
    text(nodes, 250, 200, "FIND THE SEAL ON FLOOR 2", 0.65, 0xd7dccf)
    text(nodes, 250, 235, "THEN BRING EVERYONE HOME", 0.65, 0xd7dccf)
    text(nodes, 250, 285, "ENTER: DESCEND", 0.8, 0xd7b77b)
    text(nodes, 250, 330, "R: REST 8G / B: POTION 6G", 0.6, 0xaaa995)
  }
  nodes.push(@scene.rect(x=0, y=490, w=960, h=110, fill=0x152026, alpha=0.96))
  for i in 0..<6 {
    let h = g.party[i]
    text(
      nodes,
      80 + i.to_double() * 160,
      515,
      "\{h.name()} L\{h.level}",
      0.55,
      0xd7b77b,
    )
    text(
      nodes,
      80 + i.to_double() * 160,
      537,
      "HP \{h.hp}/\{h.max_hp()}",
      0.55,
      0xb9c8ad,
    )
    text(
      nodes,
      80 + i.to_double() * 160,
      558,
      "MP \{h.mp}/\{h.max_mp()}",
      0.5,
      0xa4b1bd,
    )
  }
  let help = if g.mode == @sim.Fighting {
    "1 ATTACK / 2 GUARD / 3 HEAL / 4 FLAME / 5 POTION / F ALL / ENTER NEXT"
  } else if g.mode == @sim.Warning {
    "ENTER: CHALLENGE GUARDIAN / ESC: RETREAT"
  } else if g.mode == @sim.Looting {
    "ENTER: DISARM AND OPEN / ESC: LEAVE"
  } else if town {
    "\{g.gold}G / \{g.potions} POTIONS / TOWN SAVE: WEB VERSION"
  } else {
    "WASD MOVE+TURN / QE STRAFE / ENTER INTERACT / R RECALL HALF LOOT"
  }
  text(nodes, 480, 584, help, 0.5, 0xbdc4b5)
}

///|
priv struct NativeKeys {
  mut keys : Array[Int32]
}

///|
let native_keys : NativeKeys = { keys: [], }

///|
fn surface_aspect() -> Double {
  1.6
}

///|
fn surface_height() -> Double {
  600
}
