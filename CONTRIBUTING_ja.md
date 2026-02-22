# kagura への貢献

[English](CONTRIBUTING.md)

このドキュメントは、`mizchi/kagura` への開発参加者向けガイドです。
ライブラリ利用者向けの情報は `docs/user/` を参照してください。

## 開発原則

- TDD を基本に進める（探索 -> Red -> Green -> Refactor）
- API/型のコントラクトを先に定義し、実装差分は後段で吸収する
- 関心の分離を維持し、状態とロジックを混ぜない
- 既存契約を壊す変更では `moon info` で公開 API 差分を確認する

## セットアップ

- [MoonBit](https://www.moonbitlang.com/)
- Node.js 24+
- pnpm
- [just](https://github.com/casey/just)
- macOS native 実行時は `bash scripts/setup-wgpu-native.sh`

## 開発フロー

1. 変更対象の設計/境界を確認する（`docs/architecture.md`, `docs/module_boundaries.md`）
2. 失敗するテストを先に追加する（Red）
3. 最小実装でテストを通す（Green）
4. API/責務分離を崩さない形で整理する（Refactor）
5. 以下の検証を実行してから PR を作成する

## ローカル検証

```bash
just fmt
just check target=js
just test target=js
just check target=native
just test target=native
pnpm e2e:smoke
```

必要に応じて smoke 実行も確認してください。

```bash
(cd examples/runtime_smoke && moon run src --target js)
(cd examples/runtime_smoke_native && moon run src --target native)
(cd examples/native_triangle && moon build src --target native)
```

## ドキュメント配置ルール

- ユーザー向け: `docs/user/`
- 開発者向け設計資料: `docs/`
- 貢献手順: `CONTRIBUTING.md`

機能追加時は、対象読者に応じてドキュメントを更新してください。
