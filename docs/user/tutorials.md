# Tutorials

[日本語](tutorials_ja.md)

## Recommended Learning Order

1. `runtime_smoke`
2. `flappy_bird`
3. `survivor`
4. `action_rpg`
5. `arena3d`

## 1. Understand the Minimal Setup with runtime_smoke

- Reference: `examples/runtime_smoke/src/main_js.mbt`
- Goal: Understand the minimal connection of `platform` + `gfx` + `runtime`

## 2. Build a 2D Game Loop with flappy_bird

- Reference: `examples/flappy_bird/src/game.mbt`
- Goal: Learn the separation of input handling, state updates, and draw command generation

## 3. Learn Extensible Structure with survivor

- Reference: `examples/survivor/src/game.mbt`
- Goal: Learn how to colocate entity updates, weapon logic, and UI display

## 4. Explore Advanced Patterns with action_rpg / arena3d

- Reference: `examples/action_rpg/src/game.mbt`, `examples/arena3d/src/game.mbt`
- Goal: See how responsibilities are divided when extending to 2D/3D

## Running Examples

Each example is an independent module. Run with:

```bash
(cd examples/<name> && moon run src --target <target>)
```
