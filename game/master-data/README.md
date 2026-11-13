# マスターデータの編集契約

Studioはゲーム所有のアダプターから編集可能なテーブルを生成します。UI・下書き・Undo/Redo・保存はStudioが担当し、ゲームはデータの定義と読み込みを担当します。シーン上の実行時オブジェクトを調べるInspectorとは別の機能です。

## 使い方

StudioのExamplesから **FATHOM** を開き、上部の **マスターデータ** を選びます。

- **敵**: 名前・HP・攻撃・防御・素早さ・薙ぎ払いの有無。
- **遭遇編成**: 場面と出現する敵。3体目は省略できます。
- **遠征ルール**: HP/攻撃倍率・遭遇間隔・薙ぎ払いの威力。

値を編集して **次のPlayに反映** を押すと、プロジェクトのリソースに反映します。実行中のゲームは開始時のデータを保ち、Stop → Playで新しい値を読み込みます。型・範囲・重複・参照切れがある下書きは反映できません。Undo/Redoで修正でき、ダイアログを閉じても下書きは残ります。

サンプルとフォルダアップロードによる読み取り専用プロジェクトの編集は、プロジェクトを閉じるまで有効です。**JSON書出** で持ち出し、**JSON読込** で戻せます。書き込み可能なフォルダを開いた場合は **フォルダへ保存** で宣言したリソースへ保存できます。ディスク上で別途変更されていた場合は上書きせずエラーにします。通常のProject Saveも反映済みリソースを保存します。未反映のフォームは保存対象に含めません。

## ゲームを対応させる

1. プロジェクト相対の、自己完結した `.mjs` で `masterDataAdapter` をexportします。Blob URLから読み込むため、相対importは使わず単一モジュールにまとめます。
2. JSONリソースとアダプターを `.kgrprj` に宣言します。
3. ゲーム起動時にそのJSONを読み、ゲーム側でも検証してから適用します。ブラウザ版はStudioのリソース解決を経由する通常の `fetch` を使います。

```json
{
  "resources": {"master": "assets/master-data.json"},
  "masterData": {"adapter": "assets/master-data-adapter.mjs", "resource": "master"}
}
```

上は既存manifestへ追加する項目です。StudioはPlay時にもアダプターでデータ全体を検証し、そのリビジョンのリソースURLをゲームに渡します。編集中にゲームが古い値と新しい値を混ぜて起動することはありません。ゲーム側でJSONを実際のルールへ読み込む実装は必要です。

```js
export const masterDataAdapter = {
  apiVersion: 1,
  schema: {
    id: 'sample', version: 1, title: 'Sample',
    tables: [{
      id: 'items', label: '道具', primaryKey: 'id', labelField: 'name',
      columns: [
        {id: 'id', label: 'ID', type: 'string', maxLength: 80},
        {id: 'name', label: '名前', type: 'string', minLength: 1},
        {id: 'power', label: '威力', type: 'integer', min: 1, max: 100, step: 1},
        {id: 'enabled', label: '使用可能', type: 'boolean', default: true},
      ],
    }],
  },
};
```

```json
{
  "format": "kagura.master-data", "version": 1, "game": "sample",
  "tables": {"items": [{"id": "sword", "name": "剣", "power": 10, "enabled": true}]}
}
```

厳密な型は [contract.d.mts](contract.d.mts)、検証と編集セッションは [contract.mjs](contract.mjs)。列は文字列・整数・実数・真偽値・列挙・他テーブル参照を扱えます。参照の `table` は相手テーブルIDです。`nullable` はJSONの `null` を許可します。`readOnly` はフォーム上の編集を制限し、値そのものを固定する場合は `lockedValues` も定義します。

主キーはASCII英字で始まる80文字以内のIDです。通常のテーブルは行を追加・削除できます。フォームで追加するIDは `row_1` などを採番します。IDの一括変更は参照も更新したJSONをインポートします。`rowIds` を宣言したテーブルは固定行になり、追加・削除を許しません。ゲーム固有の追加検証は純粋な `validate(document): Issue[]` で指定でき、UI部品を実装する必要はありません。

下書きの編集は `revision` を必須とし、古いリビジョンへの更新を拒否します。初期読込とJSONインポートは全件検証を通ってから置き換えます。`session.document()` は有効なデータだけを返します。JSONは4 MiBまでです。

## バランス実験と再生

アダプターの `parameters` に、調整パラメーターと数値セルの対応を宣言できます。

```js
parameters: {enemyHpScale: {table: 'rules', row: 'expedition', column: 'enemy_hp_scale'}}
```

`parameterSpecs` はそのセルの範囲・刻み・初期値を取り出します。`applyParameters` は他の行を保って候補値を適用します。UIのJSON読込はこの対応を使い、同じゲームのバランスプロファイルも読み込めます。

```sh
just balance-tune dungeon_rpg --master-data edited.master-data.json
just dungeon-rpg-agent --master-data edited.master-data.json --dry-run
just dungeon-rpg-agent --master-data edited.master-data.json --watch
```

FATHOMの記録はマスターデータ全体も固定し、同じデータで再生します。記録の `engineVersion` は3です。マスターデータを持たない旧記録は再生できません。未発見の敵情報をJevの観測へ追加することはありません。評価の基準は[プレイヤー体験の調整](../balance/README.md)と同じで、判断への反応・立て直し・テンポを検証します。

## FATHOMの実装と検証

[アダプター](../../examples/games/dungeon_rpg/assets/master-data-adapter.mjs)と[JSON](../../examples/games/dungeon_rpg/assets/master-data.json)が実例です。現在は描画側に対応する敵6種・遭遇4場面・遠征ルール1行を固定IDにしています。行追加が必要な別ゲームは `rowIds` を省略できます。地形・味方・装備・呪文はまだテーブル化していません。

WebはJSONを直接読み込みます。ネイティブの初期値は同じJSONから `sim/master_data_generated.mbt` へ生成します。JSONを手で変更したら `just dungeon-rpg-master-build` を実行してください。FATHOMの専用dev/testタスクとautoplayビルドでも生成します。生成ファイルは手編集しません。

```sh
just master-data-test     # 共通契約・リソース保存・JS/nativeゲーム・再生
just master-data-e2e      # Studio編集→実ゲーム、別スキーマ、JSON、スマートフォン
just studio-dev          # 別ターミナルで起動
just master-data-ui      # vlmkitの固定UIゲート
```
