# UI検証Issueの実装状況（2026-09-12）

Issue本文は旧ディレクトリ構成・vlmkit 0.9.1時点の調査を含むため、現在のコードと照合した。
運用手順は [ui-verification-runbook.md](./ui-verification-runbook.md)。

| Issue | 現在の状態 | 残る作業 |
| --- | --- | --- |
| [#11](https://github.com/mizchi/kagura/issues/11) 導入 | 完了・クローズ。vlmkit 0.11.1、Playwright 1.63.0、`.mcp.json` を確認 | なし |
| [#15](https://github.com/mizchi/kagura/issues/15) 操作性 | `just ui-interactions` を実装。入力列で実際の順送り・逆送り・一周・クリック・フォーカス表示を検査 | 他ゲームは入力profileとsnapshotの接続が必要 |
| [#17](https://github.com/mizchi/kagura/issues/17) flipbook | `just ui-flipbook` を実装。ゲーム内定義から毎tickのPNG・snapshot・diff・停止判定を生成 | 他ゲームの演出は `editor/verification.json` に追加 |
| [#8](https://github.com/mizchi/kagura/issues/8) VRT | 純黒の旧baselineは追跡対象から削除済み。2Dの17ケースは実際のpixel gate | 3D・実GPU側の非gating Playwright VRTを置換 |
| [#9](https://github.com/mizchi/kagura/issues/9) native capture | CPU は `engine.run` から 2D PNG+snapshot。GPU は `backend=gpu` で wgpu readback（3D はこれ）。`just capture` / `just ui-capture --backend gpu` | なし |
| [#10](https://github.com/mizchi/kagura/issues/10) UI introspection | UISnapshot、JS publish、elements変換、native context_path出力を実装。`@scene.run` がラベルを自動 publish。hacknslash_3d は HudContext 用 adapter | 未キーのラベルは `label[n]`。TTF-only の on_frame HUD は scene tree に無い |
| [#12](https://github.com/mizchi/kagura/issues/12) integrity | 幾何 9 種 + PNG 由来の `low-contrast-text`（WCAG AA）。`ui-vlmkit-check` / matrix / flipbook / interactions がフレームを渡す | なし |
| [#13](https://github.com/mizchi/kagura/issues/13) 状態×解像度 | ui_demo + flappy / survivor / action_rpg / hacknslash / card_game を 4 viewport で `just ui-matrix --all`。HUD は `apply_viewport`、ワールドは `Camera2D::set_screen`。title/playing/gameover の InitialStates 済み。native は `just ui-matrix --all --backend native`（js-only の hacknslash を除外） | inventory/pause。3D GPU マトリクス |
| [#14](https://github.com/mizchi/kagura/issues/14) i18n | `just ui-i18n-stress` / `just ui-matrix-gates --i18n`。既定は DE 風 +35%。CI は ui_demo を gating、scene ゲームは advisory（label 矩形=文字幅） | 実フォントアトラスの解決失敗を engine から publish する。HUD に layout slot を足してゲーム側を gating にする |
| [#16](https://github.com/mizchi/kagura/issues/16) VLM review | `just vlm-ui-review --matrix` が verification.json の全セルを回す。`just vlm-ui-daemon-start` が bundle を保持して POST /review を受ける（既定 dry-run） | なし |
| [#18](https://github.com/mizchi/kagura/issues/18) テーマ・素材 | マトリクス example ごとの `editor/theme.json` + `just ui-matrix-gates --theme`。`editor/assets.json` + `just ui-assets`。CI が standard セルのパレットと空の素材リストを回す | なし |
| [#19](https://github.com/mizchi/kagura/issues/19) 全体追跡 | クローズ済み | SceneGame 自動 publish と hacknslash_3d adapter を後追いで入れた |

vlmkit側の [#116](https://github.com/mizchi/vlmkit/issues/116) はクローズ済み。
インストール済み0.11.1の `check integrity --elements ... --image ...` も確認した。
したがって旧調査の「integrityはDOM専用」は現在のCLIには当てはまらない。
ただし画像版はcomputed colorsを持たず、low-contrast-textを検査しない。
その判定は `just ui-check --image` がフレーム PNG からテキストノードを切り、Otsu で
前景/背景を分けて WCAG 比を出す。vlmkit が skip した rule をこちらで埋める。
PNG差分用とは別に、文字実測・clip・z・ゼロサイズを保持するintegrity用elements変換を追加した。
画像寸法とsnapshot座標が一致することも検査する。

native CPU capture は 2D の決定的フレーム。実 GPU は `backend=gpu` で 3D を描く。
SceneGame のラベルと hacknslash_3d の HUD/メニューは snapshot に乗る。

## マトリクスを他ゲームへ広げて分かった不足

`just ui-matrix --all` の対象は `scripts/ui-matrix-manifest.mjs`。
`editor/verification.json` を置いただけでは足りず、次が欠けている。

| 不足 | 実測 | 次 |
| --- | --- | --- |
| HUD が `capture_viewport` でリフローしない | **対応済み。** `apply_viewport` でサイズを渡す。ワールドは `Camera2D::set_screen`。4 viewport の title/playing/gameover/battle が integrity を通る | なし |
| `snapshot.state` が `"scene"` 固定だった | 入力で playing に入っても expectedState を検証できない | `@scene.run(..., snapshot_state=)` を追加済み。未配線の SceneGame はまだ `"scene"` |
| InitialStates が ui_demo だけ | **対応済み（gameover）。** flappy / survivor / action_rpg / hacknslash は debug named factory。release は default のみ | inventory / pause |
| ラベルに key が無い | title/HUD/card の主ラベルは key 済み。ログや敵 HP などに `label[n]` が残る | 残りは描画側に `key=` |
| scene walker はラベルだけ | **対応済み。** keyed `rect` / `rect_outline` が描画矩形=hit で出る。未キーのワールド rect は省略のまま。card_game の HP / End Turn / カード枠に key を付けた | 残りは描画側に `key=` |
| コントラスト | flappy / hacknslash HUD / card_game battle は直してマトリクスに入れた。白を緑の HP バーに重ねると Otsu がバー色を背景にする | テキストをバーの外に置くか、バー色を落とす |
| matrix の allow | `checkImageIntegrity` は抑制リストを読まない。欠陥があると `--update` も baseline を貼らない | verification.json に `allow` を足す |
| 3D | **title + playing GPU。** `just ui-matrix hacknslash_3d --backend gpu`。JS CI には入れない。playing は HUD を `ctx.dst` に載せる。3D ジオメトリはまだ黒 | 3D コマンドをキャプチャデバイスの shader/target で描く |
| theme / i18n / assets | **theme は対応済み。** 各ゲームの `editor/theme.json` を CI が standard セルに当てる。i18n は ui_demo gating、scene ゲームは advisory | HUD に layout slot を足して i18n を gating にする |
| native マトリクス | `just ui-matrix --all --backend native` が js-only を除外。macOS CI も `--all` | 3D GPU。hacknslash を native にするなら `supported_targets` を足す |

`just ui-matrix --all` に card_game の battle 4 viewport も入った。
