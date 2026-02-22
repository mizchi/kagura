# はじめに

[English](getting_started.md)

## 前提条件

- [MoonBit](https://www.moonbitlang.com/)
- Node.js 24+
- pnpm
- [just](https://github.com/casey/just)

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

## Native 実行（macOS のみ）

> Native ビルドは現在 macOS のみ対応しています。Windows / Linux 対応は計画中です。

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
