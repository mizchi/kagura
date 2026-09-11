///|
test "paused runtime preserves a live checkpoint and steps without input" {
  let game = Game::new()
  game.game_mode.set(1)
  game.bird_y.set(100.0)
  game.pipe_timer = 119
  game.debug_pause(true)
  let initial = game.debug_state()
  game.update(@core.empty_input_snapshot())
  assert_eq(game.debug_state().to_json(), initial.to_json())
  game.debug_step()
  assert_eq(game.pipes.get().length(), 1)
  assert_eq(game.frame_count.get(), 1)
  let checkpoint = game.debug_state()
  game.debug_step()
  let advanced = game.debug_state()
  game.debug_replace(checkpoint)
  game.debug_step()
  assert_eq(game.debug_state().to_json(), advanced.to_json())
  assert_true(game.debug_paused)
}

///|
test "live state restore is atomic and does not reset generated objects" {
  let game = Game::new()
  game.debug_pause(true)
  let state = game.debug_state()
  let edited = { ..state, mode: 1, bird_y: 80.0, velocity: -2.0, score: 42, pipes: [{ x: 180.0, gap_y: 90.0 }] }
  game.debug_replace(edited)
  assert_eq(game.score.get(), 42)
  assert_eq(game.pipes.get()[0].x, 180.0)
  assert_eq(game.velocity, -2.0)
  let rejected = try { game.debug_replace({ ..edited, mode: 9 }); false } catch { _ => true }
  assert_true(rejected)
  assert_eq(game.debug_state().to_json(), edited.to_json())
  // Snapshots own their arrays, so later edits cannot mutate the simulation.
  edited.pipes[0].x = 0.0
  assert_eq(game.pipes.get()[0].x, 180.0)
  game.debug_pause(false)
  let running_rejected = try { game.debug_replace(state); false } catch { _ => true }
  assert_true(running_rejected)
}

///|
test "runtime boundary rejects unknown fields instead of dropping edits" {
  let game = Game::new()
  game.debug_pause(true)
  let before = game.debug_state()
  let source = before.to_json().stringify()
  let extra = "{\"birdY\":42," + source[1:].to_owned()
  let rejected = try { let _ = decode_debug_state(extra); false } catch { _ => true }
  assert_true(rejected)
  assert_eq(decode_debug_state(source).to_json(), before.to_json())
}

///|
test "hierarchy is produced by the rendered declaration, not state serialization" {
  let game = Game::new()
  game.resolved_view() |> ignore
  assert_eq(game.scene_outline[0].id, "world")
  assert_eq(game.scene_outline[0].children[3].id, "world/bird")
  game.pipes.set([{ x: 150.0, gap_y: 90.0 }])
  game.resolved_view() |> ignore
  let pipes = game.scene_outline[0].children[2]
  assert_eq(pipes.id, "world/pipes")
  assert_eq(pipes.children.length(), 2)
  assert_true(pipes.children[0].generated)
}
