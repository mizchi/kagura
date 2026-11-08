# Wasm guest の wire 契約

semantic な責務は [kagura-app-v0.wit](../../examples/experimental/wasm_game/wit/kagura-app-v0.wit)、
raw ABI v0 の配置は [guest-wire-v0.json](../../platform_web/host/guest-wire-v0.json) を正本にする。
WIT component の canonical ABI と、現在の raw pointer / length 形式は区別する。
WIT の頂点は position と UV を持つ `vertex2d` とし、wire の四つの float に対応させた。

## 実行モード

| モード | 入口 | frame の結果 | 停止 |
| --- | --- | --- | --- |
| semantic raw v0 | `kagura_guest_*` | GPU API に依存しない draw commands | guest shutdown |
| engine frame | `kagura_frame` / `kagura_session_status` | host graphics import を使って描画 | `kagura_stop` |
| async worker | blocking な `_start` と共有制御配列 | worker 内のアプリに従う | worker driver の終了手順 |

前二つは [kagura-guest-protocol.js](../../platform_web/host/kagura-guest-protocol.js) の
`createGuestSession` / `createEngineFrameSession` で、`status` / `frame` / 冪等な `stop` を持つ
所有単位へ変換する。返す描画情報と必要な imports は異なり、自動的に交換可能とは扱わない。
semantic preview host と engine smoke loader は、それぞれの adapter を使用する。
engine frame の executable は `kagura_frame` / `kagura_stop` / `kagura_session_status` を
再 export する。status は 0=Starting、1=Running、2=Stopped、3=Failed。
host は内部の失敗・停止を観測し、空の frame を予約し続けない。

## バージョンと生成

semantic guest は `kagura_guest_abi_version() -> i32` を export し、現在値は 0。
host は初期化・メモリ確保前に version、必須 export、memory を検査し、不一致を拒否する。

`just wasm-wire-generate` は wire の version・共通サイズ・vertex components を
JS / MoonBit / Rust / Zig の生成ファイルへ反映する。
`just wasm-wire-check` は生成済みファイルが正本と一致することを検査する。
`just wasm-verify` もこの検査を実行する。

codec は example から platform host へ移した。example 内の `shared-memory.js` は互換の re-export。
ブラウザ host と Node harness は同じ codec と ABI 検査を使う。

[wire-v0-fixtures.json](../../examples/experimental/wasm_game/protocol/wire-v0-fixtures.json) は
独立した little-endian の固定バイト列。host の init / input / draw encoding と、
3言語 guest が返す config / draw header を照合する。既存の update / render / host asset / shutdown の
適合テストも維持する。

## 交換時の寿命

preview host は旧 guest を止めてから交換し、交換中の旧 instance へ frame を送らない。
同時に複数の更新が届いた場合は世代で最新だけを採用し、古い読み込み結果を解放する。
Vite module の dispose は frame 予約、入力 listener、guest を解放する。
失敗した guest の診断は次の空フレームで消さず、交換成功まで保持する。
