# ADR 0001: `wgpu` host と wasm guest を中心にした code-first アーキテクチャを採用する

- Status: Accepted
- Date: 2026-03-07

## Context

`kagura` は当初、Ebiten 互換に近いゲームエンジンとして、MoonBit で 2D/3D 両対応の実行基盤を整えることを主眼に進めてきた。

一方で今後の開発体験としては、単に engine API を増やすよりも、次の性質を持つ環境が重要になっている。

- `wgpu` を使った安定した preview / rendering host
- wasm としてアプリケーションコードを差し替えられる高速な HMR
- GUI editor 依存ではなく code-first で進められる authoring
- MoonBit を基準にしながらも、同じ ABI を満たせば Rust / Zig でも guest を実装できる拡張性
- 複雑な編集操作を GUI に寄せるより、AI に patch を作らせて preview / diff / rollback で確認する運用

Unity / Godot のような重い統合 editor を正面から再実装するのは、現時点の `kagura` の強みと一致しない。
`kagura` が勝ちやすいのは、`wgpu` host と wasm guest の分離、WIT による ABI 固定、preview-first tooling、code-first authoring を一体で提供する方向である。

## Decision

`kagura` は今後、次の方針を採用する。

### 1. Renderer と preview shell は host 側に置く

- host は `wgpu` を使って描画、preview、stats、error overlay、asset preview、debug UI を担当する
- guest に GPU API を直接公開しない
- host/guest 境界では `render commands`、scene graph、render plan など、より高いレベルの描画契約を扱う

### 2. アプリケーションコードは wasm guest として実行する

- ゲームやツールのロジックは wasm guest として build / deploy する
- guest は `init` / `update` / `render` / `input` / `audio` / `asset` / `hot_reload` / `shutdown` などの ABI を通じて host とやり取りする
- HMR は必須要件とし、最初は full reload を基準にする
- state 保持が必要な場合は、後続段階で `serialize/restore` または migration hook を追加できるようにする

### 3. Host/guest 契約は WIT で定義する

- wasm guest ABI は WIT を正本とする
- MoonBit のライブラリ API と、wasm 越しに公開する guest ABI は分けて設計する
- ABI は versioning 可能であることを前提にし、host と guest の互換性をテストする

### 4. MoonBit を基準実装にしつつ、Rust / Zig に開く

- 最初の guest 実装と開発体験は MoonBit を基準に整える
- ただし設計は MoonBit 専用に閉じず、同じ WIT を満たせば Rust / Zig の guest も動かせるようにする
- 多言語対応は将来構想ではなく、最小サンプルを早期に動かして検証する

### 5. Editor 統合は preview-first に寄せる

- editor は heavy authoring tool ではなく、preview / inspect / debug shell として育てる
- 優先するのは scene preview、asset preview、state inspect、input replay、draw call 可視化、shader reload などである
- 複雑な direct manipulation UI は後回しにし、利用者へ露出する GUI 操作を増やし過ぎない

### 6. 複雑な編集は AI-assisted workflow を前提にする

- 複雑な編集操作は AI が patch を生成し、host が preview / diff / rollback を提供する流れを基本にする
- ユーザーに必要なのは多機能な editor ではなく、「変更の提案」「結果の確認」「戻せること」である
- そのため host には file diff、runtime diff、snapshot diff、error surface を表示する機能を持たせる

### 7. Authoring は code-first を維持する

- scene、UI、animation、asset wiring はまずコードで定義する
- data-driven な scene authoring や prefab 相当は、code-first と矛盾しない範囲で後から追加する
- GUI でしか作れない表現や構造は基本方針にしない

## Non-Goals

この ADR では次を目標にしない。

- Unity / Godot 風の重い統合 editor を短期で再現すること
- guest から `wgpu` や backend 固有 API を直接叩けるようにすること
- MoonBit 専用 ABI に固定して、Rust / Zig からの guest 実装可能性を失うこと
- 複雑な GUI authoring を先に整え、preview / HMR / ABI 設計を後回しにすること

## Consequences

### Positive

- renderer と authoring/runtime shell の責務が host にまとまり、guest はアプリケーションロジックに集中できる
- wasm guest の差し替えで高速な preview と HMR を実現しやすい
- MoonBit を基準にしつつ、多言語 guest を実験しやすい
- editor の実装量で Unity / Godot と競わず、`preview-first + AI-assisted + code-first` という別の勝ち筋を取れる

### Negative

- host/guest ABI 設計の失敗が、性能・拡張性・デバッグ性に直結する
- wasm 境界の copy / serialization / call overhead を計測し続ける必要がある
- HMR で state を引き継ぐ場合、schema versioning や migration の問題が発生する
- AI-assisted workflow を成立させるには、diff / rollback / preview の基盤が先に必要になる

## Alternatives Considered

### A. MoonBit 単体の monolithic engine / editor として進める

却下。
短期では実装しやすいが、multi-language guest と wasm ABI の設計が後回しになり、将来の拡張性を失う。

### B. guest から `wgpu` を直接操作させる

却下。
backend 差分、ABI の不安定化、言語ごとの差分吸収コストが大きく、host/guest 分離の利点を壊す。

### C. Unity / Godot に近い GUI editor を先に作る

却下。
実装コストが高く、現段階の `kagura` の強みである code-first と高速 preview を弱める。

## Resulting Work

この ADR により、次の作業を優先する。

1. wasm guest ABI v0 を WIT で定義する
2. MoonBit guest + `wgpu` host の最小 vertical slice を作る
3. preview shell に HMR、error overlay、stats、diff 表示を入れる
4. Rust / Zig guest の最小サンプルを追加する
5. host/guest ABI の性能計測と互換性テストを整備する
