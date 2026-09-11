# IRON YARD — Kagura版

`mizchi/modeling-playground` のAC風ロボットTPSを移植したゲーム。STRIXを操作し、BASTIONとの3ウェーブの戦闘、または静止標的での射撃演習を行う。

ゲームロジック・姿勢制御はMoonBit、描画と音声はkaguraの既存基盤を使用する。React / R3F / Three.jsの実行時依存はない。ブラウザの入力・メニュー・HUDは薄いDOMアダプターに分離した。

## 起動と検証

Node.js 24+、pnpm、MoonBit、just、WebGPU対応ブラウザが必要。リポジトリのルートから実行する。

```sh
pnpm install --frozen-lockfile
just iron-yard-dev              # http://127.0.0.1:5192
just iron-yard-test             # MoonBit + 実モデル + 移植元との数値比較
just iron-yard-build            # examples/games/iron_yard/dist/
just iron-yard-e2e              # 本番ビルドをChromium / SwiftShaderで操作
just iron-yard-e2e-metal        # Apple Silicon + Chrome / Metal、Retina解像度で操作
just iron-yard-ci               # 上記の検証一式
```

Metal検証はGoogle Chromeをヘッドレスの別プロファイルで動かし、Apple／Metalであることを検査する。対話デバッグ時は `IRON_YARD_HEADED=1 just iron-yard-e2e-metal` を明示する。開発用URLは常に `http://127.0.0.1:5192/`、テスト専用プレビューはSwiftShaderが5193、Metalが5195。

初回は `pnpm exec playwright install chromium` でE2E用ブラウザを取得する。開発コマンドはMoonBitとWGSLの変更を監視する。モデルを変更した場合は再起動してアセット変換をやり直す。独自HTMLと起動処理があるため、汎用の `just dev` / `just render` ではなく上記の専用コマンドを使う。

## Editor内での実行

`just studio-dev` で [Kagura Studio](http://127.0.0.1:5190/) を起動し、**Resources → Open IRON YARD** から開ける。既存のWebGPU / WGSL版を同梱し、別のゲームサーバーは不要。実モデルを見ながら建物の位置・サイズ・色・種類、敵・波・出撃地点、ミッション・カメラ・照明、ライフルのダメージ・演出・効果音を編集できる。modeling-playgroundのScene Studio v1 JSONを読み書きし、Save / Undo / WebMCPとヘッドレスシミュレーションに対応する。編集したドキュメントで試遊し、停止メニューの「編集に戻る」で作業を再開できる。

`just iron-yard-editor-build` でゲームと `editor/ui/dist/extension.mjs` をビルドし、Studioの **Open project** からこのディレクトリを選ぶと、[iron-yard.kgrprj](iron-yard.kgrprj) が専用拡張・`scenes/iron-yard.json`・配下のモデルと音声を読み込む。Saveはシーンファイルに書き戻す。ゲームと一緒に拡張を変更・再ビルドし、**拡張を再読込** で未保存のシーンを維持したまま更新できる。汎用エディタはStudio本体に残り、専用編集からいつでも戻れる。

ゲームソースの変更後は `(cd editor/studio && pnpm build:games)` で同梱版を更新する。詳細は [Studioのゲーム連携](../../../editor/studio/README.md#iron-yard)。

## Chromeでの性能比較

起動済みのKagura版・Three.js版を、独立したChrome / Metalで順番に計測する。1280×800 CSS px、DPR 2（実描画1920×1200）、演習モード、5秒のウォームアップ後に10秒×3回。出撃可能になってからモードを切り替え、計測前後にゲーム側の状態で演習モード・稼働中・標的3機を検査する。両方のビルド種別を揃える。最終比較には各リポジトリでproductionビルドを作り、Vite previewで配信する。

```sh
just iron-yard-profile kagura=http://127.0.0.1:5192/ three=http://127.0.0.1:5194/game.html
just iron-yard-profile --scenario=strafe --profiles=false --out=test-results/iron-yard-strafe kagura=http://127.0.0.1:5192/ three=http://127.0.0.1:5194/game.html
just iron-yard-profile --heap-snapshot=true --out=test-results/iron-yard-memory kagura=http://127.0.0.1:5192/
just iron-yard-gfx-test
```

`--seconds=10`、`--repeats=3`で計測時間と反復数を指定できる。`strafe`はA/Dを1秒ごとに交互入力する。性能計測も既定ではヘッドレスで動かし、ウィンドウ表示は `--headed=true` で明示する。ヘッドレスとウィンドウ付きではrAFの上限が異なる場合があるため、同じ設定同士で比較する。ウィンドウ付きの計測中はフォーカス喪失による停止を避けるためChromeを操作しない。

`test-results/iron-yard-profile/`にFPS、フレーム間隔p50/p95/p99、ChromeのTaskDuration、GC後のJSヒープ・backing storage・DOM数、スクリーンショットを保存する。CPUと割り当てサンプリングはFPS採取後に別区間で実行し、プロファイラの負荷をFPSに混ぜない。`.cpuprofile`はDevTools Performance、`.heapprofile`と任意の`.heapsnapshot`はMemoryに読み込める。

FPSはrAFの実測で、ディスプレイの更新レートで頭打ちになる。Kaguraの`renderCpuP50`はGPUコマンドのエンコード・送信だけで、MoonBitのシミュレーションやコマンド構築を含まない。GPU時間は`diagnostics.timingMethod`が`timestamp-query`の場合にだけGPU処理時間として扱う。ヒープとbacking storageは別項目であり、GPU VRAMやChromeプロセス全体の使用量ではない。

実測結果と原因は [PERFORMANCE.md](PERFORMANCE.md) に記録する。

## 操作

| 入力 | 動作 |
| --- | --- |
| WASD | カメラ基準の移動 |
| Shift＋移動 | 地上ブースト |
| Space短押し / 長押し | ジャンプ / 0.22秒後から上昇ブースト |
| マウス | 照準。Pointer Lock不可の場合は右ドラッグ |
| 左クリック長押し | ライフル連射 |
| E長押し→離す | 最大3機をロックし、各2発のミサイルを斉射 |
| Esc | 停止。ロック・未発射予約を取り消す |
| 出発地点へ戻す | 機体・敵・弾・AP・戦績・ミッションを初期化 |
| メニューの音量・ミュート | BGMと効果音の音量を個別に調整、まとめてミュート |

視線遮蔽、屋上着地、敵の索敵・記憶・経路探索・予告射撃、自機AP、撃破、3ウェーブ、180秒制限を移植した。敵AIモードではウェーブ間にAPを200回復する。停止・フォーカス喪失中はシミュレーションを進めない。ライフルとミサイルは現在フレームの実ボーン位置から発射する。

## Kagura内で完結する範囲

| 機能 | 接続先 |
| --- | --- |
| GPU描画・深度・テクスチャ・オフスクリーン | `mizchi/gfx`、`platform/web_runtime_hooks`、既存 `lib/web/kagura-gfx.js` |
| メッシュ・座標・カメラ | `mesh3d`、`geom/math3d`、`geom/camera3d` |
| PBR・金属度・粗さ・発光 | `kagura_engine/draw3d/shaders/standard.wgsl` |
| ボーン姿勢・クリップ補間 | `anim3d/animation3d`、`anim3d/transform3d` |
| 地面・建物・機体の影 | `kagura_engine/shadow3d` のシャドウマップ |
| トーンマッピング | `draw3d/shaders/color.wgsl` のACESFilmic |
| BGM・効果音 | `kagura_audio` のWAVデコーダーとMixerAudioContext |
| ゲーム移動・衝突・弾・AI | `sim`。元版と同じ運動学と線分/AABB判定をMoonBit化 |

別の描画エンジンは不要。draw3dにThree.js 0.185.1互換のStandard / unlitシェーダーを追加し、ゲームを接続した。従来のPBR・トーンマッピングAPIの既定動作は維持している。一方、既存のGLBローダーは最初のskinだけを返し、PBRと埋め込み画像を十分に引き継がないため、ゲーム用のインポート工程を追加した。

STRIXの205メッシュはすべて「各頂点のweightが1、パーツ内の接続先が単一ボーン」という剛体スキニングである。`scripts/convert-assets.mjs` はこれを検証し、逆bind行列でボーン空間へ変換、材質とボーンごとに103バッチへまとめる。描画時はボーンのworld行列を既存PBR描画へ渡す。既存GPUスキニングを拡張せず、同じ変形を表現できる。

BASTIONは168種類のメッシュを296箇所へ配置した階層を展開し、43バッチへ統合する。18枚の埋め込み画像、透過、金属度・粗さ・発光を保持する。全頂点、インスタンス数、索引、画像数を実GLBで検証する。アニメーションは元GLBの4クリップを保持し、歩行・浮上・ブーストを補間する。脚の向きと胴体の照準を分離し、ルート移動を二重に加算しない。

このインポーターは同梱の2機体向け。複数ウェイトを持つ柔らかいスキン、異なる骨格の混在、外部画像、圧縮GLBの汎用インポーターではない。条件外は変換時に拒否する。

## 色と照明の契約

シェーダーの正本は `engine/kagura_engine/draw3d/shaders/*.wgsl`。`scripts/embed-wgsl.mjs` がMoonBitの文字列へ埋め込む。生成された `standard_sources.mbt` は直接編集しない。ゲームのbuild / test / devで再生成する。

- HEX色とPNGのRGBはsRGB。HEXはCPUで線形化し、モデル画像は `rgba8unorm-srgb` でGPUにアップロードして補間前に線形化する。glTFのbaseColorFactorはすでに線形なので再変換しない。アルファ値は線形のまま保持する。
- `standard.wgsl` は元版のGGX、相関Smith可視性、多重散乱、DFG LUT、粗さの4乗による反射方向補正を使用する。半球光と環境反射の間接光を分け、材質・太陽・半球光の値も元Stageに合わせる。
- `cube_uv.wgsl` は元版のPMREM CubeUVを直接サンプリングする。RoomEnvironment（blur 0.04）の768×1024 RGBA16F、約6.3MBを同梱し、解像度・粗さのフィルター・HDR値を保持する。経緯度への再投影や8ビット量子化は行わない。
- フラグメント内の照明計算は線形HDR。元版の画面出力順序どおり、ACESFilmicの色行列とRRT/ODT近似 → sRGB → 霧 → アルファ合成と処理する。霧にはカメラ空間の奥行きを使う。空はトーンマッピングと霧の対象外。
- シーン描画先900は表示色のRGBA16Fで、合成時の丸めを抑える。4サンプルMSAAで描画・resolveした画像を画面へコピーする。DPRの上限は元版と同じ1.5。二度目のトーンマッピングやsRGB変換は行わない。シェーダーAPIの `linear_output=true` は別用途の線形HDR出力に使える。
- 深度バッファは描画先ごとに分離し、そのフレーム最初の3D描画時に初期化する。depth-to-color影マップの空白は深度1で初期化する。影マップは2048角、RGBに24ビット深度を格納する。影用カメラは元の光源位置、near 0.5 / far 180、normalBias 0.04、depth bias 0。元版と同じ背面を記録する。

床は元版と同じ外周・内周のPBR面（粗さ0.95、金属度0）。`app/scenery.mbt` の灰色のグリッド、黄色い道路の破線、出撃リングもそれぞれ元の材質を使い、地面と機体の深度判定に従う。出撃リングは元版と同じ半径5.4〜5.58、64分割の平面メッシュ。装飾ごとのcastShadow / receiveShadowと、基本材質のトーンマッピング設定を引き継ぐ。

`shadow.wgsl` はThree.js r185のPCF（Vogel diskの5点 × 比較後の双線形補間、画素ごとのIGN回転）を実装する。WebGLとWebGPUで異なる画面・テクスチャのY座標を変換する。パックした深度値の色を補間するのではなく、4点の深度比較結果を補間する。

モデル画像はGLBのフィルター・Repeat / Clamp設定を保持する。今回のBASTIONは18枚すべて最近傍補間、ミップマップなしの指定。カスタム描画でも画像ごとのサンプラーをバインドする。汎用APIの線形補間についてもsRGB復号前後の順序をGPUで検証する。

従来の経緯度反射シェーダーでは `atan2(0, 0)` がMetal上でNaNを発生させ、アルファ合成後の道路・屋根・モデルまで黒くなる問題があった。従来APIには極のガードを追加してあり、ゲームは経緯度変換のないCubeUVへ移行した。実ゲームの浮動小数点シーン画像に非有限値がないことと、機体・路面の不透明描画順を逆転しても遮蔽が変わらないことをGPUで検証する。

環境反射と比較用画素を再生成する場合だけ、modeling-playgroundを別途起動して以下を実行する（引数はそのVite URL）。Three.jsはこのオフライン工程だけで使用し、ゲームの実行時依存には含めない。由来とライセンスは [THIRD_PARTY.md](./THIRD_PARTY.md)。

```sh
node examples/games/iron_yard/scripts/export-three-reference.mjs http://127.0.0.1:5194
node examples/games/iron_yard/scripts/export-shadow-reference.mjs http://127.0.0.1:5194
# DFG LUTの再生成（隣のcheckoutにインストール済みのThree.jsを使用）
node examples/games/iron_yard/scripts/import-dfg.mjs
```

`tests/render-reference.json` は元版を描画して記録した36ケース（9材質 × 2視線角 × 2距離）と5ケースのトーンマッピング参照値。E2Eはゲームで使うWGSLとPMREMをGPU上で実行し、材質のRGB差を2/255以内、トーンマッピングの差を1/255以内で照合する。`tests/shadow-reference.json` の24ケースも、元版のGLSLと比較サンプラーを実行した結果に対し2/255以内で比較する。この許容値は参照パッチに対するもので、シーン全体の画素一致を保証するものではない。

## 構成と検証範囲

- `sim`: 状態の型、移動、戦闘、敵AI、ミッション、JSON snapshot。DOM/GPU依存なし。
- `rig`: 変換済みアセットの読込、既存AnimationClipのサンプリング、四脚の軸と上半身照準。
- `app`: kaguraのフレーム更新・PBR描画・音声へ接続。
- `headless`: Nodeからの数値回帰検証。ゲーム状態はインスタンスごとに独立。
- `web/controls.ts`: 入力捕捉。`web/ui.mjs`: メニュー、音量、投影済み座標によるHUD。
- `e2e`: 通常操作、元版の材質・ACESFilmic・霧との画素比較、色空間、反射の強度、深度、影、メニューのフォーカス・音量・狭い画面での内部スクロール。
- `tests/movement-reference.json`: 移植元の移動関数から記録した6シナリオ。MoonBit版の位置・速度・歩行位相を誤差1e-8以内で比較。

公開ブラウザAPIは `ironYard.snapshot()`、`pause()`、`reset()`、`rendererInfo()`。snapshotは描画側のキャッシュではなく現在のシミュレーションをコピーする。`rendererInfo()` で描画基盤、モデル画像18枚＋環境反射1枚、音声6本、バッチ数、照明プロファイル、PMREMのサイズと形式、現在の音量・ミュート状態を確認できる。

`headless` の `step` は移動・AI・戦闘検証用で、アセットなしの近似銃口を使用する。ブラウザでの精密な銃口は `rig.update_animator` が計算する。ヘッドレスとブラウザの射撃全体が同一という保証はしていない。

現在の実行ターゲットはブラウザのWebGPU。シミュレーションは描画なしで動作するが、nativeのウィンドウ・入力・アセット読込への接続は未実装。照明・環境反射・トーンマッピング・霧は上記の参照値で検証する。AA方式・影の計算・モデル画像の補間・Stageの装飾設定は元版に合わせている。GPUのMSAAサンプル位置、浮動小数点精度、ブラウザの合成処理による画素差はあり、シーン全体のビット単位の一致は保証しない。

UIは元版のGame / CombatScene / style.cssを基に、HUDの配置と書体（Helvetica Neue / Arial / 日本語システムフォント、計器はui-monospace）を引き継ぐ。外部Webフォントへの依存はない。出撃・停止画面はネイティブのdialog、音量はラベル付きrange、操作説明はkbdで構成する。メニュー内のフォーカス移動、停止時の再開ボタンへのフォーカス、狭い画面でのカード内スクロールに対応する。

Studioの編集は `editor/scene` の移植元互換契約を入口とし、検証済みのシーンを `sim/scene.mbt` のレシピへ変換する。建物の描画と当たり判定、敵・波、時間制限、ライフルのダメージと演出を同じドキュメントから構築する。`ironYard.loadScene(document, ai)` と `sceneDocument()` がブラウザ側の接続API。専用編集UIは `editor/ui/` に置き、編集ビューも同じゲームのKagura WebGPU / WGSL描画を使う。`app/editor.mbt` が自由カメラ・選択枠・凍結したシーン・演出シークを提供し、通常のゲーム更新から分離する。

## 移植元

`mizchi/modeling-playground` commit `aa7ab3ea9ed08e457b574547e27f4b0c8e463f04`。

- `game/simulation.ts`, `combat.ts`, `enemies.ts`, `stage.ts`, `types.ts`
- `game/animation.ts`, `Robot.tsx`, `studio/action.ts`, `studio/mission.ts`, `studio/document.ts`
- `game/Game.tsx`, `CombatScene.tsx`, `style.css`（HUD・メニュー・書体の移植元）
- `game/controls.ts`（ブラウザ入力アダプターとしてコピーし、型importを調整）
- `robot/models/strix/output/strix.glb`, `robot/models/bastion/output/bastion.glb`
- `audio/output/03-oath-of-the-lightning-battle.wav`, `audio/output/sfx/01-explosion.wav`〜`05-blunt-hit.wav`

ソースアセットは `assets/source` / `assets/audio` に同梱し、隣のmodeling-playground checkoutや外部CDNを起動時に参照しない。モデル変換の生成済みJSONと配布用distはGit管理せず、ビルドで再生成する。PMREMと数値・画素比較用の参照データは同梱する。


### Geometry・instancingとSIMD実験

静的メッシュは更新世代付きで登録し、影・本描画・同型機のGPUバッファを共有する。PBR uniformとJSの描画コマンドを再利用し、互換な不透明描画を最大32インスタンスにまとめる。API契約は[GEOMETRY.md](../../../lib/web/GEOMETRY.md)、比較結果は[PERFORMANCE.md](PERFORMANCE.md)を参照。

`just iron-yard-simd`でZig製MVPカーネルのスカラー/SIMD/`-Oz`をChromeで比較できる。Zig 0.16、wasm-tools、wasm-optが必要。一括入力と通常配列の逐次転送を分けて計測する。本番の描画経路はこの実験用Wasmに依存しない。
