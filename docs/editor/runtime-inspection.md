# 実行中のゲームを観察する Studio

Studio の Play 中は、動いているゲームの停止・観察・状態変更を中心に画面を組み替える。Stop で従来の編集画面へ戻り、配置やソースの保存は従来どおり独立して扱う。

## 画面の構成

- 上部に実行状態、Pause / Resume、Step、Restart、Stop、Checkpoint を集約する。未対応の操作は無効にする。
- 左側は論理オブジェクトの一覧と検索。描画ノードのツリーは Render nodes に切り替えて読む。
- 中央はゲーム画面。Fit / 1× / 2× は iframe の表示倍率を変え、ゲーム内の座標や解像度を変更しない。
- 右側は実行状態を全高で表示する。対応ゲームでは型付きフィールドを編集し、未対応ゲームでは公開済みの観察情報を読み取る。
- 下部の折り畳み可能なドックに Changes、Agent、Terminal、Assets、Scene setup などを置く。
- 幅 640px 未満では Objects / Game / State を切り替えて表示する。

停止画面でのオブジェクト選択は、ゲームが公開した `subject` と描画領域の対応を使う。現在は Flappy Bird の Bird を画面から選択できる。名前からの推測、3D のレイキャスト、ドラッグによる位置変更は実装していない。

## ゲームごとの対応範囲

2026-11-10 時点で、以下の 8 ゲームを実ブラウザで検証している。

| ゲーム | 公開情報 | 一時停止 | 実行状態の変更 |
| --- | --- | --- | --- |
| Flappy Bird | 論理状態、型付き Bird フィールド、描画ツリー | 対応。Step も可能 | 対応。Undo と checkpoint あり |
| Arena 3D | Game・Player・各物理ボディを選択して型付きフィールドを観察。位置、速度、接地、睡眠、経過フレームなど | 対応 | 停止中に Player・箱・球の位置と速度を編集。実行中に生成された球も対象 |
| Hack & Slash 3D | シーン、HP、防御エネルギー、敵数、経過フレーム | 対応 | Hunter の HP・防御エネルギー |
| IRON YARD | 戦闘状態、Pilot、武器の待機時間 | 対応 | Pilot の HP、ライフル・ミサイルの cooldown |
| Card Game | シーン、冒険・戦闘の HP、所持金、エネルギー、防御値 | 対応 | 安定したゲーム画面で HP・所持金。プレイヤーの手番ではエネルギー・防御値も編集 |
| Survivor | Player、敵数、経過フレーム、武器 | 対応 | HP・2D 座標・弾のダメージ・発射間隔 |
| EMBERWING | 飛行状態、HP、熱量、過熱、ウェーブ・敵数 | 対応 | Dragon の HP・熱量 |
| AFTERSHIFT | Player・各敵の状態、HP、予告タイマー、区画、ヒットストップ | 対応。戦闘画面を保持 | Player の HP・位置・奥行き、攻撃力、敵の基本予告時間 |

UI スナップショットから未公開の HP、AI、乱数状態などを取得できるとは限らない。描画計測もゲームの論理状態ではない。Capture observation は表示内容を固定する操作で、ゲーム自体は停止しない。

現在の 8 ゲームはすべて、ゲームが公開する論理状態を観察できる。Card Game / Survivor / EMBERWING も UI や描画計測の代わりに、型付きの状態を返すようにした。全状態の復元・Undo・Step・checkpoint は Flappy Bird が対応し、それ以外のゲームは宣言したフィールドだけを編集する。

型付きの観察フィールドを公開するゲームでは、左の Objects から対象を選び、右の Inspector で値と単位を確認できる。検索と Render nodes への切り替えも共通で使う。Capture observation は選択対象のフィールドも固定し、Live observation で現在値へ戻す。元の JSON は Raw observation JSON から参照できる。

## ゲーム側との契約

型は [`editor/studio/public/runtime.d.ts`](../../editor/studio/public/runtime.d.ts) と [`projects.d.ts`](../../editor/studio/public/projects.d.ts) に定義する。

`kagura.runtime.observe()` は `{ game, source, readonly: true, state }` または `null` を返す。`source` は `scene` / `game` / `ui` / `renderer` のいずれかで、データは元の状態から切り離した JSON とする。エディタ拡張は `observe()` を公開し、共通の読み取り処理は `runtime/observation.mjs` に置く。Agent の `runtime_observe` と WebMCP も同じ観察経路を使う。

ゲーム側の `kaguraSceneRuntime.observe()` は任意で追加できる。1 回の同期読み取りで `{ state, inspection: { scope, subjects } }` を返し、状態とフィールド一覧の整合性を保つ。`inspection` は省略でき、既存の `snapshot()` だけを持つゲームも引き続き観察できる。返却値は `RuntimeObservedPayload`、観察フィールドは `RuntimeObservedInspection` で定義する。

`subjects` はゲーム所有の ID・表示名・型付きフィールドで、観察経路ではすべてのフィールドに `access: "readonly"` を要求する。エディタは編集可能な記述、不正な型、重複 ID、上限を超えるデータを拒否する。状態とフィールド一覧を合わせて最大 4 MiB とし、`scope` は 1〜256 文字とする。`scope` はゲームが宣言するシーンなどの識別子で、変化すると選択を解除する。観察用のフィールドから書き込み用の session / revision トークンを生成しない。

Arena 3D は `player` と `prop:<body id>` を描画側の `subject` に明示的に対応させる。物理ボディの表示名とフィールドもゲームが決める。共通 UI や `kagura.graph()` はこの対応を読み、描画パスやオブジェクト名から ID を推測しない。

## フィールド単位の実行状態編集

全状態の checkpoint を実装していないゲームも、`kaguraSceneRuntime.fieldEditor` に `RuntimeFieldEditorAdapter` を公開すると、宣言したフィールドだけを編集できる。`read()` は `revision / scope / paused / subjects`、`pause(boolean)` は停止制御、`edit(edit, token)` は検証と同期コミットを担当する。観察用の `observe()` は引き続き読み取り専用とし、編集権限はこの別の API から得る。

Studio は Play ごとに新しい `session` を発行する。編集・Resume には現在の `session / revision / scope` が必要で、停止中かつすべて一致する場合だけゲームへ渡す。ゲーム側も停止・revision・scope・対象・フィールド・値を検証する。シミュレーション更新、停止・再開、シーン遷移、成功した編集で revision を進めるため、同じシーンへ戻った場合も古い操作を適用できない。

```js
const fields = kagura.runtime.fields;
const paused = fields.pause();
const moved = fields.edit(
  { subject: "player", field: "position.y", value: 4 },
  paused,
);
const launched = fields.edit(
  { subject: "player", field: "velocity.y", value: 6 },
  moved,
);
fields.resume(launched);
```

Arena 3D は Player と動的な箱・球に `position.x/y/z` と `velocity.x/y/z` を公開する。対象 ID は `player` またはゲームが宣言した `prop:<body id>` とし、床・壁や未公開のボディ ID には編集権限を与えない。Sleeping、Grounded、スコアなどの派生・進行情報は読み取り専用にする。

位置は各軸 ±10000 m、速度は各軸 ±1000 m/s の有限値に制限し、検証失敗時は状態・revision・履歴を変更しない。位置変更では現在の速度を、速度変更ではほかの軸を保持する。Player の編集では論理座標とカメラも同期する。箱・球の編集では Player の座標とカメラを保ち、足場の変化に合わせて接地を判定し直す。足場を移動した後に眠った物体が空中に残らないよう、箱・球の編集時は眠っている動的ボディを起こす。接触キャッシュを無効化し、再開後に物理計算を続ける。ほかのボディの位置・速度や、ソースの初期配置を置き換えない。

成功した操作は `kagura.runtime.fields.history()` と Changes に最大 100 件残す。この能力には全状態の復元・Undo・Step・checkpoint は含まれず、Arena 3D では Step / Checkpoint を無効にする。Capture observation 中は編集欄も読み取り専用にし、Live observation で編集へ戻す。

Agent と WebMCP は `runtime_fields_inspect / runtime_fields_pause / runtime_fields_edit / runtime_fields_resume` を使う。既存の全状態編集用 `runtime_inspect / runtime_pause / runtime_edit` は別の契約として維持する。

### 他のゲームのチューニング

| ゲーム | 編集値の範囲・整合性 |
| --- | --- |
| Survivor | HP は 1〜最大 HP、座標は Player の大きさを考慮したワールド内。ダメージ 1〜100、発射間隔 1〜600 ticks。座標変更時はカメラも追従 |
| Card Game | HP は 1〜最大 HP で冒険・戦闘の両方に同期。所持金 0〜99999、エネルギー 0〜99、防御 0〜999。演出中の編集と敵の手番の戦闘リソース編集を拒否 |
| Hack & Slash 3D | HP は整数の 1〜最大 HP、防御エネルギーは 0〜100。0 にしたときは防御状態も解除 |
| IRON YARD | HP は 1〜1000、ライフル cooldown は 0〜5 秒、ミサイルは 0〜10 秒。移動・敵・弾・ミッション進行を再生成しない |
| EMBERWING | HP は整数の 1〜6、熱量は 0〜1。1 で過熱、0.2 未満で解除し、中間値では現在の過熱状態を保つ |

これらは `engine/inspection` の `FieldControl` を共有する。更新の入口で `begin_update()` を呼び、停止中は入力・進行を処理しない。Pause / Resume の境界で入力と実時間の基準をリセットし、再開時の入力残りや時間の飛びを防ぐ。リセット時には同じ Control の `restart()` で世代と revision を進める。iframe の再作成では Studio の session も変わる。

IRON YARD の Studio の Play 操作も、プレビュー用リソースの保存を経由せずに実行する。Pause・値の編集・Resume を含め、配置文書とその Undo 履歴を変更しない。

エディタからの停止ではゲーム内のポーズメニューを新たに開かず、シーンをそのまま観察する。HUD の描画は続け、停止中に変更した HP などをゲーム画面にも反映する。通常のゲーム内メニューによる一時停止は従来どおり扱う。

ゲームの停止だけに対応する拡張は `pause / resume / paused` と任意の `canPause` を公開できる。状態置換や Step を公開しないゲームに、デバッガの書き込み操作を作らない。

共通の example 拡張は、ゲームの `kaguraSceneRuntime` にある `pause(boolean)` と `paused()` を `RuntimePauseAdapter` として接続する。ゲーム ID と API 版、両メソッドの存在を検証し、未対応のゲームでは Pause を無効にする。Arena 3D は更新処理の入口で停止し、物理・入力・カメラ・進行を固定する。GPU の描画処理は継続するため、停止中のシーンも表示できる。入力ヘルパーは停止・再開の境界で作り直す。

型付きの状態編集には、ゲーム所有の `kaguraDebugAdapter` と Inspector の `describe / reduce` が必要になる。ゲームは状態の検証と一括置換を担当し、セッション ID と revision で古い操作を拒否する。シーンツリー上の `subject` と Inspector の ID を対応させると、共通 UI で論理オブジェクトを選択できる。

Changes は成功した操作を最大 100 件保持する。Undo は停止中に行った直近の編集または状態置換を 1 回戻せる。Step、Resume、次の Pause で Undo を無効にし、シミュレーション全体の巻き戻しには使わない。状態と観察は最大 4 MiB、履歴に表示する文字列は最大 512 文字に制限する。

Play 中の Cmd/Ctrl+Z は実行状態の Undo を使う。Undo 未対応のゲームと実行中の Redo はステータスに理由を表示し、配置やソースの編集履歴を変更しない。Stop 後は通常の Undo / Redo に戻る。入力欄にフォーカスがある場合は、入力文字列の Undo を優先する。

実行状態の編集は MoonBit の初期定義やプロジェクト文書を変更しない。checkpoint は再現用の実行状態で、Save によるソース保存とは分ける。別エンジンや外部ゲームの内部状態を観察・編集する場合も、そのゲームが所有する同等の接続 API が必要になる。

既存の編集契約については [コードとエディタの契約](code-editor-contract.md)、起動と配布については [ゲームプロジェクト](game-projects.md) を参照する。
