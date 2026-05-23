# gfx-mbt スナップショット (一時)

このディレクトリは `mizchi/gfx-mbt` リポジトリの完全な内容のスナップショット
です。kagura ブランチ上で path dep として参照できるように、また別リポへ抽出する
ための転送媒体として一時的にコミットされています。

## 別リポへ抽出する

```bash
# kagura branch を clone した手元の作業ツリーで
cd /path/to/some-workdir
cp -R /path/to/kagura/.gfx-mbt-snapshot gfx-mbt
cd gfx-mbt
git init -b main
git add -A
git commit -m "Initial commit: extract gfx_core from mizchi/kagura"

# GitHub にリポを作って push
gh repo create mizchi/gfx-mbt \
  --public \
  --source=. \
  --description="Backend-agnostic GPU command buffer & driver contracts for MoonBit (extracted from mizchi/kagura)" \
  --remote=origin \
  --push
```

## 抽出が終わったあと

このスナップショットは kagura では不要になるので、別コミットで削除し、各
`moon.mod.json` の `mizchi/gfx` path dep を mooncakes の version pin に切り替えてください:

```diff
- "mizchi/gfx": { "path": "../../../.gfx-mbt-snapshot" }
+ "mizchi/gfx": "0.1.0"
```

`git rm -r .gfx-mbt-snapshot && git commit -m "Drop in-tree gfx-mbt snapshot now that mizchi/gfx is published"`

## 何が入っているか

`README.md` を参照。
