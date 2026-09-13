# Kagura の再利用コンポーネント

ゲームが決めるイベント・デザインと、エンジンが提供する入力・再生・形状生成を分離しています。
`just game-components-test` で特定のゲームを起動せずに共通部分を検証できます。

| 用途 | エントリー | ゲームが指定するもの |
| --- | --- | --- |
| タッチ入力 | `kagura-controls.js` | ボタン配置、アクション名、シミュレーションへの変換 |
| ゲームパッド入力 | `kagura-gamepad.js` | 標準配置のアクション割当、メニュー、入力デバイスの切替 |
| 効果音管理 | `mizchi/kagura_audio.SoundBank[Key]` | キューの型、イベント対応、音源、音量 |
| ローポリ形状 | `mizchi/kagura_engine/procedural3d` | 寸法、リング形状、ボーン番号、色、配置 |
| 表示・撮影 | `kagura-presentation.js` | アスペクト比、表示モード、HUDを含むルート |
| 音声出力 | `kagura-audio.js` | ミキサーから完成したPCMフレーム |
| スキニング | `scene3d.SkinnedMeshAsset` | 不変の形状とスキン、ポーズの更新番号 |
| 性能計測 | `kagura-profile.js` / `just profile-web` | URL、再現操作、画面サイズ |

## タッチ入力

```js
import {createControlInput, bindVirtualStick} from '@kagura-web/kagura-controls.js';

const input = createControlInput({capacity: 8});
const stick = bindVirtualStick(document.querySelector('#move-stick'), {
  input,
  radius: 48,
  enabled: () => !paused,
  onChange: ({x, y}) => updateThumb(x, y),
});

input.hold(pointerId, 'guard');
input.release(pointerId);
input.tap(13, {slot: 2});
const {x, y, actions} = input.snapshot();
const command = input.consumeCommand();
// シミュレーションの更新ごとに一度消費。コマンドの間にnullの解放tickが入る。
// commandは {key: 13, payload: {slot: 2}} またはnull。

stick.dispose(); // リスナーと、このスティックが所有する入力を解放
input.clear();   // メニュー遷移などで全入力を破棄
```

`move()` に渡す座標は正規化済みの入力値です。`stickVector()` は半径とデッドゾーンから
長さ0〜1のベクトルを作ります。一つのポインターが移動を所有し、他のポインターは独立して
複数のアクションを保持できます。`tap()` は正の整数キーと任意のペイロードを受け取り、
キューが満杯なら `false` を返します。`snapshot()` のアクション配列はコピーです。

DOMのスティックはキャンセル、ポインターキャプチャ喪失、blur、非表示で入力を解放します。
外見や技の使用可否はゲーム側が描画します。ASHEN HUNTでは `hunter-input.mjs` が
`attack` とメニュー選択番号をMoonBit向けの既存インターフェースへ変換します。

## ゲームパッド入力

Webランタイムは入力フレームの取得時に `navigator.getGamepads()` を一度だけ呼び、
各デバイスの軸とボタンをコピーします。MoonBitの既存 `GamepadSnapshot` と、
JSの `globalThis.__kaguraWebRuntime.gamepadFrame` が同じフレームの入力を参照します。
後者は `{index, id, mapping, connected, axes, buttons, pressedButtons}[]`。
`buttons` は `{pressed, value}[]`、`index` はブラウザの機器番号です。
未割当のHID十字キーは中立を1より大きい軸値で表すため、受信時に軸を丸めません。
スティックの範囲制限は、機器別の割当を適用した後に行います。
切断・非表示・フォーカス喪失・API利用拒否では空のフレームになります。
`gamepadCaptureStatus` で `ready` / `unavailable` / `hidden` / `unfocused` /
`denied` / `error` を区別できます。`ready` でも機器数が0ならブラウザからは未検出です。
OSでUSB機器として認識されることと、Gamepad APIへ入力が公開されることは別に確認します。

```js
import {createGamepadReader, navigateGamepadMenu} from '@kagura-web/kagura-gamepad.js';

const reader = createGamepadReader({deadZone: 0.18});
// ゲームの入力フェーズから一度呼ぶ。別のRAFや再ポーリングは不要。
const frame = reader.step(globalThis.__kaguraWebRuntime.gamepadFrame, {
  enabled: !document.hidden && document.hasFocus(),
  now: performance.now(), // ミリ秒
});
if (frame.navigation) navigateGamepadMenu(menuElement, frame.navigation);
// frame.move / look: 円形デッドゾーン補正後、長さ0〜1の{x,y}。
// frame.down / pressed / released: 標準配置のボタン番号。
// frame.ready: 操作可能。activity: ボタン変化かデッドゾーン外の軸変化。
// frame.dt: カメラ操作用の秒数（最大0.05）。ゲームの進行時間とは独立。
```

標準配置、または既知の機器別割当があるパッドを1台選び、接続中は保持します。複数パッドの入力を混ぜません。
接続・機器変更・フォーカス復帰後は、全ボタンと両スティックが中立になるまで操作を抑止します。
トリガーは `pressed` または `value >= 0.55` で押下とし、ボタンの解放は切断時にも通知します。
デッドゾーン内の揺れを `activity` に含めないため、マウスとの持ち替え判定にも使えます。
`navigateGamepadMenu()` は見えるボタンへ空間的にフォーカスを移し、数値・範囲入力と
セレクトは左右で調整します。十字キー／左スティックの長押しは400ms後から140ms間隔で反復します。

`kagura-gamepad-mappings.js` の `normalizeGamepad()` は、ブラウザが `standard` を返す場合は
その割当を優先し、未割当の場合だけ機器IDと軸・ボタン構成に一致するプロファイルを適用します。
現在はMac版ChromeのVictrix Pro BFG PS5有線（`0e6f:0218`、10軸、14ボタン以上）に対応。
`frame.profile` は `standard` / `victrix-pro-bfg-ps5-mac` / `null` です。
PS5の軸0・1は左スティック、2・5は右スティック、3・4はL2/R2、9は十字キー。
十字キーは8方向を標準ボタンへ展開し、1を超える中立値では何も押しません。
受信したデータは変更せず、未知の機器・別レイアウトを推測で割り当てることはしません。
割当の参照元：[ChromiumのMac向けPS5変換](https://github.com/chromium/chromium/blob/main/device/gamepad/gamepad_standard_mappings_mac.mm)、
[十字キーの軸表現](https://github.com/chromium/chromium/blob/main/device/gamepad/gamepad_standard_mappings.cc)。

一時停止・照準・スキル割当・メニューを跨ぐ長押しの抑止はゲーム側の責務です。
ASHEN HUNTの `hunter-gamepad.mjs` はパッド専用の入力所有者IDを使い、
切断時もタッチやマウスの保持入力を消しません。

仕様の参照先：
[MDN: Gamepad APIの使用](https://developer.mozilla.org/ja/docs/Web/API/Gamepad_API/Using_the_Gamepad_API)、
[W3C: 標準配置](https://w3c.github.io/gamepad/#remapping)。
ブラウザが機器を公開するには、ページを表示した状態でパッドを一度操作する必要がある場合があります。

## 効果音

```moonbit
// moon.pkg: "mizchi/kagura_audio" @audio
let context = @audio.MixerAudioContext::new(44100)
let sounds : @audio.SoundBank[String] = @audio.SoundBank::new(context)
sounds.register("impact", clip, volume=0.5)
let result = sounds.play("impact")
sounds.set_muted(true)
sounds.clear()
```

`Key` は `Eq` を実装したゲーム独自のenumでも構いません。キーごとに一つのプレイヤーを所有し、
既定では再生中の同じ音を最後まで鳴らします。明示的な巻き戻しは `play(cue, restart=true)`。
結果は `Played / Suppressed / Muted / Missing` で、再生処理自体のエラーは呼び出し元へ返します。
登録の置き換えと `clear()` は以前の音声を破棄し、ミュートはすべての音を停止します。
`set_paused(true)` は再生位置とミュート設定を保って一時停止し、`set_paused(false)` で
停止前に再生中だった音だけを再開します。停止中の `play()` は `Suppressed` を返します
（ミュート中は `Muted`）。停止中にミュート・置き換え・破棄した音は再開しません。
音源の生成・ブラウザでのデコード・ゲームイベントとの対応は呼び出し側の責務です。

ASHEN HUNTの音源設定は `app/audio_assets.mbt`、イベント対応は `app/audio_runtime.mbt` にあります。

## ローポリ形状

```moonbit
// moon.pkg: "mizchi/kagura_engine/procedural3d"
let shape = @procedural3d.RigidGeometry::new()
shape.loft(0.0, 0.0, [(0.0, 0.4, 0.4), (1.0, 0.15, 0.15)], 6, 0)
let mesh = shape.build_mesh()
let skin = shape.build_skin()
```

三角形、四角形、箱、上下を閉じたリングのロフトを積み重ねます。リングのタプルは
`(y, x方向の半径, z方向の半径)`、箱は中心座標と各軸の全幅です。面は外向きの巻き順と
フラットな法線を持ち、ボーンは頂点ごとに一つ、重み1で割り当てます。
リングは2段以上、辺は3本以上を指定します。それ未満なら形状は追加されません。
上下で異なるボーンを使う箱には `append_box_segment()` を使えます。

バッファは `Mesh3D` の8要素（位置3・法線3・UV2）と `SkinData` の4要素の規約に従います。
`shape.append(part)` で部品を結合でき、インデックスのオフセットとスキンの頂点数を保ちます。
ボーン番号は結合先の骨格と揃えます。
`build_mesh()` と `build_skin()` は独立したコピーを返し、その後の形状追加で変化しません。
狩人、敵、樹木、岩は同じプリミティブを使い、造形・マテリアル・マップ配置はゲーム側で定義します。

## Webでの配布

`scripts/web-runtime-assets.mjs` の `WEB_RUNTIME_FILES` を配布ファイルの単一の一覧にしています。
`copyWebRuntimeAssets(destination)` はギャラリーとStudioの両方で使います。
新しい共有モジュールを追加するときは一覧へ登録してください。依存先の同梱をテストで検証します。

HTMLにはゲームのmodule scriptより先に `renderWebRuntimeImportMap(libPrefix)` の結果を置きます。
これで `@kagura-web/` が開発時の `./assets/web/`、配布時の `../lib/` などに解決されます。
固定のlocalhostパスに依存しません。表示・撮影の詳細は [PRESENTATION.md](./PRESENTATION.md) を参照。

## 汎用の二足歩行素体

```moonbit
let proportions = @procedural3d.default_biped_proportions()
let base = @procedural3d.build_biped_base(proportions)
let head = base.head.build_mesh()
let head_skin = base.head.build_skin()
let skeleton = base.skeleton
```

`BipedBase` は無彩色の頭・胴・腕・脚とスケルトンを返す。それぞれの `RigidGeometry` に
部品を追加したり、胴を肋骨などへ置き換えたりして外見を作る。`BipedProportions` で
腰・膝・肩の高さ、肩幅、頭の寸法、胴幅、手足の太さを指定できる。
足元がY=0、前が+Z、デフォルトの全高は約1.2m。寸法を変えたモデルは対応する
`base.skeleton` と組み合わせる。共通スケルトンで一括描画する派生モデルは関節位置を揃える。

ボーン順序は固定：root(0)、torso(1)、head(2)、左上腕/前腕(3/4)、右上腕/前腕(5/6)、
左腿/すね(7/8)、右腿/すね(9/10)、tail(11)。武器と盾は前腕、耳と顔は頭、尾はtailへ割り当てる。
バインド姿勢とアニメーションの状態は別に管理し、アニメーション中に元の形状を変更しない。
任意の2点間の手足・尾・棒は `RigidGeometry::segment()` で生成できる。

## 静的メッシュの登録

MoonBit JSでは地形やバインド姿勢の描画前に
`@web_hooks.register_static_geometry(vertices, indices)` を呼ぶ。
同じ配列の組は定数時間で再利用し、描画パス間でもGPUバッファを共有する。
登録した形状を変更するときは配列を置き換える。暗黙の登録は弱参照で管理し、
不要になった地形チャンクを保持し続けない。他ターゲットでは何もしない。
可変メッシュは従来どおり値を比較してスナップショットを取り、送信待ちの描画内容を保護する。

カメラ深度パスはSSAOが使う場合だけ生成する。バックエンド自身が変更を検出する場合、
`compose_postfx` とカメラ深度の生成関数に `cache_resources=false` を指定して全頂点のハッシュを省ける。
省略時は従来のキャッシュキーを生成する。

共通API、ポーズの遅延更新、CPU/GPU時間を分けた計測と改善手順は
[描画性能のガイド](../../docs/performance.md) を参照。

## 複数マスのアイテム配置

`mizchi/kagura_game/gameplay2d` の `GridFootprint` と `ItemGrid` は、描画・装備ルール・アイテム本体から独立した配置コンポーネントです。

```moonbit
let grid = @gameplay2d.ItemGrid::new(8, 6)
let shape = @gameplay2d.GridFootprint::new([(0, 0), (1, 0), (0, 1), (0, 2)]).unwrap()
let placed = grid.place(0, shape, 2, 1, rotated=true)
```

`rectangle` で長方形、`new` で任意の占有セルを定義します。各軸は0〜127、重複・負数・空の形状は拒否します。
`rotated=true` は基準形を時計回りに90度回転した向き。形状内の空きセルには別の品を配置できます。
`place` は同じIDの旧位置を除外して検査し、境界・衝突で失敗した場合は元の配置を保持します。
`overlaps` は重なるID、`find_space` は左上からの空き位置、`used_cells` は実占有数を返します。
`clone` で配置を分離し、装備交換など複数の変更を成功時だけ確定できます。アイテムの所有権と交換先の制約は呼び出し側が管理します。
