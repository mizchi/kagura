# Tutorials

[日本語](tutorials_ja.md)

## Recommended Learning Order

1. `scene_demo` -- Minimal declarative API setup
2. `flappy_bird` -- 2D game loop
3. `survivor` -- Entity management and camera
4. `action_rpg` -- Tilemap, AI, and UI
5. `arena3d` -- Low-level 3D rendering

## 1. Understand the Declarative API with scene_demo

- Reference: `examples/scene_demo/src/game.mbt`
- Goal: Learn the basic pattern of `@scene.run` + Signals + view function

### Basic Structure

```moonbit
struct Game {
  score : @signals.Signal[Int]
  player_x : @signals.Signal[Double]
  input : @inpututil.InputHelper
}
```

Use Signals for view-affecting state and update them inside `@signals.batch` in `update`.

### View Function

`view()` is called every frame and returns a `SceneNode` tree.

```moonbit
fn Game::view(self : Game) -> @scene.SceneNode {
  @scene.fragment([
    @scene.rect(w=320.0, h=240.0, fill=0x1a1a2e),
    @scene.rect(x=self.player_x.get(), y=120.0, w=16.0, h=16.0, fill=0x00FF88),
    @scene.label(x=160.0, y=12.0, content="SCORE:" + self.score.get().to_string()),
  ])
}
```

### Entry Point (JS)

```moonbit
fn main {
  @web_hooks.install("#app")
  let game = Game::new()
  @scene.run(
    view=fn() { game.view() },
    update=fn(input) { game.update(input) },
    width=320, height=240,
    title="scene_demo", canvas="#app",
  )
}
```

## 2. Build a 2D Game Loop with flappy_bird

- Reference: `examples/flappy_bird/src/game.mbt`
- Goal: Learn input handling, physics (gravity), collision detection, and game mode transitions

### Key Points

- View-affecting state uses Signals (`bird_y`, `score`, `pipes`); internal state uses `mut` (`velocity`)
- `@scene.for_each` renders dynamic pipe arrays
- `@scene.show` conditionally displays title/game-over screens

## 3. Learn Extensible Structure with survivor

- Reference: `examples/survivor/src/game.mbt`
- Goal: Learn multi-entity management, camera following, and level-up UI

### Key Points

- `@camera2d.Camera2D` transforms world coordinates to screen coordinates
- Use `camera.world_to_screen_x/y` in view to compute draw positions
- `@scene.for_each` renders enemies, items, and projectiles dynamically
- `@scene.group` for relative positioning (HP bars, etc.)

## 4. Explore Advanced Patterns with action_rpg

- Reference: `examples/action_rpg/src/game.mbt`
- Goal: See tilemap rendering, enemy AI, pause menu, and damage effects

### Key Points

- `@tilemap2d` for tile-based map rendering
- `@ai` for behavior-tree enemy AI
- `@ui` for focus-managed pause menu
- `@scene.show` for damage flash and attack indicator effects

## 5. Learn 3D with arena3d

- Reference: `examples/arena3d/src/game.mbt`
- Goal: Understand CPU-side 3D-to-2D projection, meshes, and basic lighting

> arena3d uses the low-level API (direct `DrawTrianglesCommand` construction).

## Running Examples

Each example is an independent module. Run with:

```bash
(cd examples/<name> && moon run src --target <target>)
```
