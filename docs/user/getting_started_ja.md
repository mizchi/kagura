# はじめに

[English](getting_started.md)

## 前提条件

- [MoonBit](https://www.moonbitlang.com/)
- Node.js 24+
- pnpm
- [just](https://github.com/casey/just)

## インストール

```bash
pnpm install
```

## ブラウザで実行

```bash
just dev flappy_bird
```

ビルドしてローカルサーバーが起動します。`http://localhost:8080` を WebGPU 対応ブラウザで開いてください。

他の example も同様に実行できます:

```bash
just dev survivor
just dev action_rpg
just dev scene_demo
```

## CLI で smoke テスト

```bash
(cd examples/runtime_smoke && moon run src --target js)
```

期待されるログ末尾:

```text
runtime_smoke(js): ok (hooked)
```

## Native 実行（macOS のみ）

> Native ビルドは現在 macOS のみ対応しています。Windows / Linux 対応は計画中です。

```bash
bash scripts/setup-wgpu-native.sh
(cd examples/runtime_smoke_native && moon run src --target native)
```

## 新しい example を作る

### ディレクトリ構成

```
examples/my_game/
├── moon.mod.json
└── src/
    ├── moon.pkg
    ├── game.mbt          # ゲームロジック（全ターゲット共通）
    ├── main_js.mbt       # JS エントリポイント
    ├── main_native.mbt   # Native エントリポイント
    └── main_stub.mbt     # その他ターゲット用スタブ
```

### moon.mod.json

```json
{
  "name": "mizchi/my_game",
  "version": "0.1.0",
  "source": "src",
  "deps": {
    "mizchi/kagura": { "path": "../.." },
    "mizchi/signals": "0.6.3",
    "mizchi/web_runtime_hooks": { "path": "../web_runtime_hooks" },
    "mizchi/native_runtime_hooks": { "path": "../native_runtime_hooks" }
  }
}
```

### moon.pkg

```
import {
  "mizchi/signals" @signals,
  "mizchi/kagura/scene" @scene,
  "mizchi/kagura/core" @core,
  "mizchi/kagura/inpututil" @inpututil,
  "mizchi/web_runtime_hooks" @web_hooks,
  "mizchi/native_runtime_hooks" @native_hooks,
}

options(
  "is-main": true,
  link: {
    "native": {
      "cc-link-flags": "-L../../deps/wgpu-macos/lib -L/usr/local/lib -L/opt/homebrew/lib -lwgpu_native -lglfw -Wl,-rpath,../../deps/wgpu-macos/lib -Wl,-rpath,/usr/local/lib -Wl,-rpath,/opt/homebrew/lib -framework Metal -framework QuartzCore -framework IOKit -framework CoreFoundation -framework Cocoa -framework Foundation",
    },
  },
  targets: {
    "main_js.mbt": ["js"],
    "main_native.mbt": ["native"],
    "main_stub.mbt": ["wasm", "wasm-gc", "llvm"],
  },
)
```

> **注意**: `cc-link-flags` は依存パッケージから伝播しません。Native ビルドする場合は `is-main: true` のパッケージに直接記述する必要があります。Web のみなら `link` セクションは不要です。

### main_js.mbt（最小）

```moonbit
fn main {
  @web_hooks.install("#app")
  let game = Game::new()
  @scene.run(
    view=fn() { game.view() },
    update=fn(input) { game.update(input) },
    width=320, height=240,
    title="my_game", canvas="#app",
  )
}
```

### main_stub.mbt

```moonbit
fn main {
  ()
}
```

### 実行

```bash
just dev my_game
```

## 継続的な確認

```bash
just check target=js
just test target=js
pnpm e2e:smoke
```
