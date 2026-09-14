# Landscape component benchmarks

ゲームに依存しない consumer package から、出荷する Kagura API を測定する。
`camera3d`、`draw3d`、`scene3d`、`terrain3d` を同じ呼び出し側で比較できる。

| ベンチ | 1 iteration の仕事 |
| --- | --- |
| `phase_camera_clear_64` / `phase_camera_blocked_64` | 約5mのブームを64本走査。地面・壁を模した軽い判定 |
| `build_visibility_tails_128` | 透過設定を128回、12 dwordずつ新しい配列へ追加 |
| `build_scenery_uniforms_128` | 異なる平行移動128個のlit uniform + 透過設定（各72 dword） |
| `build_skinned_draws_64` | 18骨・48姿勢から64体分の描画コマンドを作る（各1,084 dword） |
| `build_skinned_groups_8x8` | 8体ずつ8組の単色スキニングuniform（各2,088 dword） |
| `build_pose_bank_48x18` | 18骨の手続き的な姿勢を48フレーム焼き込む |
| `phase_cached_poses_64` | 焼き込み済み姿勢を64回参照する |
| `build_scatter_100x80` / `build_scatter_20x20` | 歪んだ密度場と優先度による樹木候補の配置 |

`build_` は出力配列やコマンドの構築・割り当てを含む。骨格、メッシュ、カメラ、
入力行列の準備は計測の外。反復ごとに出力を作り直し、配列全体を `b.keep` に渡す。
姿勢の焼き込みと配置生成は初期化時のコストであり、毎フレームの処理時間に足さない。
カメラのベンチは走査自体を測る。ゲームの地形サンプル・衝突検索のコストは含まない。
GPU送信・描画・フレーム全体の計測は `just hunter-map-profile` を併用する。

`fixtures_wbtest.mbt` は36インデックスの非空メッシュ、18骨、動く姿勢、128個の
uniform、非空の配置、遮蔽による早期終了を確認する。空の仕事を速さと誤認しない。
GPU ABIの全dword一致は `draw3d/skinning_uniform_wbtest.mbt` で検証する。

```sh
# 探索用。package-local と workspace 全体の結果は混ぜない。
just bench-landscape

# 正式比較。両方のcheckoutに同じベンチとfixtureを用意しておく。
# 既存 bench-gate と同じ moon bench --target js を、旧→新の順に3回ずつ実行。
just bench-paired --baseline-dir /path/to/before --runs 3 --out-dir output/landscape-paired
# 他のコンポーネントも同じrunnerで比較できる。
just bench-paired --baseline-dir /path/to/before --prefix draw3d/ --runs 3
```

`bench-paired` は全workspaceを実行した**後**で名前を絞る。
各回のログ、サンプル、実行環境、中央値・最小最大・新/旧比を保存する。
全サンプルの帯が分離した場合だけ `faster` / `slower`、重なれば `overlap` とする。
1つでも仕事が欠ける場合は失敗する。速度を合否にするCIゲートではなく比較用の道具。
計測中は別のビルド、テスト、ブラウザのプロファイルを同時に走らせない。

実測値とゲーム側の確認結果は
[性能レポート](../../docs/performance/landscape-components.md)を参照。
