# 物理エンジン調査メモ (2025-2026)

kagura の physics2d/physics3d の改善方針を決めるための調査。
Rapier, Box2D v3, Jolt Physics, PhysX 5 など最新の物理エンジンのアプローチを比較する。

## 現代ソルバーの潮流: TGS Soft が主流に

2024-2025 で最も大きな変化は **TGS Soft (Temporal Gauss-Seidel + Soft Constraints)** への収束。
Box2D v3, Rapier, Avian (Bevy) が独立して同じ結論に到達した。

### TGS Soft の3要素

1. **Temporal substepping**: 反復回数を増やすのではなくサブステップ数を増やす。各サブステップで速度積分を挟むため、位置フィードバックが得られ収束が速い
2. **Soft constraints**: Baumgarte の代わりに減衰調和振動子（バネ-ダンパー）モデル。Hz と damping ratio で制御。エネルギー注入がない
3. **Relaxation**: バイアスなしの追加ソルブパスで余剰エネルギーを除去

### なぜ TGS Soft が勝つのか (Catto の Solver2D 比較)

Erin Catto が PGS, PGS_Soft, TGS_Soft, NGS, XPBD を同一条件で比較:
- TGS Soft は同じ constraint loop 予算でほぼ全テストで最良
- XPBD より安定（位置ベースの overlap 解決で爆発しない）
- PGS より高 mass ratio に強い

### XPBD の退潮

- 剛体接触では TGS Soft に劣る（ドリフト、overlap 解決の爆発）
- NVIDIA 特許の問題
- Avian が XPBD → TGS Soft に切り替え（接触は TGS Soft、ジョイントは XPBD 残存）
- ソフトボディ・布には依然として有用

---

## エンジン別アーキテクチャ

### Rapier (Rust, 2D/3D)

| 項目 | 内容 |
|------|------|
| ソルバー | TGS Soft (v0.22 で導入、v0.23 で PGS 廃止) |
| 反復数 | 4 solver iterations x 1 internal PGS iteration |
| Broadphase | Dynamic BVH (2025年に SAP から移行、SIMD 加速) |
| Narrowphase | GJK + EPA (Parry)、単純形状は SAT fast path |
| Contact | Persistent manifold (max 4 点)、warm starting (係数 1.0) |
| Island | Persistent islands (フレーム間で再構築しない) |
| Sleeping | 速度閾値ベース、island 単位 |
| CCD | サブステップベース |
| 2025 成果 | manifold 4点制限、3D 摩擦簡略化 (25% 高速化)、Dynamic BVH、persistent islands |

### Box2D v3 (C99, 2D)

| 項目 | 内容 |
|------|------|
| ソルバー | Soft Step (= TGS Soft)。v2 の PGS + Baumgarte から完全刷新 |
| サブステップ | コア設計。接触点をローカル座標で保持し、サブステップ中の衝突再検出不要 |
| Broadphase | 内部実装 (詳細非公開) |
| SIMD | Graph coloring で制約をグループ化 → AVX2/SSE2/NEON で 4-8 制約同時解決 |
| API | C99 ハンドルベース、ポインタ廃止 |
| マルチスレッド | タスクコールバック方式（エンジンはスレッド非所有） |
| 性能 | AVX2 で scalar 比 2x、v2.4 比 2x+ |

**Box2D v3 の重要な設計判断:**
- 接触点をボディローカル座標で保持 → サブステップ中の分離距離を安価に再計算
- Baumgarte → soft constraints (減衰調和振動子)
- シリアル TOI → ハイブリッド speculative + TOI (マルチスレッド可能に)

### Jolt Physics (C++, 3D)

| 項目 | 内容 |
|------|------|
| ソルバー | Sequential Impulse + warm starting (Catto GDC 2009 ベース) |
| Broadphase | Lock-free quad-tree (4子=SIMD 4-wide と一致)、レイヤー分割 |
| Narrowphase | GJK + EPA (汎用)。全形状ペアに適用 |
| Island | Lock-free island building、大島は分割して並列解決 |
| Sleeping | Island 単位、速度閾値 + タイマー |
| 決定論 | クロスプラットフォーム決定論サポート (8% オーバーヘッド) |
| 特徴 | ジョブベース並列化、lock-free 設計、ストリーミング対応 |

**Jolt が Horizon Forbidden West に採用された理由:**
- Lock-free broadphase/island でオープンワールドのストリーミングボトルネック解消
- メモリ削減、実行ファイルサイズ削減
- 30Hz → 60Hz に倍速化しつつ CPU 時間削減

### PhysX 5 (C++, 3D)

| 項目 | 内容 |
|------|------|
| ソルバー | TGS (position iterations = substeps) |
| 特徴 | 摩擦を毎反復で解決（PGS は最終反復のみ） |
| 用途 | Unreal Engine 5 のデフォルト物理 |

---

## 技術要素別の比較

### ソルバー方式

| 方式 | 特徴 | 使用エンジン |
|------|------|-------------|
| PGS (Sequential Impulse) | シンプル、実績豊富。高 mass ratio に弱い | Box2D v2, Bullet, Jolt |
| TGS | サブステップで収束改善。PhysX 5 のデフォルト | PhysX 5, UE5 |
| TGS Soft | TGS + soft constraints + relaxation。2024-25 の主流 | Box2D v3, Rapier, Avian |
| XPBD | 位置ベース。ソフトボディ向き、剛体接触は退潮 | Jolt (soft body のみ) |

### Position Correction

| 方式 | エネルギー注入 | 品質 | コスト | 使用エンジン |
|------|:---:|:---:|:---:|------|
| Baumgarte | あり | 低 | 最小 | レガシー、**kagura 現状** |
| Split Impulse | なし | 中 | 中 | Bullet |
| NGS | なし | 高 | 高 | Box2D v2 |
| Soft Constraints + Relaxation | なし | 高 | 低〜中 | Box2D v3, Rapier, Avian |

**結論: Soft constraints が Baumgarte とほぼ同コストで NGS 級の品質。移行推奨。**

### Broadphase

| 方式 | 特徴 | 使用エンジン |
|------|------|-------------|
| Spatial Hash Grid | シンプル、均一サイズ向き | **kagura 現状** |
| SAP (Sweep and Prune) | 古典的、大オブジェクトに弱い | Rapier (旧) |
| Dynamic BVH | 自動リバランス、SIMD 加速、大オブジェクト対応 | Rapier (現行) |
| Quad-tree (Lock-free) | SIMD 4-wide 対応、並列安全 | Jolt |

### Contact Management

| 機能 | 説明 | kagura の状態 |
|------|------|:---:|
| Persistent manifold | 接触点をフレーム間で維持 (max 4) | 未実装 |
| Warm starting | 前フレームの impulse をキャッシュして初期値に | 2D: フレーム内のみ、3D: なし |
| Feature-based matching | Contact ID (辺番号) で接触点を対応付け | 未実装 |
| Local-space contacts | ボディローカル座標で保持 → サブステップ中の安価な更新 | 未実装 |

### Sleeping / Island

| 機能 | 説明 | kagura の状態 |
|------|------|:---:|
| Island detection | Union-Find で接触/制約グラフの連結成分を検出 | 未実装 |
| Per-island sleeping | Island 全体の速度が閾値以下で N フレーム継続 → sleep | 未実装 |
| Persistent islands | フレーム間で island を維持、差分更新 | 未実装 |

---

## kagura 現状の分析

### physics2d (比較的良好)

- Accumulated impulse solver (4 iterations) ← Box2D v2 相当
- Baumgarte position correction (factor=0.2, slop=0.005)
- Spatial Hash Grid broadphase
- Circle, AABB, OBB 対応 (SAT)
- 角速度積分あり

### physics3d (要改善)

- **シングルパスソルバー** (反復なし) ← 致命的
- **角速度積分なし** ← 回転が壊れている
- Baumgarte position correction
- Sphere, AABB のみ (OBB なし)

### 両方に不足している機能

| 優先度 | 機能 | 効果 |
|:---:|------|------|
| **高** | Sleeping + Island detection | 性能 50-80% 改善 (静止シーン) |
| **高** | Persistent contact manifold + warm starting | 安定性大幅改善、スタッキング |
| **高** | Soft constraints (Baumgarte 置換) | エネルギー注入除去、品質向上 |
| 中 | Substepping (衝突検出はアウターレートで) | 安定性改善、高 mass ratio 対応 |
| 中 | CCD (continuous collision detection) | 高速オブジェクトのトンネリング防止 |
| 中 | Joint/Constraint system | ヒンジ、バネ、距離制約など |
| 低 | Dynamic BVH (broadphase 置換) | 大オブジェクト対応、SIMD 加速 |
| 低 | SIMD 最適化 | MoonBit WASM ではあまり恩恵なし |

---

## 推奨改善ロードマップ

### Phase 1: physics3d の基本修正

1. **反復ソルバー追加** (physics2d の accumulated impulse solver を移植)
2. **角速度積分** (torque → angular_vel → rotation)
3. physics2d と同等の安定性に引き上げ

### Phase 2: 安定性向上 (2D/3D 共通)

4. **Soft constraints 導入** (Baumgarte 置換)
   - contact_frequency (Hz) と contact_damping_ratio パラメータ
   - Relaxation pass 追加
5. **Persistent contact manifold** (max 4 点)
   - Feature ID ベースのフレーム間マッチング
   - Warm starting (フレーム間の impulse キャッシュ)

### Phase 3: 性能最適化

6. **Island detection** (Union-Find)
7. **Sleeping** (island 単位、速度閾値 + タイマー)
8. **Substepping** (衝突検出をアウターレートに分離)

### Phase 4: 機能拡張

9. Joint/Constraint system (距離、ヒンジ、バネ)
10. CCD (speculative contacts or substep-based)
11. 3D OBB / convex hull 対応

---

## 参考リソース

### 論文・ブログ

- [Solver2D - Erin Catto (Box2D)](https://box2d.org/posts/2024/02/solver2d/) — ソルバー比較の決定版
- [Releasing Box2D 3.0](https://box2d.org/posts/2024/08/releasing-box2d-3.0/)
- [SIMD Matters - Box2D](https://box2d.org/posts/2024/08/simd-matters/)
- [Avian 0.1 TGS Soft](https://joonaa.dev/blog/06/avian-0-1) — XPBD → TGS Soft 移行の詳細
- [Rapier 2025 Review](https://dimforge.com/blog/2026/01/09/the-year-2025-in-dimforge/)
- [Warm Starting - Allen Chou](https://allenchou.net/2014/01/game-physics-stability-warm-starting/)
- [BEPUphysics2 Substepping](https://github.com/bepu/bepuphysics2/blob/master/Documentation/Substepping.md)

### GDC 資料 (Erin Catto)

- [Sequential Impulses (GDC 2006)](https://box2d.org/files/ErinCatto_SequentialImpulses_GDC2006.pdf)
- [Modeling and Solving Constraints (GDC 2009)](https://box2d.org/files/ErinCatto_ModelingAndSolvingConstraints_GDC2009.pdf)
- [Soft Constraints (GDC 2011)](https://box2d.org/files/ErinCatto_SoftConstraints_GDC2011.pdf)
- [Understanding Constraints (GDC 2014)](https://box2d.org/files/ErinCatto_UnderstandingConstraints_GDC2014.pdf)

### エンジンリポジトリ

- [Box2D v3](https://github.com/erincatto/box2d)
- [Rapier](https://github.com/dimforge/rapier)
- [Jolt Physics](https://github.com/jrouwe/JoltPhysics)
- [BEPUphysics2](https://github.com/bepu/bepuphysics2)
- [Avian (Bevy)](https://github.com/Jondolf/avian)
