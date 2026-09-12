# ASHEN HUNT

`hacknslash_3d` の戦闘、装備ドロップ、成長、スキル、敵AIを使ったローポリのハクスラ試作。
大きな三角帽・顔を覆う襟・分割したコート・鋸刃の武器を持つ2等身の狩人を操作する。
基本視点は引いたクオータービュー。MoonBitとKaguraの描画基盤を使い、Three.jsの実行時依存はない。

```sh
just hunter-dev     # http://127.0.0.1:8080/
just hunter-test    # JS型検査、ゲーム／描画の単体テスト
just hunter-e2e     # Playwrightで実際に起動・移動・攻撃・回避・カメラ・停止を確認
just hunter-capture # 起動済み8080からプレイ画面だけを output/ashen-hunt.png に保存
just hunter-motions-build # HY Motionの敵攻撃を元データから再生成（通信なし）
just hunter-audio   # 11種類のオリジナル効果音と試聴WAVを再生成（ffmpegが必要）
just hunter-cpu-profile # フレーム当たりのCPU時間とChrome用コールグラフを保存
```

Node.js 24+、pnpm、MoonBit、just、WebGPU対応ブラウザが必要。
E2EはmacOSではインストール済みChromeのMetal、他OSではPlaywright ChromiumのSwiftShaderを使用する。
`?snapshot=playing&frames=0` で直接プレイ画面を開ける。
起動直後から画面全体を使い、カメラの縦横比と描画バッファを表示サイズに合わせる。
3Dの描画は最大921,600ピクセルに抑え、HUDの文字・ボタンは表示解像度で描く。
PC画面の「全画面」でブラウザUIも消せる。表示・撮影の契約はKagura共通の
[`assets/web/PRESENTATION.md`](../../../assets/web/PRESENTATION.md) を参照。
撮影には `captureGameFrame()` を使い、表示設定を除いた3D画面・HUD・タッチ操作ボタンを一緒に保存する。
`?seed=42` で同じ森の配置を再現できる。

縦長モバイルは左下にアナログスティック、右下に4つの技・斬撃・回避を配置する。
2本以上の指で移動と攻撃を同時に操作でき、指のキャンセル・画面回転・フォーカス喪失で入力を解除する。
タッチの通常攻撃は近くの敵へ向きを補助する。開始、クラス選択、装備、成長もタッチで操作可能。

キーボードは [`KeyboardEvent.code`](https://developer.mozilla.org/ja/docs/Web/API/KeyboardEvent/code)
で物理キー位置を判定する。下表とHUDのキー表記はQWERTYでの位置を示し、
Dvorakでも同じ位置のWASDで移動、Q/Eでカメラを回転する。入力される文字による別名は使わない。

| 入力 | 動作 |
| --- | --- |
| Space | 開始、クラス選択の決定 |
| WASD / 矢印 | カメラ基準の移動 |
| 左クリック長押し / J | ポインター方向への通常攻撃 |
| Space / Shift ＋ 移動 | 無敵時間のある回避ステップ |
| 1 | 処刑の一撃：周囲への強い斬撃 |
| 2 | 回転斬り：広い範囲への斬撃 |
| 3 | 分裂火弾：敵を狙い、命中で分裂する弾 |
| 4 | 霜の輪：自分を中心とした冷気の範囲攻撃 |
| Q / E、右ドラッグ | カメラ回転 |
| ホイール / R | ズーム / クオータービューに戻す |
| I / K / Escape | 装備 / スキル / 開いたUIを閉じる |
| P / M | 一時停止 / ミュート |
| F2 | 既存の自動プレイ |

モデルは `app/hunter_model.mbt` で再生成する。14ボーン・7色の剛体スキニングで、
頭、左右の腕と脚、武器、左右のコート裾を分離。`app/character.mbt` の姿勢制御は、
走行中の斬撃、交互のスイング、被弾、回避、待機への復帰を扱う。
`modeling-playground` の `modeling/lowpoly.ts` と `modeling/primitives.ts`
（commit `aa7ab3ea9ed08e457b574547e27f4b0c8e463f04`）のリング形状・名前付き剛体パーツの組み方を参考にした独自デザイン。
旅人モデル・顔の造形・GLBは使用していない。

移動とダメージは `game/`、入力とカメラは `app/hunter_controls.mbt`、環境は
`app/hunting_assets.mbt` / `app/hunting_map.mbt`、ブラウザの枠は `web/page.mjs` に分離している。
`assets/hunter-ui.mjs` は表示、`assets/hunter-input.mjs` は入力意図を扱う。
`app/hunter_hud.mbt` の型付きViewModelが、実際の技レベル・クールダウン・装備をHUDへ渡す。
`__ashenHunt` / `__ashenHud` は観測値。UIの入力は `__ashenControls` のキューを通り、
実際の移動・技の使用可否・ダメージはMoonBitのシミュレーションが決める。

現在の狩場は「灰の森」。広い草地、曲がった旧街道、5つの戦闘用の広場、3つの灯火を組み合わせる。
木と岩は離れた小さな障害物として配置し、細い廊下を作らない。
針葉樹・枯れ木・苔岩・鐘と火を持つ祭壇は独立した再利用可能な3Dモデル。
素材ごとに静的メッシュをまとめ、プレイヤーがチャンクを跨いだときに描画キャッシュを更新する。
祭壇は現在は道案内の目印。狩場の敵を倒すと既存の報酬・次の夜への進行につながる。
森の新規開始時は4つの技を使用可能にしてあり、未習得・使用可能・再使用待ちは明示する。
近接2種は通常攻撃と待ち時間を共有する。技の詳しい効果はKまたは「技」から読める。

床の座標は「タイル中心 = 列・行 + 0.5」で当たり判定と一致させる。
現在の移動は平面上なので、部屋と廊下は共通の高さ0。高低差のある階段・坂は未実装。
壁への移動は分割して検査し、接触まで進んで壁沿いの移動を保つ。
木・岩・祭壇の根元は描画と同じタイルで衝突を持つ。小石や草は歩き越せる低い装飾。
元のダンジョン生成・native HUDは既存サンプルと検証用に残し、Webゲームから森を選択する。

敵AI、装備・成長のルール、バランスは既存サンプルがベース。
通常の近接攻撃は既存の周囲範囲攻撃を使用する。武器形状そのものの接触判定、
攻撃の予約入力、武器種ごとの専用モーションは今後の拡張範囲。

共通の入力・音声管理・形状生成は [Kaguraの再利用コンポーネント](../../../assets/web/README.md)
を参照。`just game-components-test` はゲーム本体を起動せずにこれらの契約を検証する。
狩人の寸法・材質は `app/hunter_model.mbt`、技との音声対応は `app/audio_runtime.mbt`、
音源パスと音量は `app/audio_assets.mbt` に定義する。

敵は共通の12ボーン素体に、槍を保持する武器ソケットを1つ加えて作る。`app/monster_assets.mbt` で顔・装備・5つの材質を追加し、
`app/enemy_model.mbt` の共通歩行で腕・脚・尾を動かす。歩行は種類と材質ごとに、攻撃はさらに同じポーズごとにまとめて描画する。
形状の結合には `RigidGeometry::append`、CPU変形の遅延更新にはKaguraの
`scene3d.SkinnedMeshAsset` を使う。

| 種族 | 特徴 | 戦闘での役割 |
| --- | --- | --- |
| ゴブリン | 緑の肌、大きな耳、鉄の拳 | 近接。重装個体や小型の群れも同じ素体を使用 |
| コボルト | 犬顔、長い尾、槍、青緑の腰布 | 素早い接近、槍の刺突と突進 |
| スケルトン | 頭蓋骨、隙間のある肋骨、骨の弓／魔法触媒 | 距離を取る遠隔攻撃。術師・ボスにも展開 |

序盤の小集団に3種が一体ずつ出現する。種族と既存AIの対応は `game/bestiary.mbt`、
序盤の配置は `game/hunting_grounds.mbt`。素体自体はゲームに依存しない
`@procedural3d.build_biped_base()` で生成できる。


敵の刺突・パンチ・魔法発射・弓射撃は、fal HY Motionで生成した動きを2等身の共通素体へ移して再生する。
ゴブリンは鉄の拳、コボルトは槍、スケルトン射手は骨の弓、術師は魔法の触媒を持つ。予備動作、命中、硬直を分け、
近接攻撃は向きを固定した命中フレームでだけ判定する。通常の接触ダメージは突進中だけに限定する。
`?snapshot=motions&frames=24&seed=42&mute=1` で3種類の命中ポーズを並べて確認できる。
`?snapshot=bow&frames=22&seed=42&mute=1` で弓の引き絞り、`frames=26` でリリース後を確認できる。
射手は狙いを固定して弦を引き、36フレーム目に矢を1本放つ。
生成、再取り込み、ポーズ共有の詳細は [モーションパイプライン](../../../docs/motion-pipeline.md) を参照。


## CPU計測

`just hunter-dev` の起動後に `just hunter-cpu-profile --out-dir output/cpu/check` を実行する。
1280×900でゲーム進行を一時停止し、描画を動かしたまま240フレームを計測する。
続けてChrome DevToolsで開ける4秒間の `profile.cpuprofile` を保存する。
`summary.json` にはフレーム当たりのメインスレッド処理時間、フレーム間隔、負荷の高い関数を記録する。
`--moving` を付けると移動・アニメーション・地形の切り替えを含めて計測できる。
SSAO有効時は `--url 'http://localhost:8080/?ssao=1'` を指定する。
比較時はブラウザ、画面サイズ、移動の有無、描画設定を揃える。
CPUサンプリングは別に実行し、フレーム処理時間の計測にサンプリングの負荷を混ぜない。
ゲーム側のスクリプトはシードと操作だけを指定する。計測・統計・コールグラフ出力は
共通の `scripts/profile-web.mjs` を使う。他のゲームでは `just profile-web --url URL` を利用できる。
詳細は [Kaguraの性能計測](../../../docs/performance.md) を参照。
