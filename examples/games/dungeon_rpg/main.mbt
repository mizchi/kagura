///|
priv struct App {
  mut game : @sim.Game
  mut agent : @sim.AgentSession
  control : @inspection.FieldControl
  mut cached_height : Double
  mut cached_aspect : Double
  mut cached_revision : Int32
  mut cached_view : @scene.SceneNode
  mut cached_state : String
}

///|
fn App::refresh(self : App) -> Unit {
  let aspect = surface_aspect()
  let height = surface_height()
  if self.cached_revision != self.game.revision ||
    (self.cached_aspect - aspect).abs() > 0.01 ||
    (self.cached_height - height).abs() > 0.5 {
    self.cached_height = height
    self.cached_aspect = aspect
    self.cached_view = view(self.game, aspect, height)
    self.cached_state = self.game.snapshot()
    self.cached_revision = self.game.revision
  }
}

///|
fn App::command(self : App, action : String, arg : Int32) -> String {
  if self.control.paused {
    return "解析中です。Studioで再開してください。"
  }
  let generation = self.game.generation
  self.game.command(action, arg) catch {
    e => return e.to_string()
  }
  if generation != self.game.generation {
    self.control.restart()
  }
  self.refresh()
  ""
}

///|
fn main {
  install_platform()
  let agent = @sim.AgentSession::new()
  let game = agent.game
  let app : App = {
    game,
    agent,
    control: @inspection.new_field_control(),
    cached_height: 0,
    cached_aspect: 0,
    cached_revision: -1,
    cached_view: @scene.group(children=[]),
    cached_state: "{}",
  }
  app.refresh()
  app.register_inspection()
  install_host(
    () => {
      app.refresh()
      app.cached_state
    },
    (action, arg) => app.command(action, arg),
    () => app.game.save_town() catch { _ => "" },
    source => {
      try {
        app.game.load_town(source)
        app.control.restart()
        app.refresh()
        ""
      } catch {
        e => e.to_string()
      }
    },
    () => app.control.paused,
    (kind, count, index) => {
      let h = surface_height()
      let p = @sim.enemy_pose(kind, count, index, h * surface_aspect(), h)
      let data : Json = {
        "x": p.x,
        "centerX": p.center_x,
        "centerY": p.center_y,
        "labelY": p.label_y,
      }
      data.stringify()
    },
    () => app.agent.observe().stringify(),
    (revision, choice_id) => {
      if app.control.paused {
        "paused"
      } else {
        try {
          let generation = app.game.generation
          app.agent.step(revision, choice_id)
          if generation != app.game.generation {
            app.control.restart()
          }
          app.refresh()
          ""
        } catch {
          e => {
            let message = e.to_string()
            if message.contains("stale_revision") {
              "stale_revision"
            } else if message.contains("illegal_choice") {
              "illegal_choice"
            } else if message.contains("terminal") {
              "terminal"
            } else {
              "game_failed"
            }
          }
        }
      }
    },
    (seed, balance, master) => {
      if app.control.paused {
        ""
      } else {
        let agent = @sim.AgentSession::new(seed~)
        agent.game.configure_master_data(
          if master == "" {
            app.game.master_data_source()
          } else {
            master
          },
        ) catch {
          _ => return "invalid_master_data"
        }
        agent.game.configure_balance(balance) catch {
          _ => return "invalid_balance"
        }
        app.agent = agent
        app.game = app.agent.game
        app.cached_revision = -1
        app.control.restart()
        app.refresh()
        app.agent.observe().stringify()
      }
    },
    source => {
      app.game.configure_master_data(source) catch {
        e => return e.to_string()
      }
      app.cached_revision = -1
      app.refresh()
      ""
    },
    () => app.game.master_data_source(),
    after => app.game.experience_events(after).stringify(),
  )
  @scene.run(
    view=() => {
      app.refresh()
      app.cached_view
    },
    update=raw => if app.control.begin_update() { app.platform_update(raw) },
    width=960,
    height=600,
    title="FATHOM",
    snapshot_state=() => {
      app.refresh()
      app.cached_state
    },
  )
}
