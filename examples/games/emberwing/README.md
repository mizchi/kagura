# EMBERWING — 空の厨房

ドラゴンで海上遺跡を飛ぶ、96 秒間のレールシューティング。9 波の kawaiiko 編隊を撃ち落とすと、湯気の出る鴨南蛮に変わって落下する。

リポジトリのルートから `just emberwing-dev` を実行し、<http://localhost:5194/> を開く。
`pnpm kagura dev emberwing --port 5194` でも起動できる。

| 操作 | 動作 |
| --- | --- |
| マウス移動 | 照準。ドラゴンも緩やかに追従する |
| 左ボタン長押し | 照準をなぞって最大 12 体をロック |
| 左ボタンを離す | ロックした各敵へ追尾火球。ロックなしでも 1 発発射 |
| 右ボタン長押し | 火線を連続照射。過熱すると冷却が必要 |
| WASD / 矢印 | 追加の回避移動。物理キー `KeyboardEvent.code` を使用 |
| Esc / M | 一時停止 / ミュート |
| タッチ | 画面をなぞって照準。左下でロック、右下で火線 |

体力は 6。被弾後は短時間無敵になる。96 秒を生き残ればクリアし、結果画面から再挑戦できる。通常敵は 100 点、大きい敵は 400 点。フォーカスを失うと停止する。

## 構成

- `sim/`: 描画やブラウザに依存しない MoonBit の戦闘・編隊生成・カメラ・進行。固定 60 Hz。
- `main.mbt`, `render.mbt`, `shader.mbt`: Kagura の WebGPU 描画、パレット付きメッシュのインスタンシング、HUD 用スナップショット。
- `meshes.mbt`: ドラゴン、羽、鴨南蛮、海上遺跡のローポリモデル。
- `kawaiiko_generated.mbt`: Studio のモデルから焼き出した胴体・左右の羽。実行時に Studio や Three.js を必要としない。
- `assets/host.mjs`: DOM、入力、HUD、Web Audio のブラウザアダプター。戦闘判定は持たない。
- `emberwing.kgrprj`: Studio の Examples → EMBERWING → Play で起動するプロジェクト。

kawaiiko の原型は [`editor/studio/modeling/core/kawaiiko.mbt`](../../../editor/studio/modeling/core/kawaiiko.mbt) で、[chibivue-land/art の kawaiko](https://github.com/chibivue-land/art/blob/main/kawaiko.png) を参考にしたモデルを再利用している。
モデルを変更したら、ルートで `just emberwing-model` を実行してゲームのメッシュを再生成する。生成物はチェックインし、通常のゲームビルドにエディタのビルドを要求しない。

## 検証と配布

```sh
just emberwing-test
EMBERWING_GPU=metal just emberwing-e2e # macOS + Chrome
just emberwing-e2e                    # Chromium + SwiftShader
pnpm kagura build emberwing           # examples/games/emberwing/dist
node editor/studio/scripts/build-examples.mjs emberwing
```

ロック数・発射タイミング、移動する敵への追尾、丼の落下、火線の照準深度と過熱、停止・再開・終了、敵数の上限を JS / native テストで確認する。Playwright は実際の左右クリック、キー入力、縦画面、二本指でのロック解除を確認する。

`examples/catalog.json` と `scripts/web-demo-pages.mjs` に登録済み。通常の Pages ビルドでは `/emberwing/` に収録される。

## 描画計測

サーバーを起動した状態で `EMBERWING_GPU=metal just emberwing-bench` を実行する。環境変数 `EMBERWING_URL` と `EMBERWING_BENCH_SECONDS` で対象 URL と時間を変更できる。

敵は胴体と左右の羽の 3 メッシュを共有する。遺跡・雲・弾・丼もメッシュを共有し、1 draw 当たり最大 256 インスタンスにまとめる。敵 80、火球 96、敵弾 100、丼 48 の上限を設け、生成した静的ジオメトリは GPU キャッシュへ登録する。

ローカル Chrome 152 / Metal、1440×900 @1x、24 秒の実入力による戦闘計測では、最大 30 体・火球 17 発・丼 28 個、最大 13 draw call / 156,100 三角形。フレーム間隔の中央値は 16.7 ms、描画コマンド作成と GPU 送信の CPU 時間 p95 は 2.5 ms。GPU 単体の実行時間ではなく、この端末での測定値。再計測用スクリプトを同梱する。
