# Kagura の再利用コンポーネント

ゲームが決めるイベント・デザインと、エンジンが提供する入力・再生・形状生成を分離しています。
`just game-components-test` で特定のゲームを起動せずに共通部分を検証できます。

| 用途 | エントリー | ゲームが指定するもの |
| --- | --- | --- |
| タッチ入力 | `kagura-controls.js` | ボタン配置、アクション名、シミュレーションへの変換 |
| 効果音管理 | `mizchi/kagura_audio.SoundBank[Key]` | キューの型、イベント対応、音源、音量 |
| ローポリ形状 | `mizchi/kagura_engine/procedural3d` | 寸法、リング形状、ボーン番号、色、配置 |
| 表示・撮影 | `kagura-presentation.js` | アスペクト比、表示モード、HUDを含むルート |
| 音声出力 | `kagura-audio.js` | ミキサーから完成したPCMフレーム |

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
直接バッファを結合する場合はインデックスのオフセットとスキンの頂点数を呼び出し側で揃えます。
`build_mesh()` と `build_skin()` は独立したコピーを返し、その後の形状追加で変化しません。
狩人、敵、樹木、岩は同じプリミティブを使い、造形・マテリアル・マップ配置はゲーム側で定義します。

## Webでの配布

`scripts/web-runtime-assets.mjs` の `WEB_RUNTIME_FILES` を配布ファイルの単一の一覧にしています。
`copyWebRuntimeAssets(destination)` はギャラリーとStudioの両方で使います。
新しい共有モジュールを追加するときは一覧へ登録してください。依存先の同梱をテストで検証します。

HTMLにはゲームのmodule scriptより先に `renderWebRuntimeImportMap(libPrefix)` の結果を置きます。
これで `@kagura-web/` が開発時の `./assets/web/`、配布時の `../lib/` などに解決されます。
固定のlocalhostパスに依存しません。表示・撮影の詳細は [PRESENTATION.md](./PRESENTATION.md) を参照。
