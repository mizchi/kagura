# Getting Started

## 前提

- MoonBit
- Node.js 24+
- pnpm
- just

## インストール

```bash
pnpm install
```

## 最初の実行（JS smoke）

```bash
(cd examples/runtime_smoke && moon run src --target js)
```

期待されるログ末尾:

```text
runtime_smoke(js): ok (hooked)
```

## Native 実行（macOS）

```bash
bash scripts/setup-wgpu-native.sh
(cd examples/runtime_smoke_native && moon run src --target native)
```

## 継続的な確認

```bash
just check target=js
just test target=js
pnpm e2e:smoke
```
