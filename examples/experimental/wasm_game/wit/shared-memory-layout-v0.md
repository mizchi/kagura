# shared-memory layout v0

`kagura-app-v0.wit` が semantic contract の正本で、この文書は current raw wasm PoC がそれを linear memory にどう lower しているかを固定するための adapter spec です。

- semantic source of truth: `examples/wasm_game/wit/kagura-app-v0.wit`
- shared-memory codec source of truth: `examples/wasm_game/protocol/shared-memory.js`

component model へ移行したらこの文書は不要になりますが、それまでは host / smoke test / ABI test / multi-language guest が同じ layout を参照します。

## exported guest ABI

- `kagura_alloc(size: i32) -> i32`
  - guest linear memory 上の bump allocator
  - semantic ABI ではなく、current raw wasm adapter の都合
- `kagura_guest_init(ptr: i32, len: i32) -> i32`
  - `init-env` を読む
  - `guest-config` への pointer を返す
- `kagura_guest_update(ptr: i32, len: i32) -> i32`
  - `input-snapshot` を読む
  - `update-result.wants-redraw` を `0 | 1` で返す
- `kagura_guest_render() -> i32`
  - `frame-output` 相当の packed draw list への pointer を返す
- `kagura_guest_snapshot_state() -> i32`
  - current PoC では `option<bytes>` の代わりに pointer を返す
  - `0` は `none`
- `kagura_guest_restore_state(ptr: i32, len: i32) -> i32`
  - current PoC では `result<(), guest-error>` の代わりに status code を返す
  - `0` は success

## init-env

WIT:

- `surface.width: u32`
- `surface.height: u32`
- `surface.device-pixel-ratio: f32`
- `hot-reload-enabled: bool`

Layout:

```text
0   i32 width
4   i32 height
8   f32 device_pixel_ratio
12  i32 hot_reload_enabled (0 | 1)
```

固定サイズは `16 bytes`。

## guest-config

WIT:

- `logical-width: u32`
- `logical-height: u32`
- `target-tps: u32`
- `title: string`

Layout:

```text
0   i32 logical_width
4   i32 logical_height
8   i32 target_tps
12  i32 title_len
16  u8[title_len] utf8_title
```

## input-snapshot

WIT:

- `cursor: vec2f`
- `wheel: vec2f`
- `pressed-keys: list<u32>`
- `pressed-mouse-buttons: list<u32>`
- `frame: u64`
- `dt-ms: f32`

Current PoC layout:

```text
0   f64 cursor_x
8   f64 cursor_y
16  f64 wheel_x
24  f64 wheel_y
32  i32 key_count
36  i32[key_count] pressed_keys
..  i32 mouse_count
..  i32[mouse_count] pressed_mouse_buttons
..  i32 touch_count (always 0)
..  i32 gamepad_count (always 0)
```

制約:

- `frame` と `dt-ms` は current raw wasm PoC では未 encode
- touch / gamepad も未 encode
- 数値は実装都合で `vec2f` ではなく `f64` を使っている

## frame-output / render-command

WIT:

- `frame-output.commands: list<render-command>`
- `render-command = clear(rgba8) | mesh2d(draw-mesh2d)`

Current PoC layout:

```text
0   i32 command_count
4   packed draw_command[command_count]
```

draw command:

```text
0   i32 vertex_count
4   i32 index_count
8   i32 src_image_id
12  i32 uniform_r (0-255)
16  i32 uniform_g (0-255)
20  i32 uniform_b (0-255)
24  i32 uniform_a (0-255)
28  f32[vertex_count * 4] vertices (x, y, u, v)
..  u32[index_count] indices
```

制約:

- current adapter は `mesh2d` のみを lower する
- `clear(rgba8)` は command stream に encode せず、host 側の pass clear に残している
- `blend-mode` は current packed format では未 encode

## host imports

- `kagura_host.log_i32_utf8(level, ptr, len) -> i32`
- `kagura_host.read_asset_len_i32_utf8(path_ptr, path_len) -> i32`
- `kagura_host.read_asset_copy_i32_utf8(path_ptr, path_len, dst_ptr) -> i32`

これも WIT の semantic import を current raw wasm へ lower した adapter です。

## guard rails

- semantic contract の変更はまず `kagura-app-v0.wit` を更新する
- shared-memory layout を変える場合はこの文書と `examples/wasm_game/protocol/shared-memory.js` を同時に更新する
- host preview と Node test は shared codec を直接 import し、layout を二重実装しない
