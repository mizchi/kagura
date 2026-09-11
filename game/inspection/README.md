# ゲームと Inspector を接続する

ゲームは一つの `Inspector[State]` に getter と setter を宣言する。表示用 JSON と編集ハンドラーは共通 API が生成する。

```moonbit
fn inspector() -> @inspection.Inspector[State] raise {
  @inspection.Inspector::new([
    @inspection.bind_subject("bird", name="Bird", fields=[
      @inspection.number_field("y",
        get=s => s.y,
        set=(s, value) => { ..s, y: value },
        label="Y", unit="px"),
      @inspection.number_field("speed", get=s => s.velocity.abs()),
    ]),
  ])
}
```

`number_field` / `text_field` / `boolean_field` が型を保証する。setter があれば現在値を編集でき、省略すれば読み取り専用。setter はコピーされた状態から候補状態を返す純粋関数にする。ゲームの不変条件は最後の `replace` が検証する。

描画ノードは `@scene.subject("bird", @scene.rect(key="body", ...))` または `@scene3d.subject("bird", @scene3d.mesh(key="body", ...))` で関連付ける。`key="body"` は描画ノード、`subject="bird"` は論理状態の識別子。親が `world` なら描画パスは `world/body` になる。同じ subject の getter/setter をペーンや WebMCP ごとに再定義しない。

複数の描画ノードで同じ subject を参照できる。子ノードへの継承はしない。subject がない、または現在の Inspector に対応する binding がないノードを選んでもフィールドは表示されない。

## 編集の適用と保存

Studio の `runtime.edit` は **Pause 中かつ現在の session/revision に一致する場合だけ** 実行できる。UI、カスタムペーン、WebMCP はこのホスト API を使う。

```js
kagura.runtime.pause();
const current = kagura.runtime.inspect();
const committed = kagura.runtime.edit(
  { subject: 'bird', field: 'y', value: 80 },
  { session: current.session, revision: current.revision },
);
```

getter/setter は分離された snapshot を扱い、setter が返した候補をゲームの `replace` が検証して一括適用する。成功すると revision が進み、古い token は再利用できない。拒否時は状態と revision を維持する。呼び出しは同期だが、描画の更新は別に行う。

低レベルの MoonBit API は候補を返すだけで、停止・競合チェックもコピーも行わない。

```moonbit
let candidate = inspector.edit(snapshot, subject="bird", field="y", value=80)
// ホストの停止・競合チェック後、ゲームの replace が検証・適用する。
```

編集先は現在の実行状態。MoonBit ソース、初期配置、プロジェクトファイルへ自動保存しない。再現用の状態を保存するには別操作の Export checkpoint を使う。ソースへ反映する API は未実装。

## 登録は debug 専用ファイルに置く

`inspection_js.mbt` に次の登録を書く。Flappy Bird の同名ファイルが実装例。

```moonbit
@inspection.Runtime::new(
  game="my_game", schema="my_game.state", inspector=inspector(),
  read=() => { state: game.snapshot(), revision: game.revision, paused: game.paused },
  pause=value => game.pause(value),
  step=() => game.step(),
  replace=state => game.validate_and_replace(state),
).register(
  hierarchy=() => game.hierarchy_json(),
)
```

`State` には `FromJson` / `ToJson` が必要。JSON の変換、未知フィールドの拒否、型付き setter の選択、成功・エラー応答、`kaguraDebugAdapter` と `kaguraSceneRuntime` への接続は共通実装が担当する。ゲームごとの `extern "js"` は不要。

`read` は一貫した snapshot を返す。`replace` は全状態の検証後に一括適用し、revision を進める。Pause と neutral input による Step、乱数や物理状態などの内容はゲームが所有する。`Runtime::invoke(op, payload)` は同じ処理の JSON 窓口で、native のヘッドレステストからも呼べる。session/revision の競合チェックは Studio の RuntimeSession が担当する。invoke を外部へ直接公開して競合チェックを省略しない。

## 配布物から除去する

MoonBit の `moon.pkg` の `targets` で **登録を呼ぶ入口そのもの** を debug 限定にする。

```moonbit
options(targets: {
  "inspection_js.mbt": ["and", "js", "debug"],
  "view_inspection_debug.mbt": ["debug"],
  "view_inspection_release.mbt": ["release"],
})
```

- debug の更新・描画入口: Pause / revision を管理し、描画と階層を解決する。
- release の更新・描画入口: ゲームの tick と view を直接使う。登録処理・Inspector・codec を参照しない。
- `Control` / `new_control()` は debug では Pause / revision / hierarchy を保持する。release の型は Unit で、デバッグ用状態を確保しない。ゲームに保持するフィールド名を `_inspection` にすれば release での未使用を明示できる。
- `subject()` は release では恒等操作。2D の key/name の検査用属性も追加しない。3D の描画グラフの key は描画の識別に必要なので維持する。

単に未呼出のクロージャで登録を包んだり、UI を隠すだけでは、JS 出力からの除去を保証できない。debug/release の切り替えは最適化ヒントではなく、コンパイルするファイルの選択で行う。

`pkg.generated.mbti` は生成された型一覧で、doc comment や両方のビルドプロファイルを表現しない。現在の一覧にある `Control` struct は debug 側の型であり、release の表現ではない。API の意味とビルド条件は本書と公開関数の doc comment を併せて読む。

| API / コード | debug | release |
| --- | --- | --- |
| `Control` / `new_control()` | counters と hierarchy を保持 | `Unit` / `()` |
| 2D `subject`、key/name 属性 | 検査用メタデータを追加 | 追加しない |
| 3D subject / hierarchy | 論理対象と描画階層を公開 | 検査用メタデータを省略。描画用 key は維持 |
| `Inspector` / `Runtime` / JS `register` | 利用可能 | API 自体は利用可能。参照すると残る |
| Flappy Bird の登録入口・bindings | `moon.pkg` で選択 | `moon.pkg` でコンパイル対象外 |

Studio では `.kgrprj` に `"build": {"package":".", "artifact":"my_game.js", "editorMode":"debug"}` を指定する。既定は release。配布用の `moon build --release` はこの Studio 用設定を参照しない。debug プレビューの FPS と release 配布物の FPS は同じ条件の測定ではない。

```sh
just studio-inspection-test
just target=native studio-inspection-test
just studio-inspection-release-check
just target=native studio-inspection-release-check
```

除去の検査は現在 Flappy Bird を代表実装として、生成 JS / 生成 C に登録 API・フィールド定義・codec・階層解決コードが残らないことを検査する。debug 側に同じマーカーが存在することも確認し、空のビルドを成功と扱わない。JS は入力を与えた 1 / 30 / 180 tick の画像が debug と release で完全一致することも検証する。CI の JS / native-macos ジョブで実行する。

保証対象はこの配置規約と除去ゲートを適用したビルド。ゲームが release の入口から Runtime や Inspector を直接呼べば保持されるため、各ゲームへの移行時に同じゲートを追加する。Wasm の最終配布物の除去ゲートは未実装。Unit の保持スロットや恒等関数まで全バックエンドでゼロ命令になるとは保証しない。
