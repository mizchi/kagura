# scene3d

シーングラフ、メッシュアセット、カリング、GPUスキニングの描画を提供する。
公開APIは `pkg.generated.mbti` を参照。

## 姿勢を一度だけ生成して共有する

`BakedSkinningClip` はスキニング行列の有限キャッシュ。
`new(skeleton, animation_clip, frame_count)` はアニメーションクリップをサンプルし、
`from_pose_sampler(skeleton, frame_count, sampler)` は手続き的に作った姿勢を取り込む。
両方とも同じ階層変換・逆バインド行列の処理とキャッシュを使う。

```moonbit
// アセット初期化時だけ実行。samplerはボーン数と同じ長さのローカル姿勢を返す。
let poses = @scene3d.BakedSkinningClip::from_pose_sampler(skeleton, 48, sample_rest_pose)
// 再生中はキャッシュの参照だけ。同じindexの個体はインスタンス描画を共有できる。
let matrices = poses.matrices(index)
```

手続き的なsamplerは0から順に、`max(frame_count, 1)` 回だけ呼び出される。
作業用の姿勢配列を使い回してよい。次の呼び出しより前に行列へ変換する。
アニメーションクリップの場合は最低2サンプルとし、開始・終了時刻の両方を含む。

`frame_index(phase)` は0〜1の位相を最も近い共有姿勢へ量子化する。
`matrices(index)` は範囲外のindexを端へクランプし、保存済みの行列配列を返す。
この配列は読み取り専用として扱い、個体ごとに変更しない。

敵の警戒状態、立ち上がりの時間、骨格固有の座り・伏せの角度はゲームやアセット側が所有する。
ASHEN REALMSでは二足・ゾンビ・狼の待機姿勢をこのAPIで生成している。
