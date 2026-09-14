# HUD・GPUスキニング・地形キャッシュの最適化

2026-09-14。`113fa970` を変更前として、HUD → GPUバッファ → 地形の順に実装。
ゲーム内容、表示範囲、頂点の情報量は維持する。

## 共通APIと採用した変更

### HUDの差分送信と検査snapshotの遅延生成

`engine/ui` の `JsonObjectPublisher` は、JSONオブジェクトのトップレベルの値を比較し、
変更のない場合は `None`、変更時は次のJSON文字列を返す。

```json
{"full":false,"set":{"hp":13},"remove":["notice"]}
```

初回と `reset()` 後は `full:true`。`null` は値として扱い、削除は `remove` で指定する。
保持する値は深くコピーするため、呼び出し側が配列・オブジェクトを書き換えても差分を検出する。
ブラウザーは `@kagura-web/kagura-ui-sync.js` の `applyObjectPatch` を使い、
変化していない配列やオブジェクトの参照を維持する。
`createDependencyGate` は入力が変わった描画だけを実行するための小さな共通ヘルパー。
ゲームは閉じたメニューの大きなsignature生成も省略する。
パッドへの切り替えは別途検出し、HUD値が一定でも操作ガイドを更新する。
HUDのビュー構築と構造比較自体は引き続き毎フレーム行う。

JSの `publish_ui_snapshot_lazy(() => snapshot)` は検査要求が来るまでsnapshotを構築しない。
既存の `globalThis.__kaguraUISnapshot` の `{json, parsed}` 契約は維持する。
同じpublicationを複数回読む場合は一度だけ生成し、次のpublicationで無効化する。
通常の eager publisher と既存の代入によるリセットも併用できる。

### GPUスキニングの永続バッファ

`assets/web/kagura-gfx.js` が描画スロットごとに入力頂点・計算結果・compute uniform・
render uniformを保持する。インデックスと描画bind groupも既存キャッシュを使用する。
バッファは容量不足の場合に拡張し、GPUリソースの解放時に破棄する。

- 同じ姿勢とgeometry：追加確保・upload・compute dispatchはゼロ。
- カメラ/MVP/照明だけの変更：render uniformだけ更新。
- 骨の変更：compute/render uniformを更新し、再スキニング。
- 頂点の変更：geometryを更新し、再スキニング。非immutable配列のin-place変更も検出する。
- 小さなmeshへの変更：容量を再利用し、bindingの範囲を実際の頂点数に合わせる。

このcompute経路は1,084 dwordのsingle-mesh uniform layoutと、明示的なpre-skinned分岐を
持つshader専用。インスタンス描画は従来通りvertex shaderでスキニングする。
ゲーム全体のCPU改善率を、このcompute経路だけの改善率としては扱わない。
Nodeの操作数テストと、実WebGPUの画像readbackで変更のない姿勢・骨の平行移動・
バッファ再利用・二重スキニングの回避を確認した。

### 静的地形のインデックス範囲選択

`scene3d.StaticMeshBatch::new(meshes)` は、同じ頂点形式のメッシュを一度だけ結合し、
各入力に対応する `StaticMeshSpan {first_index, index_count}` を保持する。
異なる形式、不完全な頂点/三角形、範囲外インデックスは `None` で拒否する。
`select(visible)` は可視範囲を選び、連続している範囲をまとめる。
選択処理では頂点もインデックスもコピーしない。生成後のgeometryは不変として扱う。

ゲームは地域ごと・材質ごとにこのバッチを用意し、既存の `index_offset` 付き描画を使う。
準備は隣接地域の生成を優先し、その仕事がない更新で1材質ずつ進める。
未完成の材質は元のチャンクを描くので、準備中や早いタイミングの地域移動でも欠けない。
地形の再生成時には同じseedでもキャッシュを破棄する。
SSAOの深度は可視チャンクの既存メッシュを使い、深度用の巨大な結合も行わない。
屋内の既存shadow batchingは維持する。

## 比較計測

Apple M5 / macOS arm64、Node v24.21.0、Chrome 152 / Metal、1280×900、seed 42。
同じJS debugビルド設定の変更前を8082、変更後を8080で配信した。
各場面240フレーム、3組を `旧→新、新→旧、旧→新` の順に実行。
計測中にビルドや別のブラウザーテストを実行していない。
7場面は開始後にpauseした描画負荷、`streaming` は実際に歩いて隣接地域へ移動する負荷。
CPUはCDPのTaskDurationを描画フレーム数で割った値。
GPUはtimestamp-queryのp95。各runの集計値をさらに中央値で比較した。

実行例（各組で実行順を反転）：

```sh
just hunter-map-profile --url http://localhost:8082/ --out-dir output/render/1-before
just hunter-map-profile --url http://localhost:8080/ --out-dir output/render/1-after
```

各runの集計値・測定帯・描画量は [JSON](render-caches-bench.json) に保存。
フレームごとの生データ、CPU profile、スクリーンショットはローカルの `/tmp/render-paired/`。
以下のCPU値はrun間中央値 [最小, 最大]、draw callsはrun内p50の中央値、
GPUはrun内p95の中央値。

| 場面 | CPU変更前 ms [範囲] | CPU変更後 ms [範囲] | 短縮 | draw calls 前→後 | GPU p95 前→後 ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| flat | 3.67 [3.56, 3.68] | 2.36 [2.08, 2.53] | 35.8% | 69→91 | 2.32→2.82 |
| expedition | 3.76 [3.70, 3.78] | 2.53 [2.05, 2.81] | 32.9% | 80→108 | 2.93→3.22 |
| highland | 3.99 [3.98, 4.18] | 2.61 [2.58, 2.75] | 34.6% | 130→191 | 2.46→3.31 |
| streaming | 3.92 [3.85, 4.04] | 3.48 [3.44, 3.68] | 11.1% | 85→115 | 2.35→1.46 |
| panorama | 3.14 [3.02, 3.20] | 1.80 [1.64, 2.39] | 42.8% | 55→83 | 2.71→3.22 |
| cave | 3.12 [2.74, 3.16] | 1.76 [1.47, 2.34] | 43.8% | 54→70 | 2.86→3.66 |
| occlusion | 3.15 [3.01, 3.22] | 2.06 [1.70, 2.60] | 34.7% | 61→85 | 3.08→3.04 |
| camp | 3.57 [3.27, 3.61] | 2.14 [1.82, 2.31] | 39.9% | 81→105 | 2.38→3.13 |

8場面すべてでCPUの測定帯が改善側に分離した。各場面のインデックス数p50は全6runで一致。
野営地は全runで246,432インデックス。変更前後の画像も照合し、木・柵・地面・敵の欠落が
ないことを確認した。CPU短縮はこの描画・移動条件での結果であり、戦闘全体や他のGPUへの
同率改善を意味しない。

境界移動の描画コールバック最大値は、旧 `[29.5,32.8,24.9]` ms、
新 `[2.6,3.7,3.6]` ms。run間中央値は **29.5→3.6ms（87.8%短縮）**。
RAF最大は旧33.2〜33.3ms、新は全runで16.8ms。大きなメッシュ再結合による引っかかりを
今回の条件では解消した。

## トレードオフと残る負荷

静的な範囲を分けて描くためdraw callsは増える。GPU時間の改善は全体として主張しない。
特にhighlandのGPU p95は旧2.00〜2.52ms、新3.07〜3.58ms、campは旧1.50〜2.79ms、
新2.96〜3.37msで、遅い側に帯が分離した。他の6場面のGPU測定帯は重なる。
全runのGPU p95は3.81ms以下だった。highlandは隣接地域の準備後にpauseするため、
進行中の材質準備の位置によって新方式のdraw callsが191〜194になるが、インデックス数は一致する。

地形のGPUバッファは地域全体の材質を保持するため、可視範囲だけを結合する方式とは
常駐量が異なる。3地域の常駐上限と既存の未使用geometryバッファの回収を利用する。
モバイルGPUとnativeでの実時間性能は今回測定していない。

地域生成・チャンク生成自体は依然として更新処理にあり、streaming中のupdate最大は
新11.9〜16.4ms。今回の地形バッチ準備も1材質単位の処理で、厳密な時間上限ではない。
さらに改善するなら、この生成処理を分割するとともに、地形のdraw callsとGPU常駐量を
減らす方式を比較する。

## 検証

- `just hunter-test`：MoonBit 732件、関連Nodeテストが成功。
- JSゲームの警告なしcheck、workspaceとゲームのnative警告なしcheckが成功。
- `atmosphere.spec.ts` / `camera.spec.ts` / `landscape.spec.ts` /
  `hud-sync.spec.ts` / `skinning-cache.spec.ts`：実GPUで18件成功。
- 全8場面×6runでJSエラーなし。橋・海岸・洞窟・TPS透過・空・モバイルカメラ・
  HUDメニュー・遅延snapshot・SSAO有効の範囲描画を確認。
