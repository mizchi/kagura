# Editor / AI Authoring 方針

kagura の editor 統合と AI-assisted authoring の設計方針を定める。

## 原則

1. **preview-first**: editor は preview/inspect/debug を主目的にする。複雑な direct manipulation UI は作らない
2. **code-first**: シーン・UI・アニメーション・アセット接続は MoonBit コードで記述する。GUI 編集は AI 経由を前提にする
3. **安全な編集ループ**: file diff → runtime diff → snapshot diff → undo/redo → rollback を host 側で管理する

## Editor 統合: preview/inspect/debug

### 実装する機能 (優先順)

| 機能 | 説明 | 実装場所 |
|------|------|----------|
| **Scene Preview** | 現在の描画コマンドをリアルタイム表示 | preview-shell |
| **State Inspect** | guest state の serialize/deserialize (snapshot ABI) | host protocol |
| **Frame Stats** | draw calls, vertex count, command breakdown | preview-shell |
| **Input Replay** | 入力列の record/playback で再現性テスト | host protocol |
| **Asset Preview** | ロード済みアセットのサムネイル一覧 | preview-shell |

### 実装しない機能

- ドラッグ&ドロップによるシーン配置 (AI prompt で代替)
- ビジュアルスクリプティング (MoonBit コードで記述)
- プロパティインスペクタ GUI (AI による code patch で代替)
- アニメーションカーブエディタ (コードテンプレートで代替)

### Preview Shell 拡張

既存の preview-shell.ts を拡張する:

```
┌──────────────────────────────────────────────────┐
│ [Canvas]                  │ Title: Game Name      │
│                           │ ABI: v0               │
│                           │ HMR: ready            │
│                           │                       │
│                           │ --- Stats ---         │
│                           │ FPS: 60.0             │
│                           │ Draw Cmds: 42         │
│                           │ Vertices: 1280        │
│                           │                       │
│                           │ --- Controls ---      │
│                           │ [Pause] [Step] [Reset]│
│                           │                       │
│                           │ --- Logs ---          │
│                           │ [guest:0] init ok     │
│                           │ [host] asset cached   │
│                           │                       │
│ [Error Overlay]           │                       │
└──────────────────────────────────────────────────┘
```

## AI Authoring フロー

### 編集ループ

```
User prompt
  → AI がコード patch を生成
  → MoonBit source を更新
  → moon build --target wasm
  → HMR で guest を hot reload
  → preview で結果を確認
  → 問題があれば rollback (jj undo / git checkout)
```

### 安全面の設計

| 層 | 検知方法 | 対応 |
|----|----------|------|
| **File diff** | jj diff / git diff | 変更前後のソースを表示 |
| **Build error** | moon build 失敗 | エラーメッセージを host に表示、auto-rollback |
| **Runtime error** | guest crash / panic | error overlay に表示、前の wasm に fallback |
| **Snapshot diff** | VRT スナップショット比較 | 描画差分を可視化 |
| **Undo/Redo** | jj undo / jj op restore | 任意の時点に復帰可能 |

### AI が操作する対象

1. **MoonBit ソースコード**: `examples/*/src/*.mbt` 内のゲームロジック
2. **アセット参照**: コード内の asset path 文字列
3. **シーン構築コード**: `@scene.rect()`, `@scene.label()` 等の宣言的 API
4. **ゲームパラメータ**: 速度・サイズ・色など数値リテラル

AI は直接 GPU state や binary protocol を操作しない。全ての変更は MoonBit ソースの text patch として表現される。

## Code-First Authoring テンプレート

### 基本パターン

```moonbit
// Scene 宣言
fn view(game : Game) -> @scene.SceneNode {
  @scene.fragment([
    @scene.rect(x=10.0, y=10.0, w=100.0, h=50.0, fill=0x3366FF),
    @scene.label(x=20.0, y=25.0, content="Score: " + game.score.to_string()),
  ])
}

// Game state + update
struct Game { mut score : Int; mut x : Double; mut y : Double }

fn Game::update(self : Game, input : @core.InputSnapshot) -> Unit {
  if input.is_key_pressed(87) { self.y -= 2.0 }  // W
  if input.is_key_pressed(83) { self.y += 2.0 }  // S
}

// Entry point
fn main {
  let game = { score: 0, x: 160.0, y: 120.0 }
  @scene.run(
    view=fn() { view(game) },
    update=fn(input) { game.update(input) },
    width=320, height=240, title="My Game",
  )
}
```

### 推奨構成

```
my_game/
├── moon.mod.json
├── src/
│   ├── main_js.mbt      # JS entry: @scene.run / @engine.run
│   ├── game.mbt          # Game struct, update, state
│   ├── view.mbt          # Scene tree / draw commands
│   ├── systems.mbt       # Physics, AI, etc.
│   └── moon.pkg
└── assets/               # Static assets
```

- `game.mbt`: 状態と更新ロジック (pure logic, no rendering)
- `view.mbt`: 描画のみ (state → draw commands, no mutation)
- `systems.mbt`: 独立したサブシステム (collision, AI, audio trigger)

この分離により、AI は `view.mbt` のみを変更して見た目を調整したり、`game.mbt` のパラメータを変更してゲームバランスを調整できる。
