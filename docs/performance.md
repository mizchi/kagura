# Kaguraの描画性能を計測・改善する

ゲーム固有の入力や画面遷移と、エンジンの描画・計測を分離する。
共通部品の契約は `just game-components-test` で検証できる。

## 計測

起動済みのKaguraゲームをURLで指定する。

```sh
just profile-web --url 'http://localhost:8080/?snapshot=playing&seed=42' --out-dir output/cpu/before
just profile-web --url 'http://localhost:8080/?snapshot=playing&seed=42' --out-dir output/cpu/after
```

このコマンドはゲームのキー入力やクエリパラメーターを変更しない。
`--width`、`--height`、`--samples` で表示サイズとサンプル数を指定できる。
ブラウザ・画面サイズ・シード・カメラ・描画設定・操作を揃えて比較する。
タイトル画面と戦闘中など、負荷の異なる状態の結果は分けて扱う。

計測はウォームアップ、フレーム処理時間の取得、CPUサンプリングの順に行う。
フレーム処理時間を取得し終わってからChromeのCPUサンプリングを開始するため、
サンプリングの負荷がフレーム当たりのCPU時間へ混ざらない。
実際にGPUへ送信したフレーム番号で重複するRAF観測を除き、送信フレーム数でCPU時間を割る。

| 出力 | 内容 |
| --- | --- |
| `summary.json` | CPU時間、フレーム間隔の平均・p95、描画の各段階、実行条件、負荷の高い関数 |
| `samples.json` | 個々の観測。飛ばされた送信フレームは `frameDelta` で確認できる |
| `profile.cpuprofile` | Chrome DevToolsで開けるコールグラフ。関数の自己時間はサンプルの時間差で集計 |

ゲーム固有の再現操作は薄いアダプターに置く。

```js
import {profileWeb} from './scripts/profile-web.mjs';

await profileWeb({
  url: 'http://localhost:8080/?seed=42',
  outDir: 'output/cpu/scene',
  metadata: {scenario: 'same-camera'},
  async prepare(page) {
    // ゲーム固有の開始・一時停止・移動だけを指定する。
  },
});
```

ASHEN HUNTの `just hunter-cpu-profile` はseed=42で画面を固定するアダプター。
`--moving` は移動・アニメーション・地形の切り替えを含める。

## 共通フレーム情報

Web描画ヘルパーを導入すると `globalThis.__kaguraProfiler` を利用できる。
ゲーム固有のグローバル変数やHUDは不要。

```js
const profile = globalThis.__kaguraProfiler;
if (profile?.version === 1) {
  const frame = profile.snapshot();
}
```

`snapshot()` はGPU未作成時には `null`、作成後には独立した読み取り専用オブジェクトを返す。
取得できない時間も `null` とし、0msと区別する。履歴はエンジン側で蓄積しない。

| フィールド | 意味 |
| --- | --- |
| `version` / `frame` | 契約バージョン1 / 成功したGPU送信の通し番号。シミュレーション停止中も進む |
| `updateMs` | `engine.run` のupdateとon_frameコールバックのCPU時間 |
| `drawCallbackMs` / `renderCommandsMs` | 描画コマンドの生成 / バックエンドへの送信 |
| `renderCpuMs` | WebGPUのエンコード・submit処理のCPU時間 |
| `renderUploadCpuMs` / `renderBindGroupCpuMs` | バッファ更新 / bind group準備のCPU時間 |
| `gpuFrameMs` / `gpuTimingMethod` | 最後に完了したGPU計測と、その方法。timestamp-queryとqueue-completionを区別 |
| `drawCalls` / `indexCount` | バックエンドに渡したコマンド数 / 各コマンドのインデックス数の合計 |
| `instanceCount` | コマンドごとのインスタンス数の合計 |
| `sharedGeometryDraws` / `residentGeometryBuffers` | 共有ジオメトリの描画数 / 保持中の共有GPUバッファ数 |

GPU時間は非同期の直近サンプルであり、CPU時間と同じフレームに完了するとは限らない。
queue-completionはキューの完了待ち時間を含む。計測方法の異なる値を直接比較しない。
独自のフレームループを使うゲームでもGPU側の項目は取得できる。

## 再利用できる最適化

### 変わらないジオメトリを登録する

```moonbit
@web_hooks.register_static_geometry(mesh.vertex_data, mesh.indices)
```

不変の配列の組を登録すると、以後は全頂点の比較をせずGPUバッファを再利用する。
登録は定数時間で再確認でき、GPU再作成にも対応するので描画直前に呼んでよい。
地形の入れ替えでは配列を置き換える。弱参照の登録と未使用GPUバッファの回収により、
過去の地形チャンクを保持し続けない。

CPUで変形する配列にはこの登録を使わず、通常の値比較付きスナップショットを使う。
同じ配列を変更しても、先にキューへ入れた描画の内容は保たれる。
明示的なIDと更新番号が必要なJS側の利用者には `registerGeometry` / `unregisterGeometry` もある。

### 必要なポーズだけCPU変形する

```moonbit
let asset = @scene3d.SkinnedMeshAsset::new(mesh, skin)
// GPU変形: asset.packed_vertex_dataとasset.bind_mesh.indicesを使う。
// CPU変形が必要な描画だけ、ポーズの更新番号を指定する。
let posed_mesh = asset.skinned_mesh(pose_revision, skinning_matrices)
```

バインド形状は不変として扱う。CPU頂点バッファは最初の要求時に作り、
同じポーズ番号では再計算しない。別のアニメーションや骨格に切り替える場合も番号を変える。
同時に異なるポーズを持つキャラクターには別のassetを使う。
戻り値のCPU頂点バッファは次回の変形まで借用でき、古いポーズを保持するときはコピーする。
`cpu_skin_count()` で実際の変形回数を確認できる。

材質ごと・同じポーズの群れごとにassetを持つことで、未表示モデルや結合モデルの
不要な変形を避けられる。ゲームは色・装備・AIを、エンジンはバッファとキャッシュを所有する。

### 消費されない描画パスを生成しない

`RenderPipeline3D::compose_postfx` はSSAOが無効ならカメラ深度を生成しない。
バックエンドがバッファの変化を検出する場合は `cache_resources=false` により、
カメラ深度・影のためだけに行う全頂点ハッシュも省ける。
デフォルトでは他のバックエンド用のキャッシュキーを維持する。

### 計測結果から次の処理を選ぶ

コマンド生成が重い場合は、不要なパス、メッシュの再構築、スキニングの重複を見る。
送信が重い場合は配列走査・コピー・型変換、WebGPUの準備が重い場合はバッファとbind groupの再作成を見る。
GPU側が重い場合はピクセル数、重なり、インスタンス数、影・ポスト処理を確認する。
変更後は同じシーンで再計測し、移動・戦闘・リサイズ・地形の入れ替えも検証する。
