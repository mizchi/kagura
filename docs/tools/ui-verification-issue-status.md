# UI検証Issueの実装状況（2026-09-11）

Issue本文は旧ディレクトリ構成・vlmkit 0.9.1時点の調査を含むため、現在のコードと照合した。
運用手順は [ui-verification-runbook.md](./ui-verification-runbook.md)。

| Issue | 現在の状態 | 残る作業 |
| --- | --- | --- |
| [#11](https://github.com/mizchi/kagura/issues/11) 導入 | 完了・クローズ。vlmkit 0.11.1、Playwright 1.63.0、`.mcp.json` を確認 | なし |
| [#15](https://github.com/mizchi/kagura/issues/15) 操作性 | `just ui-interactions` を実装。入力列で実際の順送り・逆送り・一周・クリック・フォーカス表示を検査 | 他ゲームは入力profileとsnapshotの接続が必要 |
| [#17](https://github.com/mizchi/kagura/issues/17) flipbook | `just ui-flipbook` を実装。ゲーム内定義から毎tickのPNG・snapshot・diff・停止判定を生成 | 他ゲームの演出は `editor/verification.json` に追加 |
| [#8](https://github.com/mizchi/kagura/issues/8) VRT | 純黒の旧baselineは追跡対象から削除済み。2Dの17ケースは実際のpixel gate | 3D・実GPU側の非gating Playwright VRTを置換 |
| [#9](https://github.com/mizchi/kagura/issues/9) native capture | 共通capture packageとPNG化は存在。2D CPU captureも存在 | 汎用engine runへのnative配線、2D exampleの接続 |
| [#10](https://github.com/mizchi/kagura/issues/10) UI introspection | UISnapshot、JS publish、elements変換、UIデモの接続が存在 | native出力の接続。UIデモのnative publishはno-op |
| [#12](https://github.com/mizchi/kagura/issues/12) integrity | 幾何・文字実測・hit矩形に加え、`ui-vlmkit-check` で画像版vlmkit integrityへ接続済み | PNG由来のコントラスト検査 |
| [#13](https://github.com/mizchi/kagura/issues/13) 状態×解像度 | `ui-matrix` で入力レシピ×viewportを全走査。UIデモの12セルをCIで比較 | MoonBit初期状態API・nativeとの共通化 |
| [#14](https://github.com/mizchi/kagura/issues/14) i18n | 未実装 | 文字列置換、実フォントのmissing glyph検査、各状態の走査 |
| [#16](https://github.com/mizchi/kagura/issues/16) VLM review | render→決定的gate→構造化reviewとdry-runは存在 | UI daemon、状態マトリクスとの接続 |
| [#18](https://github.com/mizchi/kagura/issues/18) テーマ・素材 | `just ui-asset-check` は存在 | 宣言的テーマ・素材manifest・CI gate |
| [#19](https://github.com/mizchi/kagura/issues/19) 全体追跡 | 継続 | 上記が揃うまでクローズしない |

vlmkit側の [#116](https://github.com/mizchi/vlmkit/issues/116) はクローズ済み。
インストール済み0.11.1の `check integrity --elements ... --image ...` も確認した。
したがって旧調査の「integrityはDOM専用」は現在のCLIには当てはまらない。
ただし画像版はcomputed colorsを持たず、low-contrast-textを検査しない。
PNG差分用とは別に、文字実測・clip・z・ゼロサイズを保持するintegrity用elements変換を追加した。
画像寸法とsnapshot座標が一致することも検査する。

次は #9/#10 のnative配線と #13 の状態マトリクスを揃え、その入力を #12/#14/#16/#18 に接続する。
