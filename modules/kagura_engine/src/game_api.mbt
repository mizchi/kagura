///|
/// High-level game contract for examples and small apps that already model
/// their state as `update + draw`.
pub(open) trait EngineGame {
  update_game(Self, @core.InputSnapshot) -> Unit
  draw_game(Self, EngineContext) -> Array[@gfx.DrawTrianglesCommand]
}

///|
fn[T : EngineGame] engine_game_update(
  game : T,
  input : @core.InputSnapshot,
) -> Unit {
  game.update_game(input)
}

///|
fn[T : EngineGame] engine_game_draw(
  game : T,
  ctx : EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  game.draw_game(ctx)
}

///|
pub fn[T : EngineGame] run_game(
  game : T,
  on_frame? : () -> Unit,
  after_render? : (Double, Double) -> Unit,
  audio_ctx? : @audio.MixerAudioContext,
  audio_frames_per_tick? : Int = 735,
  width? : Int = 320,
  height? : Int = 240,
  title? : String = "kagura",
  canvas? : String = "#app",
) -> Unit {
  run(
    update=fn(input) { engine_game_update(game, input) },
    draw=fn(ctx) { engine_game_draw(game, ctx) },
    on_frame?,
    after_render?,
    audio_ctx?,
    audio_frames_per_tick~,
    width~,
    height~,
    title~,
    canvas~,
  )
}
