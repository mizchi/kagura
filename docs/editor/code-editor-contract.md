# ゲームコードとエディタの契約

共通 API の実装と導入手順は [game/inspection](../../game/inspection/README.md)。getter/setter の宣言から表示・編集を生成し、登録用ファイルを debug 限定にして配布物から除去します。

## 判断

Kagura のエディタは、ゲームが公開する **シーンの観測・状態の変更・ソースへの対応** を扱う。ゲームの状態を正本とし、描画ノードやエディタ専用 JSON をもう一つのゲーム状態にしない。

「このコードを書くと、何が選択でき、どの値が表示され、変更がどこに適用されるか」を API の責務にする。ファイル名の規約だけではこの契約を満たさない。`view.mbt` に書くという規約は入口の案内であり、型や実行時の接続を自動的に生成するものではない。

本書は再設計の基準。以下の **実装済み** は今回の最小実装、**提案** は未実装の次段階を示す。既存の初期配置エディタと runtime JSON 操作は互換経路として残る。

## 現状の不足

| 現在の契約 | 足りない対応 |
| --- | --- |
| `scene_document.Document` → ゲーム別 compileScene | 初期配置は編集できるが、実行中のオブジェクトのどの値に対応するか不明 |
| `view()` → `hierarchy.Node` | 入れ子は分かるが、選択したノードから論理状態を参照できない。Studio の Hierarchy は `kagura.graph()` で subjects（state）と view（観測）を並べ、subject があるノードだけ Inspector の編集対象になる |
| DebugState → JSON → replace | 任意の状態は復元できるが、選択対象・型付きフォーム・単位・編集可否がない |
| `for_each` → `generated: true` | 評価方法を表すだけで、生成元・永続性・ソース編集可否を表せない |
| `editor/scene.mjs` の profile | ゲームの型・値・検証と同じ情報を JS に重複して書く箇所がある |

例えば Arena の初期配置はループで描画するため `generated` になる。一方、Flappy Bird の鳥の Y は静的なノードの属性だが実行状態から毎回計算する。**静的な描画ノード＝値をソースに保存できる、動的な描画ノード＝編集できない、とはしない。**

## こう書くと、こう見える（実装済み）

MoonBit の通常の関数を使う。2D / 3D の宣言 API に同じ `subject` を追加した。これはエディタ専用の描画ノードを増やさない。

```moonbit
@scene.group(key="world", children=[
  @scene.subject("bird", @scene.rect(
    key="body", name="Bird body",
    x=60.0, y=state.bird_y,
    w=12.0, h=12.0,
  )),
])
```

3D では `@scene3d.subject("player", @scene3d.mesh(...))` とする。`subject` は単一の element を包む。生成処理では `for_each` の内側で各 element を包む。

| 記述 | エディタでの意味 |
| --- | --- |
| `group(key="world", children=[...])` | Hierarchy の `world`。children の順と入れ子を保持する |
| `rect(key="body", name="Bird body", ...)` | 表示名 Bird body、描画 ID `world/body`、kind rect |
| `subject("bird", rect(...))` | ノードの選択対象を論理 ID `bird` に結び付ける |
| `for_each(...)` / `show(...)` | 解決後に存在するノードを表示。generated は動的な評価を表す |
| `subject` なし | 階層の観測のみ。Inspector の編集対象を名前やパスから推測しない |
| `subject` はあるが現在の describe にない | 対象消滅または未対応としてフォームを表示しない。別の個体へ解決しない |

ゲーム側は同じ論理状態からフィールドを公開する。Flappy Bird の `inspection.mbt` が実例。

```moonbit
fn debug_inspector() -> @inspection.Inspector[DebugState] raise {
  @inspection.Inspector::new([
    @inspection.bind_subject("bird", name="Bird", fields=[
      @inspection.number_field("y", get=s => s.bird_y,
        set=(s, value) => { ..s, bird_y: value }, label="Y", unit="px"),
      @inspection.number_field("velocity", get=s => s.velocity,
        set=(s, value) => { ..s, velocity: value }, label="Velocity", unit="px/tick"),
      @inspection.number_field("speed", get=s => s.velocity.abs(),
        label="Speed", unit="px/tick"),
    ]),
  ])
}
```

Hierarchy でこのノードを選ぶと、共通 Inspector に Y / Velocity の入力と、読み取り専用の Speed が表示される。Pause 中に Y を変更すれば現在の位置が変わり、Velocity を変えればその値で次の tick を実行する。Speed の逆算による変更は許可しない。

初期位置の fixture、MoonBit ソース、描画ツリーの値をこの操作で変更しない。現在のプロトタイプは数値・文字列・真偽値を扱う。範囲・enum・ベクトル・アセット選択などの UI ヒントは次段階で追加する。

## ID は描画と状態で分ける

- **描画 ID**: 兄弟キーから解決する `world/body`。親が変われば変わる。キーなし 2D の `@0` は位置による識別であり、永続的な編集対象には使わない。
- **subject ID**: ゲーム所有の論理状態の識別子。同じ subject を本体・影・ミニマップなど複数ノードから参照できる。描画ノードの重複ではない。
- **field ID**: subject 内の安定 ID。表示ラベルや JSON の内部パスを API 名にしない。
- **実行 token**: `{session, revision}`。Play ごとに session を発行する。現在の実行と現在の停止状態への操作だけ許可する。

動的な個体には配列添字を使わず、ゲームの entity ID と世代を含む `enemy:42:3` などを割り当てる。削除後の ID 再利用で古い選択が別個体を指さないようにする。世代管理はゲーム側の責務で、今回の Flappy Bird の固定 subject は `bird` のみ。既存のパイプ配列へ安定 ID を追加する移行は未実装。

## 状態変更の API（実装済み）

```ts
interface RuntimeInspectorAdapter {
  describe(state: JsonValue): InspectionSubject[];
  reduce(state: JsonValue, edit: RuntimeFieldEdit): JsonValue;
}
```

describe/reduce は `Inspector[State]` と `Runtime[State]` から共通実装が生成する。ゲーム側で同じ field ID の switch を再実装しない。公開型は `editor/studio/public/runtime.d.ts`。MoonBit の表示契約は `game/inspection`、描画側の参照は `core/kagura_core/hierarchy` に置く。engine / game は editor のコードへ依存しない。

1. runtime session がゲーム状態のコピーと token を取得する。
2. `describe(state)` がそのコピーだけから対象・フィールド・値を投影する。ライブ状態の再読込、view の再評価、GPU 資源の作成をしない。
3. ホストが対象、型、編集可否、Pause、token を検証する。
4. `reduce(state, edit)` が候補状態を返す。ゲームのライブ状態を直接変更しない。
5. ゲーム所有の既存 `replace(candidate)` が全状態の不変条件を検証し、一括適用する。成功時だけ revision を進める。

ホストの型チェックはゲームの検証を代替しない。例えば Y が number でもゲームの座標制限外なら拒否する。スキーマ・reducer・replace はゲームが実装する契約であり、信頼できない任意コードの副作用をホストが巻き戻す仕組みではない。

```js
kagura.runtime.pause();
const inspection = kagura.runtime.inspect();
kagura.runtime.edit(
  { subject: 'bird', field: 'y', value: 80 },
  { session: inspection.session, revision: inspection.revision },
);
```

UI、ヘッドレス、WebMCP の `kagura.runtime_inspect` / `kagura.runtime_edit` はこの同じ経路を使う。カスタムペーンもこの API の利用者にする。独自の `state.bird_y = ...` をペーンごとに実装しない。

既存 `replace` は checkpoint や複数状態の一括編集向けに残る。新しい field edit は一操作単位。複数 field のトランザクション、ドメイン操作、状態の Undo は今後の拡張で、逐次 edit を原子的と扱わない。

## 所有者と保存先の拡張（提案）

フィールドごとに、値の由来と操作の保存先を別に表す。`generated` にこの意味を兼任させない。

| 値の由来 | 表示 | 操作 | 保存先 |
| --- | --- | --- | --- |
| `state` | 現在値、単位、型 | game reducer を通じて変更 | 実行状態。明示 Export で checkpoint |
| `derived` | 計算結果と依存対象 | 通常は読み取り専用。必要なら意味のある game action を公開 | 自動保存しない |
| `definition` | 初期値・設定値と source ref | 対応する source adapter が変更案を作る | 明示 Apply to source |
| `resource` | 論理 asset ID と情報 | import / replace 等のリソース操作 | project resources と実体ファイル |

setter の指定は現在値変更への opt-in。定義の編集可否は別の capability として宣言する。将来の descriptor は `origin`、`source`、`operations` を追加し、契約の版を明示する。現在の `access: runtime | readonly` に未知フィールドを混ぜて先取りしない。

例えば鳥の現在 Y は `state`、速度の絶対値は `derived`、リセット時 Y は `definition`。現在 Y を初期値へ取り込みたいなら、その対応をゲームが明示する。重力・AI・親 transform から得た world position の逆算を汎用エディタで推測しない。

## ソースとの対応（提案）

`SourceRef` は `{path, symbol, contentHash}` を基本にし、行・列は補助情報にする。ファイル全体のハッシュまたは管理領域のハッシュで編集競合を検出する。symbol を書いただけで位置を解決できるとは約束せず、ビルド側の対応表またはゲームの source adapter が解決する。

ソース編集は **prepare → diff → compile/validate → apply** の別 API にする。

- 通常の MoonBit コード: source ref で編集対象へ移動し、AI／コードエディタが変更案を作る。任意の式をシリアライズで逆変換しない。
- 管理対象の定数・fixture: literal codec が正確に所有する領域だけ変更案を作る。現在の `kagura-scene:begin/end` はこの互換アダプター。
- ゲーム独自のレベル配置: ゲームと一緒に source adapter を実装し、対応する domain pane が同じ prepare API を呼ぶ。
- 動的な実行状態: checkpoint として再現できる。定義への promotion は `subject/field -> definition/field` の対応を宣言したものだけ許可する。

コードが通常の正本であり、エディタの都合で全ゲームを managed literal へ書き換えない。ソース変更後の再ビルドは原則として新 session。ホットリロードで状態を引き継ぐ場合だけ、ゲームの migration が互換性を保証する。

## 起動とエディタ拡張（提案）

`.kgrprj` は起動・リソース・拡張の発見を担当する。次の版ではコード起動だけのゲームに scene 文書を必須にしない。ゲームビルドが公開する capability manifest から、次を判定する。

- hierarchy / inspect の有無
- pause / step / state replace / semantic actions の有無
- source の参照・編集・promotion の有無
- checkpoint の状態スキーマ、移行可能な版
- カメラ操作、pick、gizmo 用座標と bounds の契約

通常の編集ビューも、Pause したゲームの Kagura 描画を使用する設計へ寄せる。初期 fixture の専用表示が必要な場合だけ別 viewport adapter を用意し、どちらを表示しているか区別する。これによりエディタ用の色・メッシュ・transform の再定義を減らす。

共通エディタは Hierarchy、型付き Inspector、再生制御、Undo、リソース、source diff を所有する。ゲーム固有の editor はドメイン操作と補助表示を追加する。IRON YARD の機体構成・武装・配置操作も、各 pane 独自の状態コピーを持たず subject / operation の契約へ接続する。

JS / MoonBit / Wasm は同じ JSON メッセージ境界を使う方針。今回のブラウザ接続は JS FFI、MoonBit の describe / reducer / validator は native ヘッドレスでも検証する。Wasm の RPC・非同期実行・キャンセルは未実装であり、現在の同期 adapter をそのまま非同期と扱わない。

## 移行順序と完了条件

| 段階 | 内容 | 状態 |
| --- | --- | --- |
| 1 | 2D / 3D の subject 参照、game-owned field 契約、共通 UI / headless / WebMCP | 実装済み。実ゲームの接続は Flappy Bird の Bird |
| 2 | Arena の subject と entity の安定 ID、実行画面での pick・gizmo | 未実装。2D / 3D で同じ論理操作を検証する |
| 3 | code-only project、capability manifest、同じフレームの描画・階層・状態を指す revision | 未実装。現行 hierarchy は描画時の観測で、inspect は呼出時の論理状態 |
| 4 | source refs、変更案、明示的な promotion、競合と再ビルド | 未実装。通常コードと managed fixture の両方を扱う |
| 5 | IRON YARD / HNS の専用操作、ベクトル・enum・asset・domain pane | 未実装。固有機能を保ちながら profile の二重定義を減らす |

対応ゲームごとに「コード例 → 描画階層 → 選択 → Inspector → 変更 → 次の tick → 保存先」を一つの回帰テストにする。拒否時の状態・revision 不変、再起動後の stale token、消滅した対象への操作、ソース競合、headless/browser の同値性も検証する。

現行の subject Inspector は選択・Pause・編集・Step などホスト操作時に値を更新する。実行中の毎フレーム同期、gizmo、source jump、source 保存の UI は今回の完成範囲に含めない。

```sh
just studio-inspection-test
just target=native studio-inspection-test
just studio-build
# editor/studio でバックグラウンド実行
STUDIO_PREVIEW=1 STUDIO_GPU=metal pnpm exec playwright test e2e/inspection.spec.mjs
```
