# IRON YARD 性能計測 — 2026-09-10

## 第3段階：描画ブリッジとbind groupの一時生成削減

Playwrightと性能計測を既定でヘッドレス化した。Chrome 152 / Apple M5 / Metal、1920×1200・MSAA 4・演習3機は同じだが、今回のrAFは60 Hz。**以下は前回版もヘッドレスで測り直した比較**であり、下記の120 Hz計測と毎秒の割り当て量を直接比較しない。production出力を保存し、各版を順番に8秒×3回測定した。CPU・割り当てプロファイルはFPS採取後の別区間。

| 静止演習・ヘッドレス | 前回版 | 今回版 | Three.js |
|---|---:|---:|---:|
| CPU時間 / rAF | 1.66 ms | **1.31 ms** | 4.04 ms |
| FPS | 60.0 | 60.0 | 60.0 |
| フレーム間隔 p95 | 16.8 ms | 16.7 ms | 16.8 ms |
| 一時割り当て推定量 | 82.8 MB/s | **69.5 MB/s** | 50.9 MB/s |
| JSヒープ（GC後） | 17.79 MB | 17.84 MB | 21.74 MB |
| backing storage | 34.96 MB | 34.96 MB | 7.53 MB |

CPU時間は約21%、一時割り当ては約16%減少。保持メモリはほぼ同じ。描画回数350、インスタンス882、共有geometry buffer 306本も維持している。GPU timestampは2.53→2.64msだったが、今回の変更対象はCPU側であり、GPU改善を示す結果ではない。

左右移動でも8秒×3回を比較し、CPU時間1.65→1.20ms、p95 16.8→16.7ms、両版60 FPS。計測前後とも演習3機を維持し、描画エラーはなかった。

- **描画ブリッジ**：`submitCustomDraw`でMoonBitの借用配列と描画引数を直接プールへ渡す。毎描画のdescriptor、geometryのspread、`Object.assign`を除いた。uniform・texture IDのコピーは同期的に完了し、以後の元配列変更からキューを保護する。
- **bind group**：実際のtexture viewとsamplerの同一性を比較し、キャッシュに一致した描画では記述子配列やtexture-key文字列を作らない。sampler/viewだけが変わってrevisionが同じ場合も正しく再bindする。テクスチャへのピクセル更新だけでは再作成しない。
- **バックグラウンド検証**：Metal E2Eもヘッドレスを既定とし、Apple/Metalをテストで検査する。ボタン有効化とGPU初回描画の間の競合は、描画ターゲットの準備を条件として待つことで解消した。ウィンドウ付きの実行は`IRON_YARD_HEADED=1`、プロファイルは`--headed=true`で明示できる。

Node GFX 30件、web_runtime_hooks 776件、draw3d/shadow3d/postfx 61件、audio 49件が成功。ヘッドレスのMetal Playwrightは14件成功し、深度、影、反射、sRGBの数値比較を維持している。

8秒のCPUプロファイルでは、残る上位のself timeはコマンドのバッチ化・コピー約39ms、シェーダー種別判定約39ms、影のuniform生成約28ms。以前のdescriptor生成を伴う描画ブリッジは上位から消えた。関数分割・インライン化で帰属も変わるため、関数単体の速度倍率ではなく上表のフレーム全体を改善指標とする。

測定データは`test-results/iron-yard-bridge-idle/`、移動時は`test-results/iron-yard-bridge-strafe/`。前回版の保存出力は`index-BObR5Ueq.js`、今回版は`index-BKgs-jfy.js`。

## 第2段階：世代管理・保存領域再利用・インスタンシング

同じChrome / Metal / 解像度 / MSAA / 演習3機で、今回の修正前のproduction出力を保存し、最終版とThree.jsを順番に比較した。5秒ウォームアップ後、8秒×3回の中央値。FPSとCPU・割り当てのプロファイルは別区間。今回の「修正前」は下記第1段階の完了版であり、`91b59b2`ではない。

| 静止演習 | 今回の修正前 | 今回の修正後 | Three.js |
|---|---:|---:|---:|
| FPS | 120.0 | 120.0 | 120.0 |
| フレーム間隔 p95 | 8.9 ms | 9.0 ms | 8.8 ms |
| メインスレッド時間 / rAF | 3.57 ms | **2.06 ms** | 3.71 ms |
| GPUコマンドのエンコード・送信 p50 | 0.60 ms | 0.50 ms | 未計測 |
| GPU timestamp p50 | 3.13 ms | 2.77 ms | 未計測 |
| draw / frame | 882 | **350** | 未計測 |
| 一時割り当ての推定量 | 334 MB/s | **161 MB/s** | 94 MB/s |
| GC後のJSヒープ | 19.81 MB | 18.79 MB | 22.44 MB |
| backing storage | 32.62 MB | 34.96 MB | 7.53 MB |

CPU時間は約42%、描画回数は約60%、割り当て推定量は約52%減少した。FPSは画面の120 Hz上限なので、最大FPSの優劣はこの試験からは言えない。GPU値は全パス合計で、端末状態にも左右される。Three.js側のGPU timestampは取得していない。

割り当て推定量はChromeの8秒間のサンプリング値であり、保持メモリやリーク量ではない。uniformの保存領域を保持するため、JSヒープ＋backing storageは52.43→53.75 MBと約1.32 MB増えた。実行時間・GC負荷を下げるためのトレードオフである。GPUの頂点・インデックスは登録済み153メッシュに対して306バッファとなり、影・本描画・同型機で共有する。

左右移動（A/Dを1秒ごとに切り替え、8秒×3回）でも、CPU時間は3.85→2.24ms、FPSは両方120、p95は両方9.3ms。Three.jsはCPU 4.29ms、FPS 120、p95 9.2msだった。

GPUメモリについて、左右移動の実際の確保サイズは頂点・インデックス9.13→1.77 MB、uniform 0.21→2.66 MB。合計9.34→4.43 MB。これは追跡しているGPUBufferのサイズであり、テクスチャ・MSAA・深度ターゲット・ドライバー内部を含むVRAM全体の値ではない。

左右移動のGPU timestampは一度3.61→4.27msとなったため、uniform構造体の展開を避けるWGSL直接参照版でも検証した。6秒×3回の再比較では構造体版2.89ms、直接参照版3.19ms、修正前4.48msとなり、直接参照版の優位を確認できなかった。構造体版でも2.89〜4.27msの差が出るため、GPU時間の増減をこの変更だけに帰属させない。直接参照版は不採用とし、元の構造体版を維持している。GPUの改善率は確定値として扱わない。

### 実装と検証

1. **メッシュID＋revision**：登録時だけf32/u32へ変換し、毎フレームの全頂点・インデックス比較をなくした。revision更新前のキューは古いスナップショットを保持する。静的アセットは自動IDを使い、動的利用には明示的な登録・更新・解除APIを用意した。未登録の既存呼び出しは内容比較を維持する。
2. **保存領域の再利用**：MoonBitのPBR uniformに呼び出し側のstorageを渡せるようにした。JS描画コマンドとtyped arrayもフレーム間で再利用する。GPUへ送ったuniformは別のコピーで比較し、in-place更新を取り逃がさない。
3. **共有とインスタンシング**：登録済みメッシュのGPUバッファを描画位置に依存せず共有。Standard/depth WGSLは最大32件のuniform配列に対応し、隣接する互換な不透明描画をまとめる。同型機の不透明部分はメッシュ単位で提出し、透明部分は順序を保つ。

再プロファイルで見つかったバッチ用uniformの未使用領域比較も削除した。共有GPUキャッシュは登録済みメッシュに限定し、毎フレーム作られる小さな全画面メッシュで増え続けないようにした。未使用の共有バッファは最大240描画フレーム以内に破棄する。

APIの所有権・寿命・WGSL制約は[GEOMETRY.md](../../../assets/web/GEOMETRY.md)に記載。Metal E2E 14件、GFX Node 28件、web_runtime_hooks 776件、draw3d/shadow3d/postfx 61件、audio 49件、ゲームMoonBit 10件とNode 11件が成功。PBRの数値比較はinstance index 0以外も検証し、元のThree.jsの色・反射・PCFと一致する。

### Wasm SIMD

[リンク先gist](https://gist.github.com/mizchi/9fb6627ffa370f55d482c82bc8d36fcf)を参考に、Zig 0.16でf64x2のMVPカーネルを作成した。演算順を維持し、最終出力のみf32へ丸める。スカラーWasm、SIMD、`wasm-opt -Oz`をChromeで比較し、実オペコード・import/export・境界値を検査した。

882行列を連続メモリで一括処理すると、コピー込みでJS 37.4µs→SIMD 9.2µs。一方、通常配列を1描画ずつ渡すとJS 95.6µs→SIMD 275.6µsと遅くなった。このため本番への逐次置き換えは採用していない。`just iron-yard-simd`で再実行できる。[実験の詳細](experiments/simd/README.md)にはビルド条件・サイズ・比較表を記載。

### 計測データと残る負荷

- `test-results/iron-yard-batching-final-idle/`：最終静止比較、CPUプロファイル、割り当て、スクリーンショット。
- `test-results/iron-yard-batching-final-strafe/`：最終左右移動比較。
- `test-results/iron-yard-simd/`：SIMDのWasm/WAT/測定値。
- `test-results/iron-yard-instance-shader-strafe/`：WGSL構造体版と直接参照版の比較。実験用adapterも保存。
- `test-results/iron-yard-batching-idle/`：中間版。未使用uniform領域比較がCPUホットスポットになったことを確認した測定。

CPU側に残る最大のself timeはMoonBit→JS描画ブリッジで、8秒のプロファイル中約410ms。次がコマンドのバッチ化・コピー約166ms。型付きスナップショットの全メッシュ走査はホットスポットから消えた。bridgeの一時descriptor、bind group記述子、影のuniformや行列の生成はまだ割り当てを伴う。GPUは全体約2.8msであり、影・本描画・MSAAのどこが支配的かはパス別計測が必要。

音声PCMのプレイヤー間共有と、長時間・ウェーブ切り替え・繰り返しアセットロードの保持メモリ検証は引き続き残る。

## 第1段階：初回プロファイルと改善

Chrome 152.0.7977.83 / Apple M5 / Metal、1280×800 CSS px、DPR 2、実描画1920×1200、MSAA 4。演習モードで出撃し、5秒ウォームアップ後に8秒×3回。独立したChromeプロファイルで各版を順番に起動した。FPS採取とCPU・メモリのサンプリングは別区間。

比較元はKagura `91b59b2` の隔離worktreeと、modeling-playground `aa7ab3e` のゲーム（Three.js 0.185.1）。すべてVite productionビルド。KaguraはMoonBit release。以下は3回の中央値で、メモリはFPS採取後にGCした値。単位MBは10進。

| 静止演習 | Kagura 修正前 | Kagura 修正後 | Three.js |
|---|---:|---:|---:|
| FPS | 55.3 | 119.9 | 120.0 |
| フレーム間隔 p95 | 25.2 ms | 9.2 ms | 9.1 ms |
| メインスレッド時間 / rAF | 18.15 ms | 6.15 ms | 4.28 ms |
| GPUコマンドのエンコード・送信 p50 | 6.3 ms | 1.0 ms | 未計測 |
| JSヒープ | 67.74 MB | 19.89 MB | 22.90 MB |
| backing storage | 34.89 MB | 32.62 MB | 7.53 MB |

左右移動でも、同じ3機の標的を残したままA/Dを1秒ごとに交互入力し、8秒×3回を計測した。

| 左右移動 | Kagura 修正前 | Kagura 修正後 | Three.js |
|---|---:|---:|---:|
| FPS | 67.1 | 120.0 | 120.0 |
| フレーム間隔 p95 | 17.6 ms | 9.2 ms | 9.0 ms |

「メインスレッド時間 / rAF」はChrome `TaskDuration`の差分をフレーム数で割った値。シミュレーション、コマンド生成、音声、DOMなどを含む。120 FPSはこの画面の更新レートによる上限であり、上限を外した最大性能が同等という意味ではない。GPU時間は端末状態でばらつきがあり、Three.js側のGPU timestampを採っていないため比較表から除外した。

JSヒープだけを見ると音声配列の移動を見落とす。`Float32Array`化によって一部はbacking storage側へ移っている。この2項目の合計はKaguraで102.63→52.51 MB。Chromeプロセス全体やGPU VRAM、WebAudio内部メモリを網羅する値ではない。

## プロファイルから修正した箇所

- **MoonBit→JSの描画ブリッジ**：頂点・インデックス・uniformを一要素ずつFFIで渡していた。JS用の借用配列ハンドルで一括転送する。頂点とインデックスはWeakMap内の型付きスナップショットと比較し、不変なら再変換・再アップロードを省略する。元配列を変更した場合は新しいスナップショットを作り、すでにキューへ入った描画の内容を保持する。
- **uniformとシェーダー処理**：同内容のuniform再送信を省略。WGSLのtexture binding・skinning判定はpipeline作成時に解析する。raster stateのキー生成で毎回JSONを作らない。
- **影のキャッシュキー**：全頂点を毎フレームハッシュしていた。内容の変更を検出するJSレンダラーでは`cache_resources=false`を使う。他の呼び出し元の既定動作は維持する。
- **共通パラメーター**：固定の環境光・影行列をApp初期化時に計算する。PBR uniformは必要な72/84/92/104要素を一度に確保し、途中の配列拡張をなくす。
- **変更検出のループ**：再プロファイルでは汎用変換コールバックが大きな負荷になった。頂点とインデックスの比較を別の関数にして、要素ごとの間接呼び出しを除いた。
- **音声PCM**：ヒープの最大領域はBGMの通常配列36,813,928 bytesだった。JSで`FixedArray[Float]`を`Float32Array`として確保し、BGMの保持領域は18,406,960 bytesになった。16-bit PCMの全65,536値について従来の変換値との一致をテストした。native側の実装もテストした。

予備計測のスクリプトには、初期化完了前に演習モードを選んでしまう待機不備があった。Kagura側が敵AIモードとなり比較条件が揃わなかったため、予備計測は性能比較には使わない。修正後は出撃ボタンの有効化を待ち、FPS・プロファイル採取の前後で「演習モード・稼働中・生存標的3機」を検査する。

## 計測データ

リポジトリルートの`test-results/`以下に保存。大きいChromeプロファイルはgit管理外。

- `iron-yard-verified-idle/`：3版の条件を検査した最終比較。CPU・割り当て・ヒープスナップショット・FPS・スクリーンショット。
- `iron-yard-verified-strafe/`：A/D交互入力での最終比較。
- `iron-yard-before/`、`iron-yard-production/`、`iron-yard-production-three/`、`iron-yard-heap/`、`iron-yard-final/`、`iron-yard-strafe/`：負荷箇所を探索した予備計測。モード不一致のため比較表には不採用。ヒープ上の保持元とCPUホットスポットの調査に使用した。

`just iron-yard-profile`の使い方は[README](README.md#chromeでの性能比較)を参照。

## 検証

- Metal / productionのPlaywright E2E 14件成功。移動・ジャンプ・射撃・敵AI・UIに加え、道路とモデルの深度、影、ACES/PBR/sRGBの数値比較を含む。
- GFX runtimeのNodeテスト22件成功。頂点をin-placeで変更しても先にキューへ入れた描画を壊さず、変更したuniformだけを再送信することを検証。
- draw3d / shadow3d / postfxのMoonBitテスト60件成功。
- 音声テストJS 49件 / native 48件成功。全16-bit PCM値の一致を含む。
- ゲームのMoonBit 10件、モデル・ヘッドレスのNode 11件成功。対象パッケージのwarning-free checkと`git diff --check`も成功。

リポジトリ全体のテストは対象外。audioを無指定で実行した際は、既存physics3dの`Array(capacity=...)`コンパイルエラーに当たったため、変更したaudioパッケージを明示して検証した。
