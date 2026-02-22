# kagura

[MoonBit](https://www.moonbitlang.com/) 向け 2D（将来 3D）ゲームエンジン。[Ebiten](https://github.com/hajimehoshi/ebiten) の設計に着想を得ています。

[English](README.md)

## 特徴

- **契約先行アーキテクチャ** -- API の契約を先に定義し、実装を差し替え可能に保つ
- **Ebiten の設計を移植** -- 固定 timestep、描画コマンド集約、オフスクリーン合成、バックエンド抽象
- **クロスプラットフォーム** -- デスクトップは wgpu-native、ブラウザは WebGPU / WebGL
- **Pure MoonBit** -- グラフィクスバックエンド境界以外の FFI なし

## アーキテクチャ

```
core/          ゲームループ契約、固定 timestep、フレーム統計
platform/      ウィンドウ / イベント / 入力の抽象（デスクトップ + Web）
gfx/           グラフィクスドライバ、コマンドキュー、シェーダフロントエンド
runtime/       ゲームループ実行と統合
asset/         画像 / シェーダ / マテリアル / アトラスリポジトリ
text/          フォントシェイピング、グリフアトラス（mizchi/font）
ui/            レイアウト / 入力 / レンダーブリッジ（mizchi/layout）
ai/            センサー / ポリシー / アクチュエータ / スケジューラ
draw2d/        2D 描画ユーティリティ
sprite2d/      スプライトシステム
tilemap2d/     タイルマップシステム
camera2d/      2D カメラ
vector/        ベクトル演算
```

### バックエンド戦略

| ターゲット | バックエンド |
|-----------|-------------|
| デスクトップ | wgpu-native + GLFW |
| Web       | WebGPU（主）、WebGL2（フォールバック） |

## クイックスタート

### 前提条件

- [MoonBit](https://www.moonbitlang.com/)
- Node.js 24+
- pnpm
- [just](https://github.com/casey/just)

### インストールと実行

```bash
pnpm install

# JS smoke テスト
(cd examples/runtime_smoke && moon run src --target js)

# Native smoke テスト（macOS -- wgpu-native のセットアップが必要）
bash scripts/setup-wgpu-native.sh
(cd examples/runtime_smoke_native && moon run src --target native)
```

## サンプル

| サンプル              | 説明                              |
|----------------------|-----------------------------------|
| `runtime_smoke`      | 最小 JS smoke テスト               |
| `runtime_smoke_native` | 最小 native smoke テスト         |
| `native_triangle`    | Native バックエンド三角形デモ       |
| `flappy_bird`        | 入力処理付き 2D ゲームループ        |
| `survivor`           | エンティティ・武器・UI の複合ゲーム  |
| `action_rpg`         | アクション RPG プロトタイプ         |
| `arena3d`            | 3D アリーナプロトタイプ             |

各サンプルは独立した MoonBit モジュールです。以下で実行:

```bash
(cd examples/<name> && moon run src --target <js|native>)
```

## ドキュメント

### ユーザー向け

- [入門](docs/user/getting_started_ja.md)
- [チュートリアル](docs/user/tutorials_ja.md)
- [API ガイド](docs/user/api_guide_ja.md)

### 開発参加者向け

- [コントリビューティングガイド](CONTRIBUTING_ja.md)
- [アーキテクチャ](docs/architecture.md)
- [モジュール境界](docs/module_boundaries.md)
- [ロードマップ](docs/roadmap.md)

## 検証

```bash
just fmt
just check target=js
just test target=js
just check target=native
just test target=native
pnpm e2e:smoke
```

## 依存ライブラリ

- [mizchi/image](https://mooncakes.io/docs/#/mizchi/image/) -- 画像コーデック（PNG/BMP/JPEG）
- [mizchi/font](https://mooncakes.io/docs/#/mizchi/font/) -- フォントレンダリング・シェイピング
- [mizchi/layout](https://mooncakes.io/docs/#/mizchi/layout/) -- レイアウトエンジン
- [mizchi/audio](https://mooncakes.io/docs/#/mizchi/audio/) -- オーディオシステム
- [mizchi/svg](https://mooncakes.io/docs/#/mizchi/svg/) -- SVG レンダリング

## ライセンス

Apache-2.0
