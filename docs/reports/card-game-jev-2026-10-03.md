# Card game: Jev ヘッドレス自動プレイ検証（2026-10-03）

ゲームのルールが合法な選択肢を列挙し、Jev が選び、同じルールに選択を適用する構成を検証した。ブラウザ・画像・GPUを使わず、Node 24.21.0 で実行した。キーは `~/.profile` のリテラル代入から読み取り、表示・記録していない。

参考にしたのは [mizchi/jev-playground](https://github.com/mizchi/jev-playground) の五目並べ・MOBAの状態と合法手の渡し方、`packages/jev-core/src/client.ts` の認証・choice・再試行と、[TypeSafe の公開API契約](https://api.typesafe.ai/openapi.json)。独自のゲームルールをJevクライアントには持たせず、既存の `RunState` / `BattleState` とカード・ポーション・敵行動の実装を呼び出す。

この報告は分岐導入前のv1ルールとログの検証記録です。現在のv2リプレイはここにある旧ログを受け付けません。分岐導入後の結果は [分岐・固有エネミーの検証](card-game-adventure-2026-10-03.md) を参照してください。

## 実APIでの結果

要求モデルは `jev-latest`、実際の応答モデルは `jev-1.13.0` だった。

| 条件 | 結果 | 判断数 | 最終HP | 時間 |
| --- | --- | ---: | ---: | ---: |
| メニューから開始、seed 42、判断上限300 | WardenとAscentを選択し、30階の戦闘中に上限で停止 | 300 | 101 | 55.327秒 |
| Warden / Ascent、seed 42、判断上限500 | 30階の最終ボスを倒し、ラン勝利 | 331 | 23 / 101 | 61.175秒 |

2回目の331判断はすべて提示した合法手に含まれていた。戦闘、戦闘勝利後の継続、カード報酬、休息を通り、ポーションを1回使用した。判断時間の中央値は172 ms、95パーセンタイルは253 ms。記録された使用量は入力800,085トークン、出力28,215トークン、331リクエストだった。

seed はゲームの乱数を固定し、モデルの判断を固定するものではない。この1ランの勝利は複数条件に対する勝率の評価ではない。厳密な再現には判断ログを使う。

ローカルの記録（`output/` はGit管理外）:

- `output/card-game-agent/live-menus-seed42.jsonl`
- `output/card-game-agent/live-ascent-seed42.jsonl`

## 再生検証

```bash
just card-game-agent --no-build --replay output/card-game-agent/live-menus-seed42.jsonl
just card-game-agent --no-build --replay output/card-game-agent/live-ascent-seed42.jsonl
```

APIを呼ばずに初期条件と記録された選択を再実行した。両方の記録で、初期状態・毎手の適用前後の状態・最終状態が完全に一致した。上限で止まった1回目は `limit`、完走した2回目は `victory` と再生された。

## 自動検証

- `just card-game-test`: ゲーム183件をJS/nativeそれぞれで通過。共通UI・scene・raster、releaseビルド、Web起動ページの既存チェックも通過。
- `just card-game-agent-test`: エージェントの8件をJS/nativeそれぞれで通過し、NodeのAPI/CLI 15件も通過。APIキーは不要。
- `just card-game-e2e`: Chromiumヘッドレスで既存UIのPlaywright 16件を通過。

エージェント契約では、合法な対象とコスト、ENERGY 0 の無料・Corruption・Xコスト、古いrevisionの拒否、観測の独立性と山札順序の非公開、既存ターン処理との一致、報酬・休息・ボス・終了、ポーション消費を確認した。

ホストとAPIでは、不正な数値、候補の上限と重複、未知の回答、不正な確率・使用量、認証、タイムアウトと再試行、シェルを実行しないキー読み取り、実行の終了と上限、ログ再生と改変検出を確認した。
