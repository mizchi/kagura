# コードで動かし、実行状態を編集するゲームエディタ

ゲームコードから選択・プロパティ編集・保存先までの対応は [コードとエディタの契約](code-editor-contract.md) を基準に再設計しています。実装済みの範囲と次の移行段階を同文書に記載しています。

基本の開発ループは **MoonBit のコードで起動 → 任意の時点で Pause → 実行状態を変更 → Resume / Step** です。初期配置の大量の設定を前提にせず、生成済みオブジェクト・物理状態・進行状況を編集対象にします。状態の型と不変条件、初期化・更新・復元はゲーム側が所有し、エディタはその API に対する UI と AI 操作を提供します。

Arena 3D / FPS Demo は、ゲーム配下にシーンとコンポーネント定義を置き、Studio の共通編集機能を拡張する実装例です。Hack & Slash 3D は同じシーン文書からタイルマップへ変換する別アダプター、IRON YARD は独自の編集ビューを持つアダプターです。Flappy Bird はこの実行状態編集の最初の対応例です。従来の 2D 配置編集も、初期状態の fixture を作る補助機能として利用できます。他の examples は起動設定とリソースの読み込みまで対応しており、レベル配置の編集にはゲーム側のアダプター実装が必要です。

```text
examples/games/<game>/
  <game>.kgrprj
  game.mbt           # ゲーム状態・初期化・更新
  view.mbt           # 入れ子で宣言する描画シーン
  debug.mbt          # 論理状態の取得・検証・復元（任意）
  scenes/*.mbt        # 初期配置の fixture（現行のシーン読込用）
  scenes/project.mbt  # 単体起動で使うシーンの組み立て
  editor/scene.mjs     # ゲームが扱える型・制約・追加時の初期値
  editor/editor.mjs    # Studio の共通ペーンを組み立てる入口
  scene.mbt          # 検証済み定義をゲーム状態・描画へ適用
  scene_js.mbt       # 初期データ・実行状態 API のブラウザ境界
```

共通ペーン `editor/studio/scene/editor.mjs` は追加・削除・検証・出力・WebMCP ツールを提供します。コンポーネント定義はゲーム所有です。複雑な専用フォームや専用ビューが必要になったら、既存のプラグイン API で拡張します。汎用の Hierarchy / Inspector / Undo / リソース操作は本体に残ります。

## ファイル配置と読み込みの命名規約

`src/` は置きません。ゲーム用の MoonBit ソースと `moon.pkg` はプロジェクト直下です。機能別パッケージは `sim/`・`app/`・`headless/` など直下に並べます。IRON YARD はこの分割を維持し、ブラウザ入口を `app/` に指定しています。既存パッケージのインポート名は変えません。

| パス | 意味・読み込む側 |
| --- | --- |
| `<name>.kgrprj` | プロジェクト読込入口。ここからの相対パスを解決する。 |
| `moon.mod`, `moon.pkg`, `main.mbt` | MoonBit のモジュール・パッケージ・実行入口。`build.package` の既定は `.`。 |
| `view.mbt` | シーンの宣言。静的な親子関係を入れ子で表す。描画とヒエラルキーで共有する。 |
| `game.mbt`, `debug.mbt` | ゲームの更新と状態 codec。ファイル名だけでエディタから実行せず、MoonBit の型・関数から接続する。 |
| `scenes/<id>.mbt` | シーン宣言。`.kgrprj` の `scene` / `scenes` に列挙したものを読む。MoonBit シーンの `build.scenePackage` の既定は `scenes`。 |
| `scenes/project.mbt` | ゲーム側のシーン ID と構築関数の対応。遷移・生成はゲームコードが所有する。 |
| `editor/editor.mjs` | ゲーム固有編集拡張のソース入口。`editor/scene.mjs` などで型・制約を定義する。 |
| `editor/dist/extension.mjs` | 独立配布時の編集拡張バンドルの標準出力先。読込は `.kgrprj` の `editor.entry` で指定する。既存 IRON YARD の `editor/ui/dist/extension.mjs` も明示指定で使用する。 |
| `editor/dist/runtime.js` | ゲームのブラウザ用ビルド出力。`.kgrprj` の `runtime.entry` で指定する。ビルド元 JS の既定名は `<game>.js`。 |
| `editor/studio.json` | シーンアダプター未対応 example の起動設定。実行時のゲーム状態とは別。 |
| `assets/` | リソースの標準配置。読み込むものは `resources` に登録する。 |

規約によるビルド入口は `projects/settings.mjs` の `projectBuild()` が解決し、明示設定を優先します。`editor.entry` 未指定時は登録済みの `editor.id` から読み込みます。`editor/` 内の全 JS を自動実行したり、全 `.mbt` をシーンとして解釈したりしません。`build.package: "."` はビルド専用のルート指定で、リソースパスの `.` / `..` 許可には使いません。

Studio の一覧は 27 コード examples と 1 素材プロジェクトです。MoonBit は Studio / experimental / smoke も含めてフラット配置です。

宣言的なシーン構文とヒエラルキーの契約は [declarative-scenes.md](declarative-scenes.md) を参照してください。

## 実行状態のデバッグ契約

Flappy Bird を Play すると共通バーに **Pause / Resume / Step** が現れます。Pause はシミュレーションを停止し、Kagura の描画は継続します。右の **Runtime state** で JSON を編集して **Apply state**、左の **Scene hierarchy** は `view.mbt` から解決した描画シーンを表示します。モード、スコア、経過フレーム、鳥の現在 Y・速度、パイプ生成タイマー・生成済みパイプ、現在のレイアウトを変更できます。`layout.objects` 内の鳥の Y はリセット用の位置、`bird_y` は現在位置です。Step は入力なしでゲームの update を 1 回実行します。

契約は `editor/studio/public/runtime.d.ts`、DOM に依存しないセッション管理は `editor/studio/runtime/session.mjs` です。ゲームは `kaguraDebugAdapter` に `read / pause / step / replace` を公開します。JS の薄い境界から MoonBit の状態取得・検証・置換を呼び、同じロジックを native のヘッドレステストでも使用しています。Flappy Bird の実装は `debug.mbt` / `scene_js.mbt` にあります。ほかのゲームはこのアダプターを追加すると共通 UI を利用できます。Wasm / native の外部通信ブリッジは今後の対応です。

- `state` はゲームが定義する論理状態。GPU ハンドルやクロージャを汎用シリアライザーで復元しません。エンティティ参照・乱数状態・シーン遷移中の状態が必要なゲームは、それらもゲームの codec に含めます。
- 各 update とデバッガ操作で実行状態の `revision` を進め、Play ごとに新しい `session` を発行します。置換・Step・Resume は停止中かつ両方が一致する場合だけ許可します。古い Play の応答を新しい実行へ適用できません。
- ゲームは全状態を検証・コピーしてから一括置換します。不正値の一部適用や、初期化による速度・生成済みオブジェクトの消失を防ぎます。Flappy Bird はデバッガ境界で入力エッジを解放し、Step は neutral input を使います。入力・音声・GPU を含むプロセス全体の完全な巻き戻しではありません。
- UI と AI は `kagura.runtime.snapshot/pause/replace/step/resume` を共有します。WebMCP は `kagura.runtime_snapshot` / `runtime_pause` / `runtime_replace` / `runtime_step` / `runtime_resume`。置換は `{state, token: {session, revision}}` を渡し、ソース編集のトランザクションとは独立します。
- **Export checkpoint** は取得時点の状態を `.kgrstate` に出力します。停止中に **Import checkpoint** で読み、Apply で適用します。ゲーム ID と状態スキーマ版の不一致を拒否します。checkpoint は再現用データで、通常の **Save** による MoonBit ソース保存とは別です。

```js
const paused = kagura.runtime.pause();
const state = structuredClone(paused.state);
state.bird_y = 80;
state.velocity = -2;
const edited = kagura.runtime.replace(state, paused);
kagura.runtime.resume(edited);
```

初期宣言を編集できることはライブデバッグの必須条件にしません。任意の手続き的生成コードから得た状態も同じ契約で扱う方針です。現在のプロジェクト読込には既存のシーン文書を使っており、コードのエントリだけで開くプロジェクト、型からのフォーム生成、停止画面上のドラッグ編集、状態履歴・コードへの明示的な変更取り込みは今後の実装です。

## 初期状態の fixture も MoonBit で管理

新しいシーンの既定は `scenes/<name>.mbt` です。Studio 対象の 27 コード examples は `source` 指定を持たず、MoonBit のソースルートをプロジェクト直下に置きます。現在は Arena / FPS / Flappy Bird を移行済みで、Hack & Slash 3D / IRON YARD の既存 JSON シーンも引き続き読み書きできます。コード examples の拡張コード置き場は `editor/` に統一しています。

- 配置は `@scene_document.Document` / `Node` / `Action` の型付きレコード。ゲーム固有のコンポーネントは `resources` に載せる。
- エディタが管理する関数は `// kagura-scene:begin` と `// kagura-scene:end` で囲む。関数名を維持し、マーカー外の手書きコード・コメントは保存時に保持する。
- ブラウザはこの宣言のリテラル部分を読み取る。任意の MoonBit を評価したり逆変換したりはしない。管理領域内の関数呼び出し・条件分岐などは拒否する。例外は JSON の空オブジェクト・null の定数コンストラクターのみ。
- 実行時に生成する配置や振る舞いは `project.mbt` やゲームロジックに書く。ブラウザの編集ビューは管理対象の宣言を表示するため、手書きの生成処理を視覚化するにはゲーム固有アダプターを追加する。

単体起動はコンパイルされた宣言を使用し、Studio の Play は編集時点のデータを渡します。コンパイル結果とブラウザの読み取り結果が一致することをテストします。シーン ID の追加や開始 ID の変更時は、`.kgrprj` と `scenes/project.mbt` の一覧を合わせてください。この対応の自動生成はまだありません。

Save はプロジェクトが参照する形式で保存します。`.mbt` なら MoonBit、`.json` / `.kgrscene` なら JSON です。読み取り専用プロジェクトの Save も同形式のダウンロードになります。`Export JSON` は交換形式を出力し、Import はいずれも受け付けます。Import は宣言部分だけを取り込み、マーカー外のコードは現在のプロジェクトへコピーしません。JSON の二重の正本は作りません。MoonBit の管理領域が外部で変更された場合は競合を検出して保存を止めます（File System API の読み取りと書き込みをまたぐ原子的な競合検出ではありません）。

## プロジェクト設定

```json
{
  "format": "kagura.project",
  "version": 1,
  "id": "mizchi.kagura.examples.arena3d",
  "game": "arena3d",
  "name": "Arena 3D",
  "save": { "namespace": "mizchi.kagura.examples.arena3d", "version": 1 },
  "editor": { "id": "arena3d", "apiVersion": 1 },
  "sceneSchema": { "id": "arena3d.scene", "version": 1 },
  "runtime": {
    "kind": "script",
    "apiVersion": 1,
    "targets": ["js", "native"],
    "entry": "editor/dist/runtime.js"
  },
  "build": { "package": ".", "artifact": "arena3d.js", "scenePackage": "scenes" },
  "display": { "width": 640, "height": 480 },
  "entryScene": "training",
  "scenes": {
    "training": "scenes/training.mbt",
    "second": "scenes/second.mbt"
  },
  "resources": {}
}
```

`entryScene` は開始シーンの ID、`scenes` は ID とプロジェクト相対パスの対応です。旧 `scene` だけの設定も読めます。両形式を併記する場合、`scene` は開始シーンのパスと一致させます。未知の開始 ID、パスの重複、ディレクトリ外への参照を拒否します。読み込み後の `manifest.scene` は互換用に開始シーンのパスへ正規化します。

コード examples は上記の設定を明示します。素材専用の `examples/assets/model_assets` は汎用 editor と resources のみを持ち、game / runtime / build / save 設定は不要です。古いプロジェクトでは追加フィールドを省略でき、`resources.runtime` とカタログの画面サイズも互換用に読み取ります。`id` / `game` は対で指定し、省略時に表示名から永続 ID を生成しません。

- `id` はプロジェクトを識別する安定した ID、`game` はゲーム実装・シーンの起動設定と照合する ID です。表示名を変更しても ID は変更しません。
- `save.namespace` / `save.version` はセーブデータの保存領域と形式の版です。プロジェクトを複製して保存領域を分ける場合は namespace も変更します。今回の実装は設定の受け渡しまでで、セーブの読み書き・移行サービスはまだありません。
- `runtime.kind` は `script`（classic script 形式の `.js` entry を共通 iframe で実行）、`extension`（IRON YARD の専用拡張が起動）、`native`（Studio での Play は無効）。`targets` はゲームの `moon.pkg` が対応するターゲットです。Wasm の起動契約は未実装のため受け付けません。`runtime.apiVersion` は現在 1 のみ使用できます。
- `build.package` は MoonBit のビルド対象、`artifact` は `_build/js/release/build/` 内の生成 JS パス、`scenePackage` はシーン宣言の追加ビルド対象です。`just studio-examples-build [example...]` は script 型のこれらの設定を使い、生成物を `runtime.entry` へ配置して配布に含めます。IRON YARD の専用ビルドは既存の `just iron-yard-editor-build` が担当します。ブラウザはビルドコマンドを実行しません。
- `display.width` / `height` は共通 runtime の初期キャンバスサイズです。最終的なピクセル数は表示領域・DPR に従います。IRON YARD の専用 renderer は従来どおり viewport に追従します。固定描画解像度や表示モードの契約は別途追加します。
- `sceneSchema` は拡張が export する `{ id, version }` と完全一致させます。`editor.apiVersion`、ゲーム ID、runtime API も開く前に照合します。未対応版や runtime ファイルの欠落は現在のプロジェクトを切り替える前に拒否し、編集中の内容を維持します。自動移行や元ファイルの上書きは行いません。

ゲームには `globalThis.__kaguraProject` で ID・game・save・sceneSchema・display のスナップショットを渡します。共通 runtime は `kaguraExample.project` でも公開し、IRON YARD は編集・実行の両 iframe に渡します。プロジェクトのストレージハンドルは渡しません。Project ペーンでも設定を確認できます。公開型は `editor/studio/public/projects.d.ts`、共通検証は `projects/settings.mjs` にあります。

左上のロゴ横にある `Scene` セレクタ（操作名 `Project scene`） で切り替えます。編集内容はシーンごとに保持し、Undo/Redo は切り替え時に区切ります。書き込み可能なプロジェクトの Save は、開いたシーンの編集内容をすべて検証してから各ファイルへ保存します。複数ファイルをまたぐ原子的保存には未対応です。読み取り専用の Examples / フォルダ入力では、Save は現在のシーンだけをダウンロードします。未保存の内容はブラウザを閉じると失われます。

Play はエディタで選択したシーンから開始し、全シーンのスナップショットを渡します。未保存の変更も含みます。既定の開始シーンを変更する操作とは区別しています。全シーンのコンパイルと出口の参照検証を済ませてから実行します。ゲーム実行中の状態は編集中の文書へ書き戻しません。

起動時は汎用エディタを表示し、ゲーム拡張はプロジェクトを開いたときに読み込みます。ビューポートの `Edit / Play / Stop` は本体が所有し、拡張の `play()` / `stop()` / `playing()`（任意の `canPlay()`）へ委譲します。iframe 内の終了などは `notifyState()` で本体へ通知します。ゲーム固有の操作ボタンを共通ツールバーへ常駐させる必要はありません。

## 2D の編集 UI とゲームアダプター

2D examples 13 本は、3D の orbit / XYZ Inspector から独立した画面構成を使います。左に 2D Hierarchy、中央にスクリーン平面、右に X / Y / Width / Height / Color の Inspector を置きます。ドラッグ移動、右下ハンドルのリサイズ、ホイールズーム、中・右ドラッグのパン、Fit、100%、グリッドとスナップを提供します。ドラッグ中はローカルな仮表示だけを更新し、確定時に一回のトランザクションにします。Esc・pointercancel では取り消します。

配置は `kagura.scene2d` リソース（kind 同名、version 1）に置きます。左上原点・ピクセル単位・Y 下向きで、3D nodes の座標や units を読み替えません。共通の軸平行矩形は `game/scene2d` の `Document` / `Element` に対応し、JS の検証・編集は `editor/studio/scene2d/model.mjs`、公開型は `public/scene2d.d.ts` です。オブジェクトの意味と変更可能なフィールドはゲーム所有の profile が定義します。

Flappy Bird の初期配置 fixture は `scenes/training.mbt` が正本です。鳥の X / Y / 幅 / 高さ / 色、地面の Y / 高さ / 色を編集でき、地面の Y と高さは連動します。画面はゲーム固有の 320 × 240 px、鳥の大きさは最大 64 px、地面からはみ出す初期配置を拒否します。単体起動も同じ宣言を読み、Play では編集時点のコピーを渡します。ゲームは描画・衝突・リセット後の初期位置に配置とサイズを使います。パイプ生成や重力・ジャンプなどの振る舞いはゲームコードが所有します。

配置キャンバスと選択ハンドルは SVG で描画し、Play は既存の Kagura WebGPU runtime を使います。2D の構図編集を 3D レンダラーへ迂回させません。配置編集は `studio.scene2d` ペーンの `scene_read` / `object_edit` ツールからも操作でき、Undo / Save と同じ履歴・文書を使います。

他の 12 本は 2D 専用画面・起動設定・実ゲームのプレビューまで対応します。まだ配置アダプターがないため、実ゲームに反映されない仮オブジェクトを作る操作は提供しません。ゲームごとに `define2DEditor(profile)` と `kaguraSceneRuntime` の受け取り処理を追加して広げます。タイルマップ、スプライト画像・アニメーション、回転・階層は今後の拡張です。

## シーン遷移は game/ が所有する

- `game/scene2d`: ピクセル単位の 2D レイアウト契約。ゲーム固有の意味・制約はアダプターに置く。
- `game/scene_document`: エディタとゲームが共有する型付きシーン宣言。
- `game/scene_data`: 描画に依存しない Entity / Definition / Project、床の範囲・壁の衝突判定、検証済みのシーン集合。
- `game/scene_flow`: 現在のシーン、遷移要求のチケット、確定・取り消し、地面上の Portal 判定。
- `game/scene_manager`: 既存の Scene の更新・描画とフェード。遷移条件の判定とは別の責務。

Arena はプレイヤーが Portal に入ると `scene_flow` で遷移し、配置とゲーム内オブジェクトを再生成します。検証済みの小さなシーンを同期的に切り替えます。非同期アセットの読み込みでは `Flow.request` → 読込・検証 → `commit`、失敗時は `cancel` を使えます。古いチケットの確定は拒否されます。フェードや非同期ロードを今回の Arena に組み込んだわけではありません。

Arena / FPS の床面は Y=0、回転なし、キャラクターのサイズは固定です。床・壁の位置、サイズ、色は描画に反映します。開始位置とアイテム・敵・ターゲットもゲーム側が読み込みます。Arena の配置した敵は現在固定位置、収集したアイテムは消え、FPS のターゲットは同じ位置に再出現します。Arena / FPS の単体起動も `scenes/project.mbt` を使います。`GameState::new()` の旧初期値はテスト・ベンチマーク向けに残しています。

## 次に追加を提案する設定（未実装）

| 優先度 | 設定 | 今回見えた不足と責務 |
| --- | --- | --- |
| 高 | 状態デバッグの対応宣言 | runtime の状態スキーマ・対応操作・コードエントリのみの起動を定義する。現在は実行後のアダプターから能力を検出する。 |
| 高 | セーブの永続化・移行 | ID / namespace / version の設定は実装済み。`game/` の保存サービスでバージョン検証と移行を行い、失敗時に元データを保持する。 |
| 高 | Wasm 起動・独立プロジェクトのビルド | JS/native の対応宣言と JS ビルド入口は実装済み。Wasm の ABI・ロード方式を決める。examples カタログ外のプロジェクトにもビルド CLI を展開する。 |
| 高 | シーンの移行関数 | API / スキーマ版の照合は実装済み。ゲーム所有の純粋な移行関数とプレビュー・保存手順を定義する。現在は不一致を拒否する。 |
| 中 | `display` / `simulation` | 初期画面サイズは実装済み。画面比率・表示方式・固定更新 Hz を追加する。移動量は現在ゲームのフレーム単位定数。ゲーム固有の速度はコンポーネント等で持つ。 |
| 中 | `input` / `audio` / `render` の実行プロファイル | 現在は任意の query 文字列。型付きアクションマップ、音量、品質プリセットをゲームと共有し、端末ごとの上書きを分離する。 |
| 中 | アセットの論理 ID・インポート設定 | 現在は ID とパスだけ。モデル・テクスチャ・音声のインポート設定、生成物、キャッシュ用ハッシュを追加する。R2 等の接続資格情報はプロジェクトへ保存しない。 |
| 中 | 座標系と物理の初期設定 | 3D は meters / Y up / +Z、2D は pixels / Y down を実装済み。ピクセルと物理空間の換算・重力などはゲーム契約として追加する。 |

遷移条件、ロード中の挙動、シーンを越えて残るプレイヤーやセーブ状態、BGM の寿命は `game/` のゲームオブジェクトで実装する方針です。プロジェクト設定には開始 ID と利用可能なシーン・サービスの定義を置き、条件分岐そのものを JSON の独自言語に増やさないことを提案します。

```sh
just studio-examples-build arena3d fps_demo
just studio-scene-test
```

## Inspector の共通登録と配布ビルド

[game/inspection](../../game/inspection/README.md) の getter/setter 宣言と Runtime 登録を使う。Flappy Bird は共通 API に移行済み。`build.editorMode` は Studio がコンパイルするモード（debug / release、既定 release）。Flappy Bird / Arena は debug を指定し、配布用は別途 `moon build --release` する。登録の debug 限定化と配布物の除去検査は同 README を参照。
