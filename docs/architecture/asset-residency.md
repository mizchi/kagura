# Asset Residency Strategy

アセットの常駐戦略を 3 層に分離する。

## 層構造

| 層 | 責務 | ライフサイクル | Budget |
|----|------|---------------|--------|
| **Raw Bytes** | fetch 結果の生バイト列 | `AssetStreamer` の `Delivered` 状態で即座に解放 | なし (即時解放) |
| **Decoded Data** | decode 済みの ImageSpec / ShaderSpec / MaterialSpec | `AssetKey` → Repository (Map) で保持 | `max_cached` (AssetStreamerConfig) |
| **GPU Resource** | ImageHandle / ShaderHandle | グラフィックスドライバが管理 | ドライバ依存 |

## ライフサイクル

```
fetch → Raw Bytes → callback → Decoded Data → GPU upload → GPU Resource
         ↓ (即解放)            ↓ (LRU eviction)    ↓ (driver管理)
       Delivered状態         on_evict callback     dispose
```

## 設計判断

1. **Raw Bytes は持たない**: `AssetCompletion::Delivered` で全 callback 発火後にバイト列を解放。late request には `None` を返す。re-fetch が必要なら caller が明示的に再リクエスト。

2. **Decoded Data は LRU**: `AssetStreamer` の eviction sweep (configurable interval) で `max_cached` を超えた古いエントリを除去。`touch()` で延命。`evict()` で即時除去。

3. **GPU Resource は分離**: decoded data → GPU upload は caller の責務。GPU 側のメモリ管理はグラフィックスドライバに委ねる。

## 関連コード

- `modules/asset_loader/streamer.mbt` — AssetStreamer, eviction, Delivered state（`mizchi/kagura_asset_loader`、kagura_engine から抽出済み）
- `src/asset/contracts.mbt` — AssetKey, ImageSpec, Repository types
- `modules/asset_loader/stream_manager.mbt` — priority queue, concurrent fetch
