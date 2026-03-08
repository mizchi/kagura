# Host API vs Guest ABI 分離

MoonBit ライブラリ API と WASM guest ABI は異なる設計制約を持つ。同一視しない。

## 設計原則

| 観点 | Host API (MoonBit library) | Guest ABI (WASM binary protocol) |
|------|---------------------------|----------------------------------|
| **言語** | MoonBit 専用 | 言語非依存 (MoonBit/Rust/Zig) |
| **型** | rich types (struct, enum, trait) | i32/f32/bytes の flat protocol |
| **メモリ** | GC 管理 | shared linear memory + bump alloc |
| **バージョニング** | semver (moon.mod.json) | ABI version (WIT + magic bytes) |
| **エラーハンドリング** | `raise` / `Result` | return code (-1 = error) |
| **拡張性** | 新 package 追加 | WIT interface 拡張 |

## 現在の ABI v0

```
Guest exports:
  kagura_alloc(size: i32) -> ptr: i32
  kagura_guest_init(env_ptr, env_len) -> config_ptr: i32
  kagura_guest_update(input_ptr, input_len) -> wants_redraw: i32
  kagura_guest_render() -> commands_ptr: i32
  kagura_guest_shutdown()

Host imports (kagura_host namespace):
  log_i32_utf8(level, ptr, len) -> i32
  read_asset_len_i32_utf8(path_ptr, path_len) -> i32
  read_asset_copy_i32_utf8(path_ptr, path_len, dst_ptr) -> i32
```

## 対応表

| Host API | Guest ABI 相当 |
|----------|---------------|
| `@core.Game.update(InputSnapshot)` | `kagura_guest_update(input_ptr, len)` |
| `@core.Game.draw(FrameBudget)` | `kagura_guest_render()` |
| `@gfx.DrawTrianglesCommand` | binary draw command (28B header + vertex/index data) |
| `@core.InputSnapshot` | binary input layout (32B base + key/mouse arrays) |
| `@asset.AssetKey` | UTF-8 string in shared memory |
| `@core.RunOptions` | InitEnv (16 bytes) |

## 方針

1. **Host API は MoonBit idiom を優先**: trait, named params, error handling
2. **Guest ABI は最小 surface を維持**: 関数 5 個 + import 3 個で完結
3. **Protocol は binary-first**: JSON/text ではなく fixed-layout binary で serialize
4. **ABI バージョンは独立管理**: Host API の semver とは別に ABI version を持つ
5. **新機能は Host API 先行**: MoonBit で設計・テストし、安定したら ABI に反映
