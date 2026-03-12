# fal Trellis sample inputs

`hacknslash_3d` の `fal-ai/trellis-2` 試行用に、repo 内の既存 sample から用意した入力画像です。

- `gltf-viewer-test-scene.png`
  - source: `e2e/vrt.spec.ts-snapshots/gltf-viewer-darwin.png`
- `fetch-image-sample.png`
  - source: `examples/fetch_image/assets/sample.png`
- `fetch-image-sample-512.png`
  - source: `examples/fetch_image/assets/sample.png` を 512px に拡大
  - `fal-ai/trellis-2` で生成確認済み
- `chest-illustration.png`
  - repo 内で生成した単一物体の sample
  - Trellis に渡す入力としてはこれが一番安定

最短では次のように使えます。

```sh
just hacknslash3d-fal-trellis-sample chest
just hacknslash3d-fal-trellis-sample gltf-viewer
just hacknslash3d-fal-trellis-sample fetch-image
```

どちらも既定で `--preset hard-surface --preprocess isolate` を付けます。`isolate` は単一被写体を中央に寄せる前処理で、Trellis にそのまま生画像を渡すより shape が安定しやすいです。

`fetch-image` は既存の checkerboard input なので、Trellis の shape quality は高くありません。より良い 3D 形状を狙うなら、単一物体が中央に大きく写った入力を別途用意してください。

生成後は `hacknslash_3d` を次の URL で確認できます。

```text
http://127.0.0.1:3000/?generated_prop=./assets/generated/<name>.glb
```
