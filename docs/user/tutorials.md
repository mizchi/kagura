# Tutorials

[日本語](tutorials_ja.md)

## Recommended Learning Order

1. `scene_demo` -- Minimal declarative API setup
2. `flappy_bird` -- 2D game loop
3. `survivor` -- Entity management and camera
4. `arena3d` -- First/third-person controls and rigid-body physics

## 1. Understand the Declarative API with scene_demo

- Reference: `examples/demos-2d/scene_demo/game.mbt`
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

- Reference: `examples/games/flappy_bird/game.mbt`
- Goal: Learn input handling, physics (gravity), collision detection, and game mode transitions

### Key Points

- View-affecting state uses Signals (`bird_y`, `score`, `pipes`); internal state uses `mut` (`velocity`)
- `@scene.for_each` renders dynamic pipe arrays
- `@scene.show` conditionally displays title/game-over screens

## 3. Learn Extensible Structure with survivor

- Reference: `examples/games/survivor/game.mbt`
- Goal: Learn multi-entity management, camera following, and level-up UI

### Key Points

- `@camera2d.Camera2D` transforms world coordinates to screen coordinates
- Use `camera.world_to_screen_x/y` in view to compute draw positions
- `@scene.for_each` renders enemies, items, and projectiles dynamically
- `@scene.group` for relative positioning (HP bars, etc.)

## 4. Learn 3D Controls and Physics with arena3d

- Reference: `examples/games/arena3d/{controls,physics,view}.mbt`
- Switch views with V; move with WASD, jump with Space and shoot with click or F.
- Both views share the same player, aim and physics world.
- `PhysicsWorld` handles gravity, collisions and impulses; the view reads body positions.
- Authored `crate` and `ball` components can be placed in Studio. R resets the scene.

## Running Examples

Each example is an independent module. Run with:

```bash
just dev arena3d
```
