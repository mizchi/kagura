# kagura - MoonBit 2D Game Engine

## プロジェクト構成

- `src/` - エンジンコア
- `examples/<category>/<name>/` - サンプルプロジェクト（各ディレクトリが独立した moon プロジェクト）
  - カテゴリ: `games-2d`, `games-3d`, `rendering`, `physics`, `ui`, `ecs`, `smoke`, `experimental`
- `scripts/` - ビルド・開発スクリプト
- `justfile` - タスクランナー

## 依存パッケージ開発

外部パッケージ（`mizchi/glfw` など）に問題が出た場合、`moon.mod.json` の deps でローカルパスを指定して開発できる:

```json
"mizchi/glfw": { "path": "../glfw-mbt" }
```

修正が完了したら、パッケージ側で `moon publish` してバージョン番号に戻す。

**リリース前には `just check-release` でローカルパス依存がないことを確認すること。**

## ビルド・テスト

```bash
just check          # moon check (js)
just test           # moon test (js)
just check target=native  # native ビルド確認
just check-release  # リリース前チェック（ローカルパス依存の検出）
```

## ゲーム UI の検証

canvas 上の UI は DOM を持たないので、`@ui.publish_ui_snapshot` で UI ツリー
（矩形・クリップ・実測テキスト幅・hit 矩形・フォーカス順）を外に出し、Node 側の
決定的ゲートにかける。browser も API キーも不要。

```bash
just ui-check output/ui-snapshot.json      # 文字あふれ/クリップ/画面外/重なり/hit box ずれ
just ui-elements output/ui-snapshot.json   # vlmkit diff png --elements-json 用に変換
just ui-asset-check <png>                  # スプライト/アイコンの入庫ゲート
```

手順とルールの詳細は `docs/tools/ui-verification-runbook.md`。

- `text_measured` は描画側と**同じ算術**で測る（dot text は `@renderer2d.dot_text_size`）
- `path` は実ツリーの階層を反映させる（ツーリングが祖先関係を読む）
- `extern "js"` を含むファイルは `moon.pkg` の `targets` で js に限定し、native は no-op スタブ

## スナップショットテスト (VRT)

Playwright + SwiftShader による Visual Regression Testing。

**現状 CI では非 gating**（`ci.yml` が `--update-snapshots` で実行）。Linux では canvas
screenshot が透明かつ Dawn readback が完了しないため。移植可能なキャプチャの整備は #9、
gating 化は #8。

```bash
just e2e-vrt          # VRT 実行
just e2e-vrt-update   # ベースライン更新
```

### スナップショットモード

URL パラメータでゲームステートを制御し、目視確認と VRT の両方に使える:

```
?snapshot=playing&frames=60&tick=5
```

| パラメータ | 説明 | デフォルト |
|---|---|---|
| `snapshot` | ゲームモード (`playing`, `gameover`) | なし（通常起動） |
| `frames` | update を空入力で進めるフレーム数 | 60 |
| `tick` | 描画フレームを N 回待ってからキャプチャ | 0 |

**目視確認:** `just dev hacknslash_3d` → ブラウザで `http://localhost:8080/?snapshot=playing&frames=60` を開く。実ブラウザの WebGPU で PostFX 込みの描画を確認できる。

**自動テスト:** `just e2e-vrt` で SwiftShader ヘッドレス環境でリグレッション検知。SwiftShader では WebGPU の高度な機能が制限されるため、描画結果は実ブラウザと異なるが、変更による差分検知として機能する。

- `tick` は PostFX パイプライン（Bloom, Tonemap, FXAA）が確実に適用された状態をキャプチャするために使う
- ゲーム側で `globalThis.__kaguraSnapshotTick` に描画済みフレーム数を公開し、Playwright が `waitForFunction` で待機
- 実装: `examples/*/*/src/snapshot.mbt` + `main.mbt` の draw コールバック内

### 新しい example に VRT を追加する手順

1. `scripts/serve-wasm-smoke.mjs` の `VRT_EXAMPLES` に追加
2. `e2e/vrt.spec.ts` の `VRT_EXAMPLES` に追加（タイトル画面）
3. スナップショットモードが必要なら `SNAPSHOT_TESTS` にも追加
4. `just e2e-vrt-update` でベースライン生成

## 注意事項

- `cc-link-flags` は依存パッケージから伝播しない。native ビルドする example では個別に `-lglfw` 等を指定する必要がある
- `extern "C"` を含む `.mbt` ファイルは `moon.pkg` の `targets` で native のみに制限する（`supported-targets` だけでは不十分）
