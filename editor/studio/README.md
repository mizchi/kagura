# Kagura Studio

Luna / MoonBit で書き直した、AIと人が同じコマンドで編集する統合オーサリング環境の最初の実装。
シーン・プリミティブモデリング・短い演出プレビューを同じワークスペースで確認できます。

## 起動

Node.js 24+、pnpm、MoonBit、just が必要です。リポジトリのルートで:

```sh
just studio-install
just studio-dev
# http://127.0.0.1:5190
```

`studio-dev` は MoonBit を初回ビルドし、変更監視と Vite を起動します。
依存は独立した `moon.work` と固定バージョンで解決し、隣の luna.mbt / three-mbt のチェックアウトには依存しません。
ブラウザ向け UI は `mizchi/luna@0.23.3`、シーン生成は `mizchi/three@0.1.3` を使います。

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
自然言語の推論や外部LLMへの通信はエージェント側が担当します。

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
| コントラクト | `src/core/contracts.mbt`, `public/contract.d.ts` | バージョン・単位・ノード・演出・入力検証 |
| 編集ロジック | `src/core/commands.mbt` | 入力を変更しないドキュメント遷移 |
| 状態・操作 | `src/core/session.mbt`, `editor.mbt` | 原子的コミット、版の競合、Undo/Redo、選択・時刻、共通リクエスト |
| Lunaビュー | `src/app/views.mbt`, `state.mbt` | コントローラ状態をSignalへ反映。UIも同じリクエストを発行 |
| ヘッドレス | `src/headless`, `headless/` | Node向けエクスポート、JSONL CLI、ファイル保存 |
| threeアダプター | `src/app/scene.mbt`, `web/viewport.mjs` | MoonBitからシーン生成、カメラ・ピック・プレビュー・破棄 |
| レイアウト | `web/layout-state.mjs`, `layout.mjs`, `layout.css` | 寸法・制限とドラッグ操作、画面内配置、独立スクロール |
| ブラウザホスト | `web/main.mjs`, `api.mjs` | 永続化・ファイル・クリップボード・AIへのJSON境界 |

`core` はDOM、Luna、threeをimportしません。UIとレンダラーはこの契約の利用者です。
既存のkagura engineとは別moduleなので、エディタのUI依存が公開エンジンへ流れません。

## 持ち込んだ知見と次の接続

[設計・移植方針](../../docs/design/studio-authoring.md) を参照してください。
現時点の対応はプリミティブの配置・階層・材質と、単一ターゲットの閃光／反動プレビューです。
GLB読込、人体・IK・モーション編集、音声合成、複数アクション、Transformギズモ、任意ペーン分割、ゲーム実行、既存modeling3d/effect-studioドキュメントとの変換は未実装です。
modeling-playgroundのScene Studio JSONは別形式のため、そのままImportすることはできません。
2000ノードの上限は入力制限であり、大規模シーンの性能保証ではありません。

## カスタムペーン

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
