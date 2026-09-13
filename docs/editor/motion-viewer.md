# 汎用モーションビューア

Studio 本体の **Motions** ペーンで、素体と武器を組み合わせ、武器のアニメーションを確認する。
ゲーム固有の拡張や Play を起動する必要はない。

## 開く

`just studio-dev` で起動し、`http://127.0.0.1:5190` を開く。

1. **Examples → Hack & Slash 3D** を選ぶ。
2. **Project → motions/enemies.kgrmotion**（敵）または **motions/hunter.kgrmotion**（プレーヤー）をクリックする。
3. **素体**と**武器・モーションセット**を選ぶ。武器選択時はその武器の既定クリップになる。
4. 素体を変更しても、武器・モーション・再生位置は維持される。

ASHEN HUNT のゴブリン、コボルト、スケルトン、重装ゴブリン、ボスの5素体と、
拳の装具＋パンチ、槍＋刺突、触媒＋詠唱、弓＋射撃の4セットを同梱する。
例えばゴブリンに弓、スケルトンに槍を装着できる。射手と術師は同じスケルトン素体を共有する。
プレーヤーは狩人素体に、鉈＋斬撃・槍＋刺突・拳具＋パンチ・触媒＋魔法弾・弓＋射撃の5セットを同梱する。
ゲームでは画面下の武器選択、または物理キー **X** で持ち替える。通常攻撃は左クリック／J／攻撃ボタン。
全セットで「突進」クリップも選べる。Launch / Brake が踏み込み開始と停止の目印になる。
ゲームでは物理キー **C** または専用ボタンで突進する。移動中は移動方向、停止中は近くの敵へ向かう。
0.2秒の構え → 踏み込み → 硬直で、再使用は3秒後。壁で停止し、同じ敵には一度だけ命中する。回避で中断可能。
選択したセットはセーブに保存する。攻撃・回避中の持ち替えはできず、回避で未発射の攻撃を中断できる。

別プロジェクトでは `.kgrprj` の `resources` に `.kgrmotion` を登録すれば同じ操作で開ける。
プロジェクトを開かずに **Motions → ファイルを選択** から読み込むこともできる。

## 確認操作

- 再生・一時停止、先頭へ戻る、前後1コマ、タイムスライダー。
- 0.25 / 0.5 / 1 / 2倍速、ループ切替。ループなしでは最終姿勢で停止する。
- Impact / Release ボタンでゲームの命中・発射時刻へ移動する。
- 骨格の重ね表示、グリッド、斜め・正面・横・俯瞰カメラ。
- キャンバス上では物理キーの Space で再生、左右矢印でコマ送り、F でフレーム。

ドラッグで回転、右ドラッグでパン、ホイールでズームする。シークとコマ送りは一時停止する。
素体・武器・クリップを変更してもシーンドキュメント、revision、Undo 履歴は変えない。
ペーンを閉じる・プロジェクトを切り替える・Play を開始する場合は描画ループと GPU リソースを破棄する。

## ファイルと実装

`.kgrmotion` は `format: "kagura.motion"`, `version: 2` の JSON。
[型定義](../../editor/studio/public/motions.d.ts) と [実行時検証](../../editor/studio/motions/contract.mjs) を共通契約とする。

| データ | 内容 |
| --- | --- |
| skeleton | 素体と装備が共有する骨格と手・小道具のソケット。親を先に並べたローカルTRS |
| models | 素体・衣服・防具のバインド形状と材質。武器や既定クリップを持たない |
| weapons | 独立した装備形状、使用可能なclipsのID一覧、defaultClip。矢筒も弓に所属 |
| clips | 秒単位の時間、表示FPS、命中イベント、関節のTranslation / Rotation / Scaleチャンネル |

素体と武器のpartsは同じ形式（PNU頂点・三角形・頂点ごとの4関節/ウェイト・RGBA材質）を使う。
武器はモデルIDを参照せず、共通骨格にバインドする。各セットには複数クリップを登録でき、
ビューワは選択中の武器に含まれるクリップだけを表示・再生する。

v1も読み込み可能。旧ファイルの形状は分割できないため、埋め込まれた装備をそのまま保持し、
全クリップを持つ「既存モデルの装備」セットへ読み込み時に変換する。武器の交換にはv2で再出力する。

単位はメートル。Linear / Step 補間に対応する。Step の発射時刻が丸めでずれないよう、
時刻は Float64 で保持する。負の時間、参照切れ、循環骨格、正規化されていない回転・ウェイト、
未知フィールド、64 MiB を超えるファイルは読み込み時に拒否する。

状態と時計は `motions/player.mjs`、Threeアダプターは `motions/scene.mjs`、
描画とカメラは `motions/viewer.mjs`、UIとプロジェクトの寿命管理は `motions/pane.mjs`。
Studio の Three.js / WebGL で描くため、モデルと動作はゲームと共有するが、ゲームの照明・ポストエフェクトは適用しない。
FBXやGLBを直接アニメーション再生する画面ではなく、変換済みの共通データを確認する。

## ゲームからの出力

```sh
just hunter-motion-assets        # ゲームの実モデル・クリップから再出力
just hunter-motions-build        # HY元データからクリップとビューア用データを再構築
just studio-examples-build hacknslash_3d
just studio-motion-test          # 契約・時計・骨格・発射タイミング・API型
```

`hacknslash_3d/motion_api` はブラウザを起動しないビルド用エントリ。
ゲームと同じ素体、材質、モーションから `motions/enemies.kgrmotion` と `motions/hunter.kgrmotion` を生成する。
`app/monster_assets.mbt`が素体、`app/weapon_geometry.mbt`が装備形状、
`app/weapon_sets.mbt`が装備とモーション・命中時刻の組み合わせを定義する。
ゲームでは組み合わせごとに同色材質を一度だけ統合・キャッシュし、既存のインスタンス描画を維持する。
狩人は専用の17関節骨格を持ち、`app/hunter_model.mbt`の素体と装備を分離している。
`app/hunter_weapon.mbt`が鉈・銃、`app/hunter_equipment.mbt`が5セットの装着・キャッシュ・上半身への適用を担う。
槍・拳具・触媒・弓の形状は敵の装備アセットを狩人の手へ再バインドし、
`scripts/hunter-motion-profile.mjs`で既存HYデータを専用骨格へオフラインでリターゲットする。
脚・コートの移動アニメーションは保ち、弓弦は右手へ追従し、つがえた矢は発射フレームで消える。
突進は`game/charge.mbt`で予備動作・移動・硬直のフレームを管理し、
`app/charge_motion.mbt`の共通サンプラーを敵と狩人の骨格へ適用する。
突進クリップはコードで作成した構え・踏み込み・停止のモーションで、HY生成データとは独立している。
水平移動はゲームの衝突処理が担い、クリップには含めない。
`game/player_weapon.mbt`が武器ID・予備動作・命中範囲・硬直の契約を定義し、通常攻撃はその命中フレームで一度だけ判定する。
ゲームの予備動作・硬直の長さに合わせてキーフレーム時刻を変換し、命中イベントも出力する。
盾ガードは独立した副手装備`shield_guard`から再生する。既存の5武器には`lightning_cast`・`flame_cast`・`astral_cast`・`dash_strike`を追加している。
`app/hunter_art_motion.mbt`のゲーム用サンプラーをそのまま書き出し、Contactイベントは雷撃10・炎弾14・星落とし30・踏込斬り16フレームに一致する。
これらはコードで作った動作で、HYの生成結果とは分けて管理する。盾の形状は`app/combat_visuals.mbt`の独立したパーツとして定義する。
別ゲームも同じ形式へ書き出せば、ビューアへの専用コード追加は不要。

## API

```js
await kagura.motions.preview('motions/enemies.kgrmotion');
kagura.motions.selectModel('goblin');
kagura.motions.selectWeapon('bow'); // bow_shotへ切替
kagura.motions.seek(0.6);
kagura.motions.step(-1);
kagura.motions.showSkeleton(true);
kagura.motions.setSpeed(0.5);
kagura.motions.play();
console.log(kagura.motions.snapshot());
kagura.motions.close();
```

E2Eでは実際の描画差分、操作、シーンの保持、プロジェクトなしでの読み込み、
非同期読み込みの競合、閉じた後のキャンバス破棄を検証する。
