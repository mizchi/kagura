# wasm guest ABI notes

このディレクトリには 2 種類の契約を置く。

- `kagura-game.wit`
  - 現在の `examples/wasm_game` PoC が使っている legacy shared-memory protocol
  - `kagura_alloc`, packed input, packed draw command を前提にしている
- `kagura-app-v0.wit`
  - ADR 0001 に沿って今後の正本にする target guest ABI v0
  - host / guest の意味的な責務を表し、linear memory の詰め方までは固定しない

## v0 で固定したいこと

- host が `wgpu` renderer と preview shell を持つ
- guest は wasm component / wasm guest として `init`, `update`, `render`, `shutdown` を export する
- HMR はまず full reload を基準にし、必要なら `snapshot-state` / `restore-state` を使う
- guest に GPU API を直接見せず、描画は `render-command` に閉じる
- MoonBit を基準実装にしつつ、同じ WIT を満たせば Rust / Zig guest も動かせる

## 現行 PoC からの差分

- `kagura_alloc` は target ABI の一部ではない
  - 共有メモリを使うとしても、それは低レベル最適化であって semantic contract ではない
- `kagura_draw()` の packed binary ではなく、target ABI では `render() -> frame-output`
- HMR は `wasm module replace + full reload` を先に通し、state transfer は optional hook にする
- asset 読み出しは host import (`read-asset`) に寄せる

## 実装順

1. `kagura-app-v0.wit` を正本としてレビューする
2. MoonBit guest をこの ABI へ寄せた最小実装を作る
3. host 側で current PoC protocol から v0 ABI へ段階移行する
4. Rust / Zig guest の最小サンプルで ABI の言語中立性を確認する
