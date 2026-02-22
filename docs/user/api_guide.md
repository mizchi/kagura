# API Guide

[日本語](api_guide_ja.md)

kagura is built around low-level contracts. Start with the following APIs.

## Game Loop

- `@runtime.run_loop`: Execute the game loop
- `@core.Game`: Contract for `layout` / `update` / `draw`
- `@core.default_run_options`, `@runtime.default_runtime_config`

## Platform

- `@platform.create_web_canvas_platform`
- `@platform.create_desktop_glfw_platform`
- `@platform.new_window_options`

## Graphics

- `@gfx.create_webgpu_graphics`
- `@gfx.create_wgpu_native_graphics`
- `@gfx.default_graphics_backend_options`
- `@gfx.DrawTrianglesCommand` (the basic unit of drawing)

## Utilities

- `@inpututil`: Just-pressed detection for keys and mouse
- `@debugutil`: Simple draw commands for rectangles, numbers, etc.
- `@sprite2d`, `@draw2d`: Atlas-based 2D drawing helpers

## Code References

- Minimal setup: `examples/runtime_smoke/src/main_js.mbt`
- 2D game: `examples/flappy_bird/src/game.mbt`
- Complex game: `examples/survivor/src/game.mbt`
