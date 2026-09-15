# EMBERWING — 空の厨房

ドラゴンで海上遺跡を飛ぶレールシューティング。9 波の kawaiiko 編隊、弾幕、飛来する岩をくぐり抜け、巨大 kawaiiko を倒す。撃ち落とした敵は、湯気の出る鴨南蛮に変わって落下する。

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

体力は 6。通常弾は 1、岩とボスビームは 2 ダメージで、被弾後は短時間無敵になる。ドラゴン中央の小さな輪が被弾判定の目安。フォーカスを失うと停止する。マウスの左右同時押しにも対応し、片方を離してももう片方の攻撃は維持される。

ウェーブの敵数は 24 → 30 → 36 → 42 → 48 → 54 → 60 → 66 → 72 体。後半ほど狙い弾と扇状弾幕が増え、弾速も上がる。12 秒以降は岩が飛来する。岩の予想到達位置と残り時間を表示するため、円から離れて回避する。

84 秒で巨大 kawaiiko が出現し、倒すまで戦闘が続く。6 か所をロックでき、1.2 秒の予告後に高速ビームを発射する。体力が半分になると予告が 0.95 秒に短縮され、横に並ぶ 3 本のビームと密な円形弾幕を放つ。ビームの狙いは予告時に固定されるため、上下への移動で避けられる。通常敵は 100 点、大きい敵は 400 点、ボスは 10,000 点。ボス撃破時は残った攻撃が消え、大盛りの鴨南蛮を落としてクリアする。

タイトル画面の「巨大 kawaiiko 戦を練習」からボスだけに挑戦できる。`http://localhost:5194/?encounter=boss` はボス、`?encounter=swarm` は最終ウェーブから開始する練習用リンク。いずれも開始ボタンを押してから動く。

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

ロック数・発射タイミング、追尾、丼の落下、火線と過熱、停止・再開、ウェーブの増加、ビーム予告と回避、高速な岩の衝突、ボスの形態変化と撃破を JS / native テストで確認する。Playwright は実際の左右クリックと同時押し解除、キー入力、縦画面、二本指でのロック解除、大群とボス戦を確認する。

`examples/catalog.json` と `scripts/web-demo-pages.mjs` に登録済み。通常の Pages ビルドでは `/emberwing/` に収録される。

## 描画計測

サーバーを起動した状態で `EMBERWING_GPU=metal just emberwing-bench` を実行する。環境変数 `EMBERWING_URL` と `EMBERWING_BENCH_SECONDS` で対象 URL と時間を変更できる。

敵とボスは胴体と左右の羽の 3 メッシュを共有する。遺跡・雲・弾・丼・岩もメッシュを共有し、1 draw 当たり最大 256 インスタンスにまとめる。敵 120、火球 96、敵弾 320、丼 48、岩 18、ビーム 9 の上限を設け、生成した静的ジオメトリは GPU キャッシュへ登録する。

ローカル Chrome 152 / Metal、1440×900 @1x、最終ウェーブから 14.09 秒の実入力による戦闘計測では、最大 72 体・敵弾 295 発・岩 3 個、最大 16 draw call / 330,934 三角形。フレーム間隔の中央値は 16.7 ms、p95 は 17.4 ms。描画コマンド作成と GPU 送信の CPU 時間 p95 は 1.5 ms。敵が通過した後のフレームも含み、GPU 単体の実行時間ではなく、この端末での測定値。

`EMBERWING_URL='http://localhost:5194/?encounter=swarm' EMBERWING_BENCH_SECONDS=14 EMBERWING_GPU=metal just emberwing-bench` で再計測できる。スクリプトはマウス照準・発射とキーによる回避を行い、実測時間・終了状態・各オブジェクト数を出力する。ボスの計測には `?encounter=boss` を使う。
