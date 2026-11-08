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

検証済みツールチェーンは `moonc v0.10.20`（`moon 0.1.20261104`）です。
`moon upgrade` と `moon update` の後に `just moon-deps` を実行すると、
公開パッケージに残る旧 JSON マニフェストをダウンロード先で移行します。
サンプル単体では `just moon-deps examples/games/flappy_bird` のように指定できます。
`just check` / `just test` と CI はこの準備を自動で行います。

旧 manifest の検出は compiler の診断文に依存しません。
crater `0.19.2` と differentiable_ecs `0.2.2` への更新でソース補修パッチを撤去しました。
現行形式の依存 package や source は変更せず、旧 manifest の形式移行だけを行います。
検査対象と target は `scripts/moon-check-plan.mjs` の plan から実行し、
独立 module・外部 example の一覧を一つの catalog で管理します。

`just publish` は `scripts/publish-moon-module.mjs` を通じて、公開検査用の
新しい cache にも旧 manifest の移行を適用します。通常の archive コンパイル検査を
実行し、失敗したら公開を停止します。module ごとの一時 adapter は終了時に削除し、
ローカル設定 `skills-lock.json` は staging と archive 検査の両方で配布対象から除外します。

## 開発フロー

1. 変更対象の設計/境界を確認する（`docs/architecture/architecture.md`, `docs/architecture/module_boundaries.md`）
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

`just check` は独立したエディタ、Wasm guest、同梱 GLFW も検査します。
外部の `../crater` を使う `crater_paint` / `browser_headless` は、
`just check-external-examples` で明示的に検査します。


必要に応じて smoke 実行も確認してください。

```bash
(cd examples/smoke/runtime_smoke && moon run src --target js)
(cd examples/smoke/runtime_smoke_native && moon run src --target native)
(cd examples/smoke/native_triangle && moon build src --target native)
```

## ドキュメント配置ルール

- ユーザー向け: `docs/user/`
- 開発者向け設計資料: `docs/`
- 貢献手順: `CONTRIBUTING.md`

機能追加時は、対象読者に応じてドキュメントを更新してください。
