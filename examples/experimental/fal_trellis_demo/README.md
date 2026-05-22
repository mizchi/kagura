# fal_trellis_demo

`fal-ai/trellis-2` を使って画像から GLB を生成し、その結果をそのまま Kagura 上で確認するための独立 example です。

## 起動

```sh
just dev fal_trellis_demo
```

既定では `./assets/generated/gltf-viewer-proxy-chest-trellis.glb` を表示します。

明示的に asset を指定する場合:

```text
http://127.0.0.1:3000/?asset=./assets/generated/your-model-trellis.glb
```

`hud=0` を付けると HUD を隠せます。

## Fal 生成

`~/.zshenv` などで `FAL_KEY` / `FAL_API_KEY` / `FAL_AI` のいずれかを用意してください。

```sh
source ~/.zshenv
just fal-trellis-demo-generate image=examples/fal_trellis_demo/assets/fal_samples/gltf-viewer-proxy-chest.png
```

sample 入力から生成する場合:

```sh
source ~/.zshenv
just fal-trellis-demo-generate-sample proxy-chest
```

生成物は `examples/fal_trellis_demo/assets/generated/*.glb` に保存されます。

## 事前処理

CLI は `--preprocess isolate` と `--preset hard-surface` を受けられます。

例:

```sh
source ~/.zshenv
just fal-trellis-demo-generate-sample proxy-chest extra='--preset hard-surface --preprocess isolate'
```
