///|
/// High-level game contract for scene-based examples that already model
/// their state as `update + view`.
pub(open) trait SceneGame {
  update_game(Self, @core.InputSnapshot) -> Unit
  view_game(Self) -> SceneNode
}

///|
fn[T : SceneGame] scene_game_update(
  game : T,
  input : @core.InputSnapshot,
) -> Unit {
  game.update_game(input)
}

///|
fn[T : SceneGame] scene_game_view(game : T) -> SceneNode {
  game.view_game()
}

///|
pub fn[T : SceneGame] run_game(
  game : T,
  on_frame? : (
    Array[@gfx.DrawTrianglesCommand],
    @gfx.ImageHandle,
    @gfx.ShaderHandle,
    Double,
    Double,
  ) -> Unit,
  audio_ctx? : @audio.MixerAudioContext,
  width? : Int = 320,
  height? : Int = 240,
  title? : String = "kagura",
  canvas? : String = "#app",
) -> Unit {
  run(
    view=fn() { scene_game_view(game) },
    update=fn(input) { scene_game_update(game, input) },
    on_frame?,
    audio_ctx?,
    width~,
    height~,
    title~,
    canvas~,
  )
}
