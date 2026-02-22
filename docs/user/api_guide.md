# API Guide

[日本語](api_guide_ja.md)

kagura is built around low-level contracts and a declarative scene API.

## Declarative Scene API (Recommended)

The `@scene` package abstracts platform initialization, game loop, and rendering, letting you describe games declaratively.

### Entry Point

```moonbit
@scene.run(
  view=fn() { game.view() },      // Called every frame
  update=fn(input) { game.update(input) },  // State update
  width=320, height=240,
  title="my_game",
  canvas="#app",      // JS only: canvas selector
)
```

### Drawing Elements

| Function | Description | Key Parameters |
|----------|-------------|----------------|
| `@scene.rect` | Filled rectangle | `x~`, `y~`, `w~`, `h~`, `fill~`, `alpha~` |
| `@scene.label` | Text display | `x~`, `y~`, `content~`, `color~`, `scale~` |
| `@scene.group` | Offset children | `x~`, `y~`, `children~` |
| `@scene.line` | Line segment | `x0~`, `y0~`, `x1~`, `y1~`, `width~`, `color~` |
| `@scene.rect_outline` | Rectangle outline | `x~`, `y~`, `w~`, `h~`, `line_width~`, `color~` |

### Control Flow

| Function | Description |
|----------|-------------|
| `@scene.fragment(children)` | Group multiple elements |
| `@scene.show(when, child)` | Conditional rendering |
| `@scene.for_each(items)` | Dynamic list rendering |
| `@scene.switch_(cases~, fallback?)` | Exclusive conditional branching |
| `@scene.match_case(when~, render~)` | Case for switch_ |

### State Management with Signals

Combine with `mizchi/signals` for reactive state management.

```moonbit
let score = @signals.signal(0)

fn view() -> @scene.SceneNode {
  @scene.label(content="SCORE:" + score.get().to_string())
}

fn update(input : @core.InputSnapshot) {
  @signals.batch(fn() {
    score.set(score.get() + 1)
  })
}
```

## Low-level API

### Game Loop

- `@runtime.run_loop`: Execute the game loop
- `@core.Game`: Contract for `layout` / `update` / `draw`
- `@core.default_run_options`, `@runtime.default_runtime_config`

### Platform

- `@platform.create_web_canvas_platform`
- `@platform.create_desktop_glfw_platform`
- `@platform.new_window_options`

### Graphics

- `@gfx.create_webgpu_graphics`
- `@gfx.create_wgpu_native_graphics`
- `@gfx.default_graphics_backend_options`
- `@gfx.DrawTrianglesCommand` (the basic unit of drawing)

### Utilities

- `@inpututil`: Just-pressed detection for keys and mouse
- `@debugutil`: Simple draw commands for rectangles, numbers, etc.
- `@camera2d`: 2D camera (world-to-screen transformation)
- `@tilemap2d`: Tilemap rendering

## Code References

- Minimal scene API: `examples/scene_demo/src/game.mbt`
- 2D game: `examples/flappy_bird/src/game.mbt`
- Complex game: `examples/survivor/src/game.mbt`
- Action RPG: `examples/action_rpg/src/game.mbt`
- Low-level 3D: `examples/arena3d/src/game.mbt`
