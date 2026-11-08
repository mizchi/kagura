# 設計レビューと対応（2026-11-08、0.7.0）

ライブラリ、実行アダプター、Wasm guest、配布・検査スクリプトを確認した。
層の依存方向は維持されている。今回の対象は、失敗の伝播、実行状態の寿命、
描画形式と ABI の契約、ビルドの再現性、検査対象の管理だった。

## 対応一覧

| ID | 優先度 | 問題 | 対応 |
| --- | --- | --- | --- |
| D1 | P1 | 起動失敗後も仮 handle で続行 | 型付きの失敗・状態を返す session に統合。失敗時は callback を開始しない |
| D2 | P1 | 頂点 stride を三つの形式へ曖昧に丸める | 対応形式を明示し、未対応値を拒否。pipeline cache にも layout を含める |
| D3 | P1 | グローバル状態と停止処理の寿命が不明瞭 | clock / hook の捕捉、予約取消、解除関数、冪等な停止、二重起動拒否を実装 |
| D4 | P2 | Wasm の wire と実行経路の正本が分かれる | wire schema・生成・version 検査・byte fixture・host adapter を共通化 |
| D5 | P2 | cache の状態と診断文に依存する修正 | 対応版への依存更新でソース補修パッチと lock を撤去。旧 manifest の移行は診断文を解析せず実行 |
| D6 | P2 | module 一覧と検査 recipe が重複 | 実行可能な check plan と単一 catalog を導入し、網羅性テストも同じ plan を検査 |

D5 は crater `0.19.2` と `differentiable_ecs@0.2.2` へ依存を更新し、
依存ソースを書き換える互換層そのものを撤去した。

## D1・D3: 起動と停止

[RunSession の型](../../engine/session_types.mbt)、
[寿命の実装](../../engine/session.mbt)、
[共通の実行処理](../../engine/run_session.mbt) に分けた。
`engine.start` / `start_game` は session を返す。既存の `run` / `run_game` は同じ実装を使う。
scene を含む入口へ `on_error` を渡せる。

- `Starting` / `Running` / `Stopped` / `Failed` を区別する。
- 失敗段階は `RunStage` enum とし、呼び出し側へ一度だけ通知する。
- 初期化例外をログだけで処理したり、ID 1 の代用品を作ったりしない。
- 非同期 GPU 起動待ちでは game callback を呼ばない。
- clock・終了 hook・frame host を開始時に捕捉する。
- frame 予約と終了 listener は解除関数を持ち、停止時に解放する。
- 古い game callback・GPU 起動 promise・vsync submit は世代で無効化する。
- 同じ backend の二重起動は既存 session の状態を触る前に拒否する。

現在の graphics hooks の容量は一つの runtime / realm に一つの GPU session。
複数 preview は host を分ける。独立した GPU session の同時実行をサポート済みとは扱わない。
固定 timestep と per-frame の実行モデルの違いは保持した。
詳細は [runtime-sessions.md](./runtime-sessions.md) を参照する。

## D2: 対応する頂点形式を厳密にする

[共通検証](../../engine/renderer2d/vertex_layout.mbt) と
[WebGPU pipeline](../../platform_web/host/kagura-gfx.js) は対応する stride を
4 / 8 / 16 成分に限定する。0 は従来の shader 推定用の互換値として残す。
12 成分を 32 bytes の layout へ丸める経路は、GPU resource 作成前にエラーになる。
同じ shader ID でも stride が異なれば pipeline cache を共有しない。

メッシュの `VertexFormat` は計算用の属性を表せるが、tangent / color を追加した
任意形式の描画はまだ対応外。対応しない値を正しく扱えるかのように通さない。
将来の拡張では、属性・offset・step mode を descriptor として渡す契約を別途追加する。

## D4: Wasm の契約と所有単位

[raw wire schema](../../platform_web/host/guest-wire-v0.json) を配置し、
version・共通サイズを JS / MoonBit / Rust / Zig へ生成する。
WIT は semantic contract とし、position / UV を持つ `vertex2d` に揃えた。
raw ABI と component canonical ABI は区別する。

[host codec](../../platform_web/host/kagura-guest-protocol.js) は example から platform へ昇格。
version・必須 export・memory を guest init 前に検査する。
semantic guest と engine frame は別の adapter とし、状態参照と冪等な停止の契約を共有する。
preview と smoke loader はこの adapter を使用する。
HMR の古い読み込み結果、旧 instance への frame、失敗表示の意図しない消去も防ぐ。

[byte fixture](../../examples/experimental/wasm_game/protocol/wire-v0-fixtures.json) で host の
init / input / draw と3言語 guest の config / draw header を検査する。生成検査は `just wasm-wire-check`。
実行モードと互換範囲は [guest-abi.md](./guest-abi.md) を参照する。

## D5: 対応版へ更新し、ソース補修を撤去する

[prepare-moon-deps.mjs](../../scripts/prepare-moon-deps.mjs) は、compiler の診断文を
解析せず cache 内の旧 manifest を列挙する。check plan の target を使うため、
native 専用 module を誤って wasm として準備しない。

crater は `0.19.2` へ全 example の依存を更新し、`crater-layout` と
`crater-renderer` の `Float` 互換修正を撤去した。
`differentiable_ecs` は optimizer の `cmp` import を本体で修正した `0.2.2` へ更新。
最後の修正処理と互換 lock・専用テストも削除した。
準備処理が現行形式の依存 package と source を変更しないことを回帰テストで検査する。

リリースの staging も旧 JSON のみの出力から現行 `moon.mod` へ変更した。
配布 metadata の round trip と、staging 済み全公開 module の実際の compiler check を検証する。
新しい自前の配布物が旧 manifest を再生産しないようにした。

旧 JSON manifest の形式移行は、他の公開依存にも残っているため継続する。
依存 source の補修は行わない。

## D6: plan を実行と検査に使う

[check catalog](../../scripts/moon-check-catalog.mjs) が独立 module、対応 target、
外部 checkout 要否を保持する。
[check plan](../../scripts/moon-check-plan.mjs) は workspace、動的な example 一覧、
catalog を組み合わせ、[CLI](../../scripts/check-moon-modules.mjs) が実行する。
justfile に module 一覧を重ねて定義しない。

網羅性テストも同じ plan を使い、単に path が recipe に書かれているかでは判定しない。
未登録 module、target、実行引数、失敗時の停止を fixture / fake runner で検査する。
Wasm 専用の `wasm_async_smoke` は wasm として明示的に検査する。
配布用の module catalog は別の責務として維持する。

## 関連する整理

atlas の 1,946 行の `contracts.mbt` は、型・trait と五つの実装ファイルに分離した。
165 個の宣言ブロックと atlas の公開 API を保持した。
古い設計資料のリンク・所属、`VertexFormat::offset_of` の単位コメントも修正した。

## 検証

- MoonBit の workspace テスト: JS 1,435 件、native 1,423 件成功。
- 起動・停止の fake host テストと、予約済み GPU submit の無効化テストが成功。
- ブラウザ: GPU 起動後の描画、GPU 失敗時の未実行、停止後の予約数 0 を確認。
- Wasm: WIT 検査、3言語の build / smoke / ABI、host の型検査・build が成功。
- 配布 archive の manifest と `cmp` import、および依存 source を変更しない準備処理を確認。
- crater `0.19.2` の公開版を使った renderer example の JS / native と、
  crater_paint / browser_headless の native check が警告をエラー扱いにして成功。
- `differentiable_ecs@0.2.2` を公開し、取得した全18ファイルが配布 archive と一致することを確認。
  kagura の公開版依存による JS / native check と balance_lib の26テストが成功した。

Node テスト 455 件、リリース検査、生成物照合、対応 target の全 module 検査が成功した。
配布予定20 module の staging からの compiler check と archive 検査も成功し、公開は行っていない。
