# vs Unity / vs Godot: 戦略

kagura が Unity / Godot と同じ土俵で戦わないための方針。

## 競う軸

kagura の優位性は以下の 5 軸に集中させる:

| 軸 | kagura | Unity / Godot |
|----|--------|---------------|
| **Code-first** | コードが唯一の source of truth。GUI editor なしでゲームが作れる | GUI editor が前提、コードは補助 |
| **AI-assisted editing** | prompt → code patch → preview → rollback のループ | AI 支援は後付けプラグイン |
| **Small API surface** | 50 package, 1153 tests, 全コードが見渡せる規模 | 数万 API、学習コスト大 |
| **WASM guest** | MoonBit/Rust/Zig の guest を差し替え可能 | 言語固定 (C#, GDScript) |
| **Web/native parity** | 同一コードが browser と native で動く | Web export は制限あり |

## 競わない軸

| 非目標 | 理由 |
|--------|------|
| 重い統合 editor | preview host + AI authoring で代替。GUI ノードエディタ・プロパティインスペクタは作らない |
| ビジュアルスクリプティング | MoonBit コードで十分。AI がコードを書く前提 |
| 大規模チーム向けワークフロー | 個人・少人数チームに最適化 |
| コンソール対応 | Web + desktop に集中 |
| asset store / marketplace | 外部ツール (Blender, Aseprite) の出力を直接読む |

## 不足機能の棚卸しと優先順位

Unity / Godot で当たり前の機能を kagura の preview-first 戦略で段階導入する:

### 対応済み

| 機能 | kagura での実現 |
|------|----------------|
| Profiler | `@debugutil.build_profiler_hud()` + preview-shell ABI stats |
| Inspector (frame stats) | preview-shell: FPS, draw calls, vertices, ABI timing |
| Hot reload | Vite HMR (JS), WASM guest full reload |
| Scene preview | preview-shell canvas + WebGPU |
| Pause / Step | preview-shell pause/step controls |
| Input debug | `@debugutil.build_input_debug_overlay()` |

### 次のステップ (preview-first で対応可能)

| 機能 | 優先度 | 実装方針 |
|------|--------|----------|
| Draw call viewer | High | preview-shell に draw command 一覧パネル追加 |
| Asset viewer | High | ロード済み asset のサムネイル + metadata |
| Input record/replay | Medium | input snapshot 列を JSON で保存・再生 |
| Animation preview | Medium | animation state machine の状態遷移を可視化 |
| Build/export workflow | Low | `moon build` + wasm-opt で十分 |

### 対応しない (AI authoring で代替)

| 機能 | 代替手段 |
|------|----------|
| Scene editor (drag & drop) | AI prompt → code patch |
| Animation curve editor | コードテンプレート (`@animation2d`) |
| Property inspector GUI | AI による数値リテラル変更 |
| Tilemap editor | Tiled export → JSON import |
| Particle editor | コードで `@particle3d` API を呼ぶ |

## 移行導線

外部ツールからの asset import 対応状況:

| ツール | 形式 | 対応状況 |
|--------|------|----------|
| Blender | glTF 2.0 (.glb/.gltf) | `@gltf` パッケージで読み込み可能 |
| Blender | OBJ | `@mesh3d` の obj_parser で読み込み可能 |
| Aseprite | PNG sprite sheet | `@sprite2d` + `@sprite_packer` で利用可能 |
| Tiled | JSON tilemap | `@tilemap2d` で読み込み可能 |
| テキスト | BMFont / TTF | `@text` で読み込み可能 (mizchi/font) |

### 概念対応表

| Unity / Godot | kagura |
|---------------|--------|
| GameObject / Node | struct (code-first) |
| Component | struct field / ECS component (`@ecs`) |
| Prefab | 関数 / struct constructor |
| Scene file (.unity / .tscn) | MoonBit ソースコード |
| Inspector | AI prompt / preview-shell |
| Asset Database | `@asset` repository + `@asset_loader` |
| Animator | `@animation2d` / `@animation3d` state machine |
| Physics Body | `@physics2d` / `@physics3d` rigid body |
| Shader Graph | WGSL テキスト (`@gfx.ShaderHandle`) |
| Build Settings | `moon.mod.json` + `moon.pkg` |

## 勝てるユースケース

kagura が Unity/Godot より速く価値を出せる領域:

1. **2D ゲーム (web 配布)** — `@scene.run` で 50 行から始められる。ビルド → ブラウザ表示が数秒
2. **AI と一緒にコード編集** — Claude Code + preview-shell で prompt → patch → preview → rollback が回る
3. **MoonBit 学習教材** — 小さい API surface と豊富な example で言語学習とゲーム制作を同時に進められる
4. **WASM guest 実験** — 同じ host で MoonBit/Rust/Zig の guest を差し替えて比較できる
5. **軽量 3D (web)** — WebGPU で PostFX 込みの 3D がブラウザで動く。Unity WebGL export より軽い
6. **プロトタイピング** — code-first + HMR で試行錯誤が速い。GUI editor の学習コスト不要
