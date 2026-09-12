# HY MotionをKaguraへ取り込む

ASHEN HUNTの敵用に、falの `fal-ai/hunyuan-motion` で刺突・パンチ・魔法発射・弓射撃を各1本生成した。
ゲームでは生成サービスへ接続せず、MoonBitに変換済みの回転クリップを再生する。
Three.jsはFBXのオフライン取り込みだけに使う。

## 生成と取り込み

Node.js 24+、pnpm、MoonBit、justを使用する。
`FAL_KEY` はローカルの `.env` または環境変数に設定する。ブラウザへ渡さない。

```sh
# 通信なしで入力を確認
just motion-generate plan --input examples/games/hacknslash_3d/motions/punch.json

# 新しい出力先へ一度だけ生成を依頼（falの課金API）
just motion-generate submit \
  --input examples/games/hacknslash_3d/motions/punch.json \
  --out output/motion/new-punch --execute

# 同じjobを再取得できる。submitの再実行は不要
just motion-generate fetch --job output/motion/new-punch

# 保存された4本の元モーションからゲーム用コードを再生成。通信なし
just hunter-motions-build
just hunter-test
just hunter-e2e
```

`request.json` / `job.json` / `result.json` にプロンプト、seed、request ID、FBXのSHA-256を保存する。
送信前に出力ディレクトリを確保し、通信が不明確な場合もPOSTを自動再送しない。
生成結果は公式Queue APIから取得し、CDNのダウンロードに認証ヘッダーを付けない。

元FBXにはプレビュー用の人間メッシュとテクスチャが含まれるため、骨格と全53トラックを
`motions/source/*/source-motion.json` に抽出して保存する。大きな生FBXはローカルだけに保持する。
通常の再ビルドには、保存済みのJSONと生成レシートだけで足りる。
新しい生成結果へ置き換えるときは、対応するレシートとFBXを `motions/source/<name>/` に置き、
そのクリップの `source-motion.json` を再抽出する。既存の元データは比較用に別の場所へ保存しておく。

## 2等身への変換

`examples/games/hacknslash_3d/scripts/build-motions.mjs` に、対象骨格、切り出し時刻、命中時刻を定義する。
`motions/manifest.json` は実際に使った変換設定と元データのハッシュを記録する。

- HYのTポーズからKaguraの腕を下ろした骨格へ、ボーンの向きと軸を補正する。
- 中間の背骨・鎖骨もワールド回転へ合成してから、12関節の素体へ移す。
- HYの左が正のXとなる座標から、Kaguraの右が正のXとなる座標へ明示的に変換する。
- X/Zのルート移動はゲームの衝突判定に任せ、モーションはその場で再生する。Y方向は足底が床を突き抜けないよう補正する。
- 生成結果の動きが最も伸びた時刻を命中時刻とし、再生位相0.5へ合わせる。開始と終了は待機姿勢へブレンドする。
- 共通12関節に槍・弓・弦・つがえた矢の4ソケットを加える。槍は手の位置を保ちながら穂先を攻撃方向へ向ける。
- 弓の本体は左手、引いた弦の中心は右手に固定する。矢は弓の握りへ向け、リリース位相0.5でStep補間のScaleを0にして消す。
- 弓の保持・弦・矢の補正はゲーム側の `scripts/bake-game-motion.mjs`、Translation/Scaleチャンネルの書き出しは共通の `scripts/motion/retarget.mjs` に分ける。

生成結果をそのまま短縮するだけでは、パンチの向きや武器の握りが合わない。
これらのクリップでは、手先の方向を基準に正面を補正し、武器の保持を追加している。
49個の編集済みポーズを `app/enemy_motion_generated.mbt` へ書き出す。

## 戦闘と描画

`game/enemy_attack.mbt` が予備動作、命中、硬直、攻撃方向を管理する。
命中前に向きを固定するため、横や背後へ回避できる。近接攻撃のダメージ判定は命中フレームで一度だけ行い、壁の遮蔽と無敵時間を確認する。
通常の接触ダメージは廃止し、突進の有効時間だけ残す。

| 敵 | 動作 |
| --- | --- |
| ゴブリン、重装ゴブリン | 鉄の拳によるパンチ |
| コボルト | 予備動作から槍を前方へ突き出す |
| スケルトン射手（Ranged） | 36フレームの引き絞りと照準、矢を1本発射、22フレームの硬直。照準は構えた時点で固定 |
| スケルトン術師（Caster）・ボス | 触媒を持つ腕を振って魔法を発射。隕石・ビーム・魔法弾と命中位相を同期 |
| 召喚役 | 同じ詠唱動作を使い、溜めが終わってから雑魚を召喚 |

`@scene3d.BakedSkinningClip` は、初期化時に有限個のスキニング行列を作る汎用部品。
短い近接攻撃は49ポーズ、弓射撃は97ポーズ、2秒の詠唱に使うクリップは241ポーズへ補間しておく。
同じクリップ・位相の敵をまとめてGPUで描き、元の頂点バッファも共有する。
行列はゲームの再開始でも再利用し、現在画面で使っているバッチだけを走査する。
敵1体ごとのCPU頂点変形は不要。歩行は従来の共有ポーズを使う。

単体のスキニング描画で材質色が失われる不具合も `scene3d` で修正した。

## 見た目の確認

Studio の **Motions** ペーンでも、実モデルとクリップをゲーム起動なしで再生できる。
`just hunter-motion-assets` で共通ファイルへ書き出す。操作は [汎用モーションビューア](editor/motion-viewer.md) を参照。

```text
http://localhost:8080/?snapshot=motions&frames=12&seed=42&mute=1
http://localhost:8080/?snapshot=motions&frames=24&seed=42&mute=1
http://localhost:8080/?snapshot=bow&frames=22&seed=42&mute=1
```

`frames=0..48` で、3種類を横に並べた編集確認画面を開く。12が予備動作、24が命中、48が待機への復帰。
`snapshot=bow` は射手単体の確認用で、22が引き絞り、24がリリース、26以降は矢が飛ぶ。
Pで通常の戦闘更新へ戻る。撮影は `just capture-web --url URL --output output/motion.png` を使う。
この画面も実際のゲームと同じモデル・シェーダー・描画処理を通る。
PC・縦長モバイルのE2Eは、実際のGPU画像のポーズ差分と色を検証する。

## 参考

- [modeling-playgroundの生成パイプライン](https://github.com/mizchi/modeling-playground/tree/4533271fcd785002091e4eb0268561a086187012/motion/generation)
- [Hunyuanのリターゲット処理](https://github.com/mizchi/modeling-playground/blob/4533271fcd785002091e4eb0268561a086187012/motion/import/hunyuan.ts)
- [fal Hunyuan Motion API](https://fal.ai/models/fal-ai/hunyuan-motion/api)

Queueクライアントと回転変換は上記リポジトリを参考にKaguraへ移植した。
生成・変換・ビルドは別工程なので、実行時に認証情報やFBXローダーは必要ない。
