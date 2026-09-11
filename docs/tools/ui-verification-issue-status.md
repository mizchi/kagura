# UI検証Issueの実装状況（2026-09-11）

Issue本文は旧ディレクトリ構成・vlmkit 0.9.1時点の調査を含むため、現在のコードと照合した。
運用手順は [ui-verification-runbook.md](./ui-verification-runbook.md)。

| Issue | 現在の状態 | 残る作業 |
| --- | --- | --- |
| [#11](https://github.com/mizchi/kagura/issues/11) 導入 | 完了・クローズ。vlmkit 0.11.1、Playwright 1.63.0、`.mcp.json` を確認 | なし |
| [#15](https://github.com/mizchi/kagura/issues/15) 操作性 | `just ui-interactions` を実装。入力列で実際の順送り・逆送り・一周・クリック・フォーカス表示を検査 | 他ゲームは入力profileとsnapshotの接続が必要 |
| [#17](https://github.com/mizchi/kagura/issues/17) flipbook | `just ui-flipbook` を実装。ゲーム内定義から毎tickのPNG・snapshot・diff・停止判定を生成 | 他ゲームの演出は `editor/verification.json` に追加 |
| [#8](https://github.com/mizchi/kagura/issues/8) VRT | 純黒の旧baselineは追跡対象から削除済み。2Dの17ケースは実際のpixel gate | 3D・実GPU側の非gating Playwright VRTを置換 |
| [#9](https://github.com/mizchi/kagura/issues/9) native capture | CPU は `engine.run` から 2D PNG+snapshot。GPU は `backend=gpu` で wgpu readback（3D はこれ）。`just capture` / `just ui-capture --backend gpu` | 他ゲームの UI snapshot adapter |
| [#10](https://github.com/mizchi/kagura/issues/10) UI introspection | UISnapshot、JS publish、elements変換、native context_path出力を実装。UIデモのJS/native snapshot一致を検証 | 他ゲームへのadapter追加 |
| [#12](https://github.com/mizchi/kagura/issues/12) integrity | 幾何 9 種 + PNG 由来の `low-contrast-text`（WCAG AA）。`ui-vlmkit-check` / matrix / flipbook / interactions がフレームを渡す | なし |
| [#13](https://github.com/mizchi/kagura/issues/13) 状態×解像度 | `InitialStates[T]` と `initialState` でMoonBitの初期状態を指定。16セルをJS/nativeで共通baselineと比較 | 他ゲームでの状態ファクトリ宣言 |
| [#14](https://github.com/mizchi/kagura/issues/14) i18n | `just ui-i18n-stress`。既定は DE 風 +35%。fullwidth/RTL/emoji/digits は `--profiles`。missing glyph は 3x5 HUD の `glyph_pattern` 集合 | 実フォントアトラスの解決失敗を engine から publish する |
| [#16](https://github.com/mizchi/kagura/issues/16) VLM review | `just vlm-ui-review --matrix` が verification.json の全セルを回す。`just vlm-ui-daemon-start` が bundle を保持して POST /review を受ける（既定 dry-run） | なし |
| [#18](https://github.com/mizchi/kagura/issues/18) テーマ・素材 | `editor/theme.json` + `just ui-theme-check`。`editor/assets.json` + `just ui-assets`。CI が ui_demo の standard セルと空の素材リストを回す | 他ゲームのトークン表 |
| [#19](https://github.com/mizchi/kagura/issues/19) 全体追跡 | 継続 | 上記が揃うまでクローズしない |

vlmkit側の [#116](https://github.com/mizchi/vlmkit/issues/116) はクローズ済み。
インストール済み0.11.1の `check integrity --elements ... --image ...` も確認した。
したがって旧調査の「integrityはDOM専用」は現在のCLIには当てはまらない。
ただし画像版はcomputed colorsを持たず、low-contrast-textを検査しない。
その判定は `just ui-check --image` がフレーム PNG からテキストノードを切り、Otsu で
前景/背景を分けて WCAG 比を出す。vlmkit が skip した rule をこちらで埋める。
PNG差分用とは別に、文字実測・clip・z・ゼロサイズを保持するintegrity用elements変換を追加した。
画像寸法とsnapshot座標が一致することも検査する。

native CPU capture は 2D の決定的フレーム。実 GPU は `backend=gpu` で 3D を描く。他ゲームの UI snapshot adapter は #10 の残り。
