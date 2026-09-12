# Kagura Studio

[コードとエディタの契約](../../docs/editor/code-editor-contract.md): 宣言した subject を Hierarchy で選択し、ゲーム所有の型付きフィールドを Inspector / AI から編集します。Flappy Bird の Bird が最初の対応例です。

シーンエディタの画面は汎用スロット（`hierarchy` / `resources` / `viewport` / `timeline` / `inspector` / `tools`）でできている。Luna の 3D 編集はそのデフォルト view。2D やゲーム拡張は `workspace.slot(id).adopt()` でスロットを埋める。CSS クラスを occupy して奪わない。`window.kagura.workspace.list()` / `active(id)` が同じ契約。

## 起動

Node.js 24+、pnpm、MoonBit、just が必要です。リポジトリのルートで:

```sh
just studio-install
just studio-dev
# http://127.0.0.1:5190
```

`studio-dev` は MoonBit を初回ビルドし、変更監視と Vite を起動します。
依存は独立した `moon.work` と固定バージョンで解決し、隣の luna.mbt / three-mbt のチェックアウトには依存しません。
ブラウザ向け UI は `mizchi/luna@0.25.0`、シーン生成は `mizchi/three@0.1.3` を使います。

```sh
just studio-check                  # MoonBit warning-free check + core tests
just studio-plugin-test            # JS / MoonBit / Wasm SDKと公開ライフサイクル
just studio-build                  # dist/ を生成
(cd editor/studio && pnpm exec playwright install chromium) # 初回のみ
just studio-e2e                    # ブラウザ操作とGLB出力を検証
just studio-ci                     # 上記のまとめ
```

## 操作

- Resourcesでbox / sphere / cylinder / groupを追加し、Hierarchyまたは3D上で選択。
- Inspectorで名前、親ID、位置、XYZ Euler回転、スケール、色を編集。親変更はローカル座標を維持します。
- 削除は子孫も含みます。演出対象が削除された場合は対象を空にし、Undoで両方復元します。
- ドラッグでカメラ回転、右ドラッグで移動、ホイールでズーム。Front / Side / Topで多方向を確認、Fで選択対象をフレーム。
- Action previewのTargetにノードIDを指定し、閃光・反動の長さと強さを編集。再生、一時停止、逆方向シークに対応。
- ペーン境界をドラッグして列幅と各列の上下の高さを調整。境界にフォーカスして矢印キーでも調整でき、ドラッグ中のEscで取り消せます。
- 全体は100vhに収まり、長い内容は各ペーン内でスクロールします。
- Scene / Action layoutは同じ編集状態を使い、配置のみ切り替えます。寸法はレイアウトごとにブラウザ内へ保存。
- Saveは現在の保存先（初期値はIndexedDB）へ非同期保存し、Export JSON / Import JSONは編集ドキュメントの持ち出し・復元。ImportはUndoできます。
- Export GLBは編集時の形状・階層・材質・座標を出力。プレビューの変位、グリッド、選択枠、カメラは含みません。
- Cmd/Ctrl+Z、Shift+Cmd/Ctrl+ZでUndo/Redo、Cmd/Ctrl+Sで保存。入力中のキー操作はフォームに委ねます。

保存は明示的です。画面下のSaved表示が完了の目印です。未保存の変更はリロードで消えます。Undo/Redoはセッション中の最大100トランザクションで、JSON保存には含めません。
GLBには演出定義を焼き込まないため、再編集用にはJSONも保存します。

## ヘッドレス実行

ブラウザ・DOM・GPUなしで、エディタ本体をNode.jsから動かせます。
UIと同じMoonBitの `Editor` が検証・トランザクション・選択・時刻・Undo/Redoを所有します。
描画・GLB書出・ブラウザのIndexedDBはこのモードでは使用しません。NodeからWorker用ストレージアダプターを使うこともできます。

ルートから、標準入力へ1行1リクエストのJSONを送ります。標準出力も1行1応答です。
`just studio-headless` は必要なヘッドレスパッケージだけをビルドします。

```sh
just studio-headless --help
just studio-headless --output edited.json < requests.jsonl > replies.jsonl
just studio-headless --document edited.json < requests.jsonl
```

`requests.jsonl` の例:

```jsonl
{"method":"snapshot"}
{"method":"dispatch","transaction":{"expectedRevision":0,"commands":[{"op":"node.rename","id":"hero","name":"Player"}]}}
{"method":"select","id":"hero"}
{"method":"seek","time":0.03}
{"method":"undo","expectedRevision":1}
{"method":"redo","expectedRevision":2}
```

対応メソッドは `snapshot / dispatch / undo / redo / select / seek / layout`。
CLIの初期ドキュメントは検証後にrevision 0・履歴なしで開始します。稼働中の読込は `document.replace` コマンドで行います。
Undo履歴はプロセス内に保持されます。空行は無視し、不正入力の後も次の行を処理します。
1件でも失敗すると終了コード1、全件成功なら0です。`--output` は全件成功時にだけ最終ドキュメントを一時ファイルから置換し、失敗した実行では既存ファイルを上書きしません。
CLIと画面は独立したセッションです。編集ファイルを介して受け渡します。

Nodeライブラリとしても使えます（先に `just studio-headless-test` などでビルド）:

```js
import { createHeadlessEditor } from './editor/studio/headless/index.mjs';
const editor = createHeadlessEditor(); // 引数に初期SceneDocumentも指定可能
const result = editor.dispatch({
  expectedRevision: editor.snapshot().revision,
  commands: [{ op: 'node.rename', id: 'hero', name: 'Player' }],
});
editor.seek(0.03);
console.log(result, editor.snapshot());
```

ブラウザの `window.kagura` と同じAPIに加え、CLIと同じ形式を受ける `request()` を公開します。
複数インスタンスと購読・購読解除に対応。[ヘッドレスの型](headless/index.d.mts)。
`just studio-headless-test` でNode実行とCLIの回帰テスト、`just studio-ci` でUIとの結果一致まで確認できます。

## AI操作

[API型定義](public/contract.d.ts) が公開コントラクトです。ブラウザでは `/contract.d.ts` でも取得できます。
`window.kagura` の編集APIはJSONだけを受け渡しし、ドキュメントにDOM・関数・レンダラーの型を持ち込みません。
自然言語の推論や外部LLMへの通信はエージェント側が担当します。Studio 内では Agent ペーンが `@mariozechner/pi-coding-agent` に接続し、同じ `snapshot` / `dispatch` / `runtime_*` / `select_scene` をツールとして呼びます。Terminal ペーンは Ghostty（`@gespenst/core`）で、開発サーバの `/studio-pty` に OS シェルを繋ぎます。

```js
const api = window.kagura;
const context = api.snapshot();
const result = api.dispatch({
  expectedRevision: context.revision,
  commands: [
    { op: 'node.add', id: 'prop.crate', name: 'Crate', asset: 'primitive.box' },
    { op: 'node.transform', id: 'prop.crate', position: [2, 0.5, 0],
      rotation: [0, 0.3, 0], scale: [1, 1, 1] },
  ],
});
if (!result.ok) console.log(result.error);
api.select('prop.crate');
api.undo(api.snapshot().revision);
const unsubscribe = api.subscribe(snapshot => console.log(snapshot));
unsubscribe();
```

Command consoleにも同じトランザクションJSONを貼り付けられます。Copy contextで版・選択・ドキュメント・時刻を取得します。
`capabilities()` で対応コマンド、プリミティブID、制限を取得できます。

- 各トランザクションは1〜100コマンド。途中失敗ならデータ、履歴、revisionを一切更新しません。
- 各コマンドの完了時点で参照が成立する必要があります。親を追加してから子を追加します。
- すべての編集とUndo/Redoでrevisionが増えます。古い版の操作は `conflict` を返すため、再取得して差分を再検討してください。
- 未知フィールド・欠落・型違い・不正な整数・重複ID・未知アセット・欠落参照・循環・不正な数値を拒否します。
- `select` / `seek` / レイアウトは作業コンテキストです。ドキュメント履歴には入りません。
- snapshotはコピー。購読には解除関数があります。編集コマンドにJavaScriptコードを渡す仕組みはありません。

## 構成

| 層 | 場所 | 責務 |
| --- | --- | --- |
| コントラクト | `core/contracts.mbt`, `public/contract.d.ts` | バージョン・単位・ノード・演出・入力検証 |
| 編集ロジック | `core/commands.mbt` | 入力を変更しないドキュメント遷移 |
| 状態・操作 | `core/session.mbt`, `editor.mbt` | 原子的コミット、版の競合、Undo/Redo、選択・時刻、共通リクエスト |
| Lunaビュー | `app/views.mbt`, `state.mbt` | コントローラ状態をSignalへ反映。UIも同じリクエストを発行 |
| ヘッドレス | `headless/` | Node向けエクスポート、JSONL CLI、ファイル保存 |
| threeアダプター | `app/scene.mbt`, `web/viewport.mjs` | MoonBitからシーン生成、カメラ・ピック・プレビュー・破棄 |
| レイアウト | `web/layout-state.mjs`, `layout.mjs`, `layout.css` | 寸法・制限とドラッグ操作、画面内配置、独立スクロール |
| ブラウザホスト | `web/main.mjs`, `api.mjs` | 永続化・ファイル・クリップボード・AIへのJSON境界 |

`core` はDOM、Luna、threeをimportしません。UIとレンダラーはこの契約の利用者です。
既存のkagura engineとは別moduleなので、エディタのUI依存が公開エンジンへ流れません。

## 持ち込んだ知見と次の接続

[設計・移植方針](../../docs/design/studio-authoring.md) を参照してください。
汎用シーンはプリミティブの配置・階層・材質と、単一ターゲットの閃光／反動プレビューに対応します。
IRON YARDは以下の専用シーン編集に対応し、modeling-playgroundのScene Studio v1 JSONを直接Importできます。
汎用GLB読込、人体・IK・モーション編集、音声合成、複数アクション、Transformギズモ、任意ペーン分割、既存modeling3d/effect-studioドキュメントとの変換は未実装です。
2000ノードの上限は入力制限であり、大規模シーンの性能保証ではありません。

## プロジェクトとゲーム固有の拡張

### 既存examplesを開く

ヘッダの **Examples…** からゲーム・2Dデモ・3Dデモ・素材集の28プロジェクトを選択できます（一覧は [catalog.json](../../examples/catalog.json)）。`hacknslash_3d` も含みます。各exampleの直下に `.kgrprj` を置いているので、**Open project** でそのフォルダを選ぶこともできます。同梱版は読み取り専用で、Saveはプロジェクトのシーン形式（MoonBit / JSON）で書き出します。ローカルフォルダ版は `.kgrprj` が指定するシーンファイルに保存します。

```sh
just studio-dev                         # 全exampleをビルドして起動
just studio-examples-build flappy_bird   # 変更したexampleだけ再ビルド
```

**Example設定** で起動パラメーターを編集し、**Play** で実際のKagura/WebGPUランタイムを開始します。停止・プロジェクト切替時はiframeごと破棄し、GPU・音声・入力の寿命を終了します。ローカルフォルダでは `editor/dist/runtime.js` と同じフォルダ配下のアセットを読み込みます。コードを変更した場合は再ビルド後に「拡張を再読込」、設定変更だけなら再Playで反映します。実行中の状態は編集用JSONへ書き戻しません。

共通拡張 `kagura.example` は本体の汎用エディタに設定ペーンを追加します。起動設定は `kagura.example` resourceに保存し、Undo/Redo・ヘッドレス・宣言的WebMCPツール `kagura.pane.studio.example.launch_read/launch_update` が同じトランザクションを使います。`hacknslash_3d` は実装済みのURLパラメーター（ミュート・自動操作・Profiler・FXAA・影・SSAO）をフォームでも操作できます。他のキーは各ゲームが読み取るものだけが有効です。

IRON YARDは専用シーンエディタ、H&S 3Dは以下の共有シーン定義を使います。その他のexamplesはMoonBitコードでレベルを定義しており、ゲーム固有の配置・バランス編集は `editor.entry` で拡張します。IK・PBR・Terrainの3件はnative専用のため、プロジェクト読込・ソース参照はできますがブラウザ試遊は無効です。`experimental` と `smoke` は一覧に含めていません。

### ゲームと共有するシーン定義

`hacknslash_3d` は [training.kgrscene](../../examples/games/hacknslash_3d/scenes/training.kgrscene) を実際のレベル定義として読み込みます。Examplesから開くとHierarchyに床・壁・開始位置・敵が現れ、InspectorでX/Z位置や大きさを変更できます。**Game scene** ペーンでは床・壁・敵の追加／削除と敵の種類・HPを編集できます。**Play** は編集時点のコピーからゲームを起動し、変更した配置を描画・衝突判定・敵生成へ反映します。起動後のゲーム状態は編集データを変更しません。

`.kgrscene` は既存のSceneDocument v1と同じJSONです。位置・回転・スケールは `nodes` に置き、resource `kagura.scene` の `data: {game, bindings}` で各ノードへゲームの意味を割り当てます。bindingは `{node, component, properties}` です。共通の参照検証は [scene/contract.mjs](scene/contract.mjs)、型は [scene.d.ts](public/scene.d.ts)、ゲーム固有の検証・ランタイムへの変換は [hacknslash_3d/editor/scene.mjs](../../examples/games/hacknslash_3d/editor/scene.mjs) が担当します。他のゲームも同じ契約に独自コンポーネントと変換処理を追加できます。

H&S 3Dでは1mを1タイルとし、床の領域をくり抜いてから壁を配置します。X/Zの辺は整数、回転は0、ルート直下の配置に対応しています。Y・色・プリミティブ形状は配置用マーカーで、床・壁の材質と敵モデルはゲームのKaguraレンダラーが決めます。壁と重なる開始位置・敵、不正な参照や未対応の変形はPlay／プロジェクト保存前に拒否します。自由配置のメッシュシーンへ拡張する場合は、ゲーム側の描画と物理の変換も合わせて実装します。

ローカルの `.kgrprj` は `scene: "scenes/training.kgrscene"` を指定します。フォルダをOpen projectで開いた場合、Saveはこのファイルに保存します。同梱exampleではSaveでJSONを書き出し、Import JSONから `.json` / `.kgrscene` を再読込できます。シーンはリセット時にも維持し、敵を全滅させても自動生成フロアへ切り替えません。

ヘッドレスでも同じ定義から実際のMoonBitゲームを作れます。

```js
import { readFile } from 'node:fs/promises';
import { createSceneRuntime } from './examples/games/hacknslash_3d/editor/headless.mjs';
const document = JSON.parse(await readFile('examples/games/hacknslash_3d/scenes/training.kgrscene', 'utf8'));
const game = createSceneRuntime(document);
game.blocked(20.5, 20.5); // 実際のゲームと同じ衝突判定
game.step(1, 0);
game.snapshot();
```

事前に `just studio-examples-build hacknslash_3d` でブラウザ版とヘッドレスAPIをビルドします。

### プロジェクトファイルの形式

汎用のシーン編集・履歴・保存・ペーン・WebMCPはStudio本体に組み込みます。ゲーム側は専用フォームや編集モードを追加し、ゲーム実装と一緒に開発します。拡張は標準ドキュメント操作を引き継ぐので、専用ペーンを一つ追加するだけでも構いません。IRON YARDの拡張は `examples/games/iron_yard/editor/ui/` にあり、Studio本体はゲーム固有のフィールドや描画処理を持ちません。現在、汎用プリミティブのビューは既存のThree基盤、IRON YARDの編集・試遊はKaguraで描画します。

**Open project** で `<name>.kgrprj` を含むフォルダを選択します。同じフォルダに複数ある場合はプロジェクトファイルを選べます。ファイル単体の選択では兄弟ファイルへアクセスできないため、ブラウザではフォルダ単位で開きます。JSON v1の例:

```json
{
  "format": "kagura.project",
  "version": 1,
  "name": "My game",
  "scene": "scenes/main.json",
  "resources": { "map": "assets/map.json" },
  "editor": { "id": "my-game", "entry": "editor/extension.mjs" }
}
```

`editor` を省略すると本体の汎用エディタで開きます。この場合の `scene` はStudioのSceneDocumentです。ゲーム独自形式は拡張の `validateDocument` で検証します。`entry` を省略した登録済みIDは同梱拡張を使い、指定した場合はプロジェクト内のES moduleを読み込みます。プロトタイプのentryは依存を一つにまとめた `.mjs` とします。JS、MoonBit/JS、Wasmアダプターを組み合わせ、ホストと同じ権限で動く自作の拡張コードとして扱います。

パスはすべて `.kgrprj` のあるディレクトリを基準とします。絶対パス・URL・`..` による親ディレクトリ参照は拒否します。拡張には `project.read(path)` / `resource(id)` / `url(path)` / `list()` を渡し、配下のリソースを読めます。Projectペーンからファイルをダウンロードできます。生成キャッシュ（`_build`, `.mooncakes`, `node_modules`, `.git`）は一覧から省きますが、明示したパスは読み込めます。

フォルダへの書込み権限があれば **Save** はmanifestの `scene` ファイルへ書き戻します。File System Access非対応環境のフォルダアップロードは読み取り専用で、Saveはシーンを書き出します。manifestと拡張コードは自動で書き換えません。フォルダ権限はこのセッションで保持し、ページ再読込後はプロジェクトを開き直してください。IndexedDBへの通常保存とプロジェクトフォルダ保存は別の保存先です。

**拡張を再読込** はフォルダ内で更新したbundleとリソースを読み直し、現在の未保存シーンを引き継ぎます。API不一致・不正シーン・欠落リソースは現在の拡張を破棄する前に拒否します。切替時は専用ビュー・音声・ツール・Object URLを解放します。拡張自身の `activate` / `dispose` はリソースを確実に片付ける必要があります。

ペーンだけ追加する最小の `editor/extension.mjs`:

```js
export const apiVersion = 1;
export const id = 'my-game';
export function activate({ panes, base }) {
  panes.register({
    id: 'my-game.tuning', title: 'Game tuning',
    mount({ element, editor }) {
      const text = document.createElement('p');
      text.textContent = `Editing: ${base.readDocument().name}`;
      element.append(text);
      // editor.dispatch(...) で標準の履歴に参加する。
      // panes.registerPlugin(...) なら既存の宣言的WebMCPツールも提供できる。
    },
  });
  panes.open('my-game.tuning');
  return { dispose() { panes.unregister('my-game.tuning'); } };
}
```

[拡張API型](public/projects.d.ts)と[IRON YARDプロジェクト](../../examples/games/iron_yard/iron-yard.kgrprj)を参照。`just iron-yard-editor-build` または `just studio-build` でゲーム側のbundleを生成した後、`examples/games/iron_yard/` をOpen projectで選択できます。IRON YARDでは同フォルダの変換済みモデルJSON・環境反射・音声を、編集ビューと試遊の両方へ渡します。

## カスタムペーン

### IRON YARD

**Examples → IRON YARD** または `.kgrprj` の読み込みで専用拡張を開き、modeling-playgroundの `scene-editor.html` に相当するシーン編集を開きます。実際のSTRIX / BASTIONモデルを表示し、Hierarchyまたは3Dビューから選択できます。

- 建物の位置・サイズ・色・種類、敵の位置・向き、出撃地点をInspectorで編集。コンテナ・敵の追加と削除、波ごとの敵配置に対応します。
- シーン名、制限時間、カメラFOV、空の色、太陽の強さを編集できます。
- Actionではライフルの間隔・ダメージ・閃光・反動・発射音・命中音を編集します。MoonBitの戦闘処理で一発を再生し、命中・残りHPを確認できます。シークは無音で、巻き戻し時は初期状態から再計算します。
- 移植元と同じv1シーンJSONをImport / Exportできます。入力は元の契約に従って検証し、建物に埋まる出撃地点、不正な参照や数値などは変更前に拒否します。

編集内容は `iron-yard.scene` リソースの単一ドキュメントとして管理し、通常の **Save / Undo / Redo** に対応します。SaveはStudio全体を保存し、IRON YARD編集中のExport JSONは移植元互換のシーンJSONを書き出します。全体ImportはStudio JSONとIRON YARDシーンJSONを識別します。契約・初期シーン・編集操作は `examples/games/iron_yard/editor/scene/` に同梱し、隣のcheckoutを実行時に参照しません。

**Play / 試遊する** は現在のドキュメントのコピーでゲームを起動します。変更した建物は描画と当たり判定、敵と波はミッション、ライフル設定は戦闘と演出へ反映されます。試遊モードは敵AIとの交戦と訓練を選べます。WASD・右ドラッグ・Space・Shiftで操作し、Escで停止。親ペーンまたはゲームの停止メニューの **編集に戻る** で編集を再開します。実行中の機体位置や戦闘状態は編集ドキュメントを変更しません。

IRON YARDの編集ビューと試遊は同じKagura WebGPU / WGSLを使用し、モデル・材質・照明・影・地面を共有します。左ドラッグで回転、右ドラッグまたはShiftで移動、ホイールで拡縮、クリックでエンティティの境界を選択します。試遊中は編集ビューの描画を停止し、試遊を閉じるとゲームのiframeを破棄して入力・音声・GPUの実行環境を終了します。上部の **汎用エディタ** または専用ペーンの **Close IRON YARD** で本体の汎用シーンへ戻ります。拡張ツールと編集内容は残ります。既存のペーン境界のリサイズ・独立スクロールと100vhのレイアウトを維持します。

プラグインは起動時に登録され、ペーンを閉じていてもWebMCPから操作できます。変更ツールには `expectedRevision` が必要です。

| ツール（接頭辞 `kagura.pane.iron-yard.`） | 動作 |
| --- | --- |
| `scene_load` / `scene_export` | 移植元互換ドキュメントの読込・取得 |
| `scene_edit` | 建物・敵・spawn・scene・actionを検証して原子的に編集 |
| `scene_add` / `scene_remove` | コンテナ・指定波の敵の追加、エンティティ削除 |
| `attack_preview` | 指定時刻の攻撃をMoonBitで再計算。DOM / GPU不要 |
| `inspect` | 保存シーン・設定とブラウザプレビュー状態を取得 |
| `configure` | 試遊モードと旧出撃設定を保存。シーンがある場合の座標編集は `scene_edit` を使用 |
| `preview` | `play / pause / reset` を要求。ヘッドレスホストは要求を記録 |
| `simulate` | 保存シーンで60Hz・最大600フレームの独立シミュレーション。DOM / GPU不要 |

Nodeでも同じプラグインを使用できます（先に `just studio-headless-test` でビルド）。

```js
import { createHeadlessEditor } from './editor/studio/headless/index.mjs';
import { createPluginHost } from './editor/studio/plugins/host.mjs';
import { createIronYardPlugin } from './editor/studio/games/iron-yard.mjs';
import { defaultScene } from './editor/studio/games/iron-yard-scene.mjs';
const editor = createHeadlessEditor();
const plugins = createPluginHost(editor);
plugins.register(createIronYardPlugin());
const edit = (tool, args) => plugins.invoke('iron-yard', tool, args, {
  expectedRevision: editor.snapshot().revision,
});
await edit('scene_load', { document: defaultScene() });
await edit('scene_edit', {
  id: 'hangar-a', changes: { center: [-30, 7, -15], color: '#ffcc00' },
});
console.log(await plugins.invoke('iron-yard', 'simulate', {
  frames: 120, forward: 1, boost: true,
}));
console.log(await plugins.invoke('iron-yard', 'scene_export', {}));
plugins.dispose();
```

`just studio-dev` / `just studio-build` はゲームとアセットもビルドします。別途5192番のサーバーは不要です。配布用 `dist/games/iron-yard/` に同梱され、静的ホスティングやWorkerから同じパスで配信できます。ゲームソース変更後は `(cd editor/studio && pnpm build:games)` で同梱版を更新して開き直します。editorの変更監視とは独立しています。[型定義](public/games.d.ts)、[シーン操作](games/iron-yard-scene.mjs)。

`just studio-e2e` はヘッドレスのSwiftShaderでゲーム統合も検証します。macOSでは `STUDIO_GPU=metal just studio-e2e` でインストール済みChromeのMetal描画も確認できます（こちらもヘッドレス）。

### フォームと任意プラグイン

右下の **New pane → Pane builder** でJSON定義を編集し **Create pane** を押すと、再ビルドせずゲーム固有フォームを作れます。テキスト・数値・真偽値・選択肢に対応します。タブでConsoleと切り替え、Close paneで表示を閉じます。ペーン領域は既存の境界ドラッグでリサイズでき、内容だけがスクロールします。

```js
kagura.panes.registerForm({
  id: 'combat.settings', gameId: 'my-game', title: 'Combat settings',
  fields: [
    { key: 'damage', label: 'Damage', type: 'number', min: 0, max: 999 },
    { key: 'enabled', label: 'Enabled', type: 'boolean' },
  ],
  values: { damage: 10, enabled: true },
});
kagura.panes.open('form.combat.settings');
```

定義と値は `document.resources` の `{id, kind:'kagura.form-pane', version:1, data:定義}` に保存されます。フォーム作成・値変更も通常のUndo/Redo、Save、JSON export/importの対象です。Save後の再読み込みではタブも復元されます。`registerForm` は同じIDを更新します。削除は `resource.remove` コマンドで行い、Close paneではデータを消しません。ゲーム識別子はフォームの `gameId` とリソースIDで管理します。

自由なUIは同期 `mount` を持つプラグインとして登録できます。

```js
kagura.panes.register({
  id: 'my-game.debug', title: 'Game debug',
  mount({ element, editor, subscribe, signal }) {
    const output = document.createElement('pre');
    element.append(output);
    const render = snapshot => { output.textContent = JSON.stringify(snapshot.document.resources, null, 2); };
    render(editor.snapshot());
    subscribe(render);
    // eventListener/fetchにはsignalを渡す。タイマー等の解放関数をreturnできる。
  },
});
kagura.panes.open('my-game.debug');
```

`register` は同じIDを差し替えます。非表示・差し替え・登録解除時に購読解除、AbortSignalのabort、返された破棄関数の実行を行い、再表示時にmountし直します。状態はドキュメントに置きます。任意プラグインは信頼するローカルコードとしてエディタと同じ権限で動き、JS関数自体はシーンに保存しません。実例は [game-tools.mjs](public/plugins/game-tools.mjs) にあり、ブラウザの開発者コンソールから次で読み込めます。

```js
const { install } = await import('/plugins/game-tools.mjs');
const uninstall = install(kagura);
```

ヘッドレスではUIをmountせず、同じ `resource.put` / `resource.remove` コマンドで値やフォーム定義を編集できます。リソースの形、ID、版、サイズ、深さはMoonBitコアで検証します。汎用JSONリソースのゲーム固有ルールはゲーム側アダプターの責務です。フォームの型・値域の検証はフォームAPIで行い、直接コマンドで不正なフォーム値を入れた場合はUIにエラーを表示します。

フォーム部品のMoonBitパッケージ名は **`mizchi/luna_components`** です（`mizchi/luna/components` ではありません）。今回の真偽値フィールドは `headless.use_switch_computed` を `luna/dom/client` で描画し、キーボード操作・ARIAとSignalへの更新を利用しています。他の基本フィールドはDOMアダプター側の標準フォーム要素です。Luna製の独自UIも同じmount/dispose境界へ接続できます。

## WebMCP

カスタムペーン自身のツールは `panes.registerPlugin()` で宣言できます。`manifest` に入出力Schemaと `read` / `transaction` を定義し、`invoke` は結果と編集コマンドを返します。親が検証・Undo可能なcommit・WebMCPへの公開を担当します。

```js
const { install } = await import('/plugins/js-demo.mjs');
const uninstall = install(kagura);
await kagura.webmcp.settled();
// kagura.pane.demo.js.set_damage が公開される。
```

JSの `defineJSPlugin`、MoonBit JS用の `fromJSONModule`、wasm32用の `fromWasm` は同じJSON契約へ接続します。画面のmountは任意で、省略するとツール実行用ペーンを生成します。閉じてもツールは残り、登録解除・差し替え時に進行中の処理も取り消します。NodeでもDOMなしで実行できます。

[プラグインAPI設計・各言語の実装例](../../docs/design/pane-plugin-api.md)、[公開型](public/plugins.d.ts)、[Node/ブラウザ共通SDK](plugins/index.mjs) を参照してください。Wasmは線形メモリABIで、MoonBitのWasmGC出力への直接対応は含みません。

ブラウザ内では `document.modelContext.registerTool()` に以下のツールを自動登録します。UI・ヘッドレスと同じ編集コアを呼び、AIによる操作も即座に画面へ反映されます。

| ツール | 操作 |
| --- | --- |
| `kagura.snapshot` | ドキュメント・revision・選択・プレビュー・対応コマンドの取得 |
| `kagura.dispatch` | シーン、演出、ゲームリソースの原子的編集 |
| `kagura.history` | Undo / Redo |
| `kagura.select` / `kagura.seek` | 選択と時刻 |
| `kagura.panes_list` | 利用可能なペーン一覧 |
| `kagura.panes_open` / `kagura.panes_close` | ペーン切り替え |
| `kagura.panes_create_form` | ゲーム固有フォームの作成・更新 |
| `kagura.storage_list` | 接続済みストレージのリソース一覧 |
| `kagura.storage_save` / `kagura.storage_load` | シーンの保存・読込 |
| `kagura.storage_download` | 任意リソースのダウンロード |

`dispatch`・`history`・`panes_create_form`・`storage_save`・`storage_load` は `expectedRevision` が必須です。競合時はsnapshotを取り直します。入力JSON Schemaは [tool-schemas.mjs](web/tool-schemas.mjs)、登録と実行のアダプターは [webmcp.mjs](web/webmcp.mjs) に分離しています。作成したフォームも通常のresourceコマンドで編集できます。

ローカルではChromeの `chrome://flags/#enable-webmcp-testing` を有効にして再起動します。WebMCPは開発中のAPIで、HTTPSまたはlocalhostと対応ブラウザが必要です。利用可否はConsole内の表示、または `kagura.webmcp.status()` で確認できます。未対応時も通常の編集APIとヘッドレスは使えます。

```js
await kagura.webmcp.ready;
const tools = await document.modelContext.getTools();
const tool = tools.find(t => t.name === 'kagura.snapshot');
// Chromium 153では引数はJSON文字列。新しい仕様案ではオブジェクトへ移行中。
const result = await document.modelContext.executeTool(tool, '{}');
console.log(JSON.parse(result));
```

ツールは開いているページのライフサイクルに結び付け、HMR終了時や登録途中の失敗時にはAbortSignalでこのエディタの登録を解除します。編集操作はメモリ上に反映され、永続化はSaveまたはstorage_saveで行います。外部MCPサーバーやブラウザエージェント自体の実装は含みません。

`just studio-ci` は実際のChromium WebMCPを有効にして、ツール検出・実行・UI反映・競合拒否・フォーム作成・Undo・登録解除まで確認します。仕様とChromiumの過渡的な引数形式の差はE2Eの呼び出し側で扱います。

参考: [Chrome: WebMCPとMCPの使い分け](https://developer.chrome.com/docs/ai/webmcp/compare-mcp?hl=ja)、[命令型API](https://developer.chrome.com/docs/ai/webmcp/imperative-api?hl=ja)、[ローカルでの有効化](https://developer.chrome.com/docs/ai/webmcp)、[WebMCP仕様案](https://webmachinelearning.github.io/webmcp/)（2026-09-10確認）。

## ストレージとリソース取得

**Resources → Browse storage** からStorageペーンを開けます。IndexedDB、ユーザーが選んだフォルダー、Worker経由のR2に対して、一覧・ファイル追加・シーン保存／読込・任意ファイルのダウンロードができます。Resource URLにはHTTP(S)やS3/R2の署名付きGET URLも指定できます（配信元のCORS設定が必要）。

公開契約は [storage.d.ts](public/storage.d.ts)、Node/ブラウザ共通の入口は [storage/index.mjs](storage/index.mjs) です。

| 保存先 | 接続 | 同時書き込み |
| --- | --- | --- |
| IndexedDB | 初期登録済みの `indexeddb` | トランザクション内でETagを検証 |
| File System API | Open folder、または取得済みDirectoryHandle | OS側の編集を含む原子的な競合検出は非対応 |
| R2 / Worker HTTP | Worker endpointとセッショントークンを指定 | R2の条件付きputを使用 |
| HTTP(S) URL | `{url}` を指定して取得・コピー・ダウンロード | 読み取り専用。ブラウザから直接取得 |

保存対象はJSONに限定せず、`Blob`とMIME typeで扱います。取得場所は `{store, key}` とし、シーン内のゲームリソースには例えば `data: {source: {store:'r2-1', key:'game/model.glb'}}` のように参照を持たせられます。接続IDと保存先の対応はホスト側で登録します。ゲームの型付きアセット読込・threeへの変換は別のアダプターの責務です。

```js
const storage = kagura.storage;
const ref = { store: 'indexeddb', key: 'game/mesh.glb' };
await storage.write(ref, new Blob([bytes], { type: 'model/gltf-binary' }), { ifMatch: null });
await storage.download(ref, 'mesh.glb');
await storage.download({ url: 'https://assets.example.com/mesh.glb' });
const page = await storage.list('indexeddb', { prefix: 'game/', limit: 100 });
// page.cursorがあれば、次回のlistにそのまま渡す。
```

`write` の `ifMatch` は未指定で上書き、`null`で新規作成のみ、ETag文字列でその版のみ更新します。File Systemは条件付きwriteを拒否します。シーンの `save` は最後にload/saveしたETagを自動で使い、未読の既存データを上書きしません。保存先に既存シーンがあれば先にLoad sceneで読み込みます。シーンの読み込みは、取得中に編集が進んだ場合も `conflict` となり、現在のシーンを保持します。

標準保存先は `indexeddb / scenes/default.kagura.json`。旧localStorageの保存は、IndexedDBへのコミット成功後に移行します。フォルダーとR2の接続はセッション単位で、トークンをシーンやlocalStorageへ保存しません。再起動では標準保存先を読み込み、外部ストレージは再接続してLoad sceneで開きます。

実装上の上限は書き込みとHTTP取得が1オブジェクト64 MiB、シーンJSONの読み込みが4 MiBです。現在はBlob単位で処理し、マルチパートアップロードや無制限サイズのストリーミングは未実装です。File Systemの一覧は選択ディレクトリを走査するため、大規模アセットDB用の索引ではありません。

### Cloudflare Worker / R2

```sh
# リポジトリのルートから。開発用トークンを設定する。
cp editor/studio/worker/.dev.vars.example editor/studio/worker/.dev.vars
just studio-worker-dev
# http://localhost:8787 でエディタと /api/storage/objects を提供。
# StorageのWorker tokenに .dev.vars の値を入力してConnect R2。
```

`studio-worker-dev` はローカルR2を使い、本番バケットへアクセスしません。通常のVite開発画面から接続する場合はendpointを `http://localhost:8787/api/storage/objects` とします。

Workerは静的エディタ配信とR2リソースAPIを持ちます。[wrangler.jsonc](worker/wrangler.jsonc) の `RESOURCES` がバケットbinding、`ASSETS` がUI配信です。全リソースAPIは `STORAGE_TOKEN` によるBearer認証を要求し、未設定なら拒否します。CORSは同一オリジンと `ALLOWED_ORIGINS` の明示的なオリジンのみ許可します。現段階では一つの共有ワークスペース向けで、ユーザー別の認可やテナント分離は含みません。

本番へ接続する際はバケット名、Worker secretの `STORAGE_TOKEN`、許可オリジンを設定します。S3署名処理やR2の資格情報はサーバー側に置く設計です。今回のサーバー実装はR2 bindingを使用し、AWS S3の署名付きアップロード生成は含みません。共通HTTP契約を保てばサーバー側の保存先を差し替えられます。

```sh
just studio-storage-test  # Nodeの保存競合と、実workerd/R2での契約テスト
just studio-worker-check # アップロードしないWorkerビルド検証
just studio-ci           # 型・MoonBit・Node・Playwright・Worker dry-run
```

### NodeからR2へ接続

```js
import { createHeadlessEditor } from './editor/studio/headless/index.mjs';
import { createStorageRegistry, createDocumentStorage, createWorkerStore } from './editor/studio/storage/index.mjs';
const editor = createHeadlessEditor();
const storage = createStorageRegistry();
storage.register('r2', createWorkerStore({
  endpoint: 'https://your-worker.example/api/storage/objects',
  getToken: () => process.env.KAGURA_STORAGE_TOKEN,
}));
const documents = createDocumentStorage(editor, storage);
await documents.load({ store: 'r2', key: 'game/scene.json' }, editor.snapshot().revision);
// 通常のeditor.dispatch(...)で編集
await documents.save({ store: 'r2', key: 'game/scene.json' }, editor.snapshot().revision);
```

参考: [R2 Worker API](https://developers.cloudflare.com/r2/api/workers/workers-api-reference/)、[静的アセットのbinding](https://developers.cloudflare.com/workers/static-assets/binding/)、[File System API](https://developer.mozilla.org/en-US/docs/Web/API/File_System_API)、[IndexedDB](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API/Using_IndexedDB)（2026-09-10確認）。

### ゲームごとのシーンと複数シーンのプロジェクト

Arena 3D / FPS Demo はゲーム所有のコンポーネント定義から共通ペーンを組み立て、Kagura のゲーム実行へ配置・色・衝突形状を渡します。Arena は出口オブジェクトで次のシーンへ遷移します。左上のロゴ横にある `Scene` セレクタ（操作名 `Project scene`） で `.kgrprj` の `scenes` を切り替えられます。

実装パターン、現在の制約、未実装のプロジェクト設定の提案は [ゲームプロジェクト設計](../../docs/editor/game-projects.md) を参照してください。

### MoonBit を正本にするシーン

Arena / FPS は `scenes/*.mbt` を既定のシーン定義として使います。`@scene_document.Document` の型付き宣言を MoonBit がコンパイルし、エディタは同じ宣言をリテラルとして読み書きします。Save は `.mbt` を保持し、手書きコードは管理マーカーの外に残せます。任意のコードをエディタで逆変換する機能ではありません。単体起動もこの定義を読みます。JSON は交換・既存プロジェクト互換用です。

全 examples の拡張コードは `editor/`、IRON YARD の専用 UI は `editor/ui/` にあります。詳しくは [シーンの正本は MoonBit](../../docs/editor/game-projects.md#シーンの正本は-moonbit) を参照してください。

### 共通のプロジェクト操作

起動時は汎用エディタだけを読み込みます。ゲーム固有の拡張・ペーン・WebMCP ツールはプロジェクトを開いた時点で読み込みます。

ビューポート上部の **Edit / Play / Stop** は Studio 本体が所有します。Edit は試遊を終了して現在のプロジェクトの編集へ戻り、Play はそのゲームを起動、Stop は実行用 iframe を破棄します。native 専用や実行機能のないプロジェクトは Play が無効です。Action preview の再生は個別アクション確認用として独立しています。

拡張は `GameEditor` の `play()` / `stop()` / `playing()` を提供し、利用可否を変える場合は `canPlay()` を返します。ゲーム内から終了するなど状態が変わった場合は `GameEditorContext.notifyState()` で本体に通知します。IRON YARD と共通 examples 拡張はいずれもこの API を使います。

### コードから起動し、停止中の実行状態を編集する

**Examples → Flappy Bird → Play → Pause** で実行中の状態を編集できます。**Runtime state** の JSON を変更して **Apply state**、**Step** で入力なしの 1 フレーム実行、**Resume** でその状態から再開します。鳥の現在位置 `bird_y`・速度 `velocity`、スコア、生成済みパイプも対象です。**Scene hierarchy** は `view.mbt` の描画ツリーを表示します。**Export checkpoint / Import checkpoint** で `.kgrstate` を保存・復元できます。

コードと状態の型・検証はゲームが所有し、汎用エディタはデバッグ操作を提供する方針です。`kagura.runtime` と WebMCP の `kagura.runtime_*` が同じ API を使用します。実行状態の session / revision で競合を検出し、通常のシーン Save や Undo とは独立して扱います。現在の対応ゲームは Flappy Bird。共通契約は [runtime.d.ts](public/runtime.d.ts)、設計と他ゲームの実装手順は [game-projects.md](../../docs/editor/game-projects.md) を参照してください。`just studio-runtime-test` で JS/native の状態復元とヘッドレス API を検証できます。

### 2D プロジェクトの配置編集

2D examples は専用の平面ビューと Inspector を使います。Flappy Bird は **Examples → Flappy Bird** で鳥・地面を選択し、ドラッグまたは **X / Y / Width / Height / Color** で編集できます。右下ハンドルでサイズ変更、ホイールでズーム、中・右ドラッグでパン、**Fit / 100%** で表示を調整します。**Play** は配置・サイズをゲームの描画と衝突に反映し、**Stop** は編集中の状態へ戻ります。**Save** は `scenes/training.mbt` を保存またはダウンロードします。

2D 配置は `kagura.scene2d` リソースと `game/scene2d` の型で共有します。WebMCP の `kagura.pane.studio.scene2d.scene_read` / `object_edit` も同じトランザクションを利用します。共通 UI は `scene2d/`、Flappy Bird 固有の制約は `examples/games/flappy_bird/editor/scene.mjs` です。他の 2D examples は起動設定とプレビューまで対応し、配置の編集にはゲーム側のアダプターを追加します。

Studio 対象の 27 コード examples は MoonBit の `src/` を置かず、ソースを直下、シーンを `scenes/`、編集拡張を `editor/` に配置します。ビルド入口は `.` が既定です。具体的な読込規約は [プロジェクト設計](../../docs/editor/game-projects.md#ファイル配置と読み込みの命名規約) を参照してください。

### 宣言的な描画シーン

Flappy Bird と Arena 3D は `view.mbt` の入れ子から描画とヒエラルキーを生成します。2D は既存 `@scene`、3D は `@scene3d.group / mesh / show / for_each` を使います。Play 中の **Scene hierarchy** と `kagura.runtime.hierarchy()` は同じツリーを参照します。[宣言 API と実装例](../../docs/editor/declarative-scenes.md) を参照してください。

モデル閲覧は本体の [汎用モデルプレビュー](../../docs/editor/model-assets.md) を使用する。Project の GLB / glTF / OBJ をクリックすると、Kagura WebGPU で中央にプレビューする。ゲーム用の拡張や Play は不要。

`Model Assets` は `examples/assets/model_assets/` の素材専用プロジェクトで、MoonBit のビルド設定やゲームランタイムを持ちません。旧 glTF / OBJ viewer の素材をここに統合しています。各 example の目的と整理方針は [examples/README](../../examples/README.md) を参照してください。
