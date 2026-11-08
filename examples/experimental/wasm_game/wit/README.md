# Wasm guest 契約

- `kagura-app-v0.wit` は host / guest の semantic contract。
- raw pointer / length の ABI v0 は `platform_web/host/guest-wire-v0.json` が正本。
- canonical component ABI と raw ABI のバイト列を混同しない。
- `kagura_guest_abi_version` による互換性検査は guest init 前に行う。

生成・適合検査は `just wasm-wire-generate` / `just wasm-wire-check` /
`just wasm-verify`。詳細は [guest-abi.md](../../../../docs/architecture/guest-abi.md) を参照する。
