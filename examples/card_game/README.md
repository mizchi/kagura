# Card Game — Slay the Spire-style Deckbuilder

kagura エンジン上で動作する Slay the Spire スタイルのデッキ構築型ローグライトカードゲーム。
Ironclad のデータをベースに、StS の面白さを構成する要素を形式的にモデル化している。

## 起動

```bash
# GUI（ブラウザ）
just dev card_game

# ヘッドレス実行テスト（CI 向け）
cd examples/card_game
moon run src/headless --target js

# ユニットテスト
cd examples/card_game
moon test --target js
```

## プロジェクト構成

```
examples/card_game/
├── src/
│   ├── lib/                  # ゲームロジックライブラリ
│   │   ├── cards.mbt         # カード定義（31枚）
│   │   ├── combat.mbt        # 戦闘システム（Fighter, StatusEffects, ダメージ計算）
│   │   ├── enemy.mbt         # 敵AI・エンカウンター定義（10体 + ボス2体）
│   │   ├── game.mbt          # バトルステート・カード実行ロジック
│   │   ├── run.mbt           # ラン進行（15フロア Act 1）
│   │   ├── relics.mbt        # レリック（8種）
│   │   ├── balance.mbt       # AI戦略（Aggressive/Defensive/Smart）
│   │   ├── economy.mbt       # Machinations経済モデル・ラン全体シミュレーション
│   │   ├── ml_balance.mbt    # ML用特徴量抽出・感度分析
│   │   ├── fun_metrics.mbt   # Fun指標（7次元）・StS面白さ定量化
│   │   ├── view.mbt          # UI描画（SceneNode ツリー）
│   │   └── *_wbtest.mbt      # ホワイトボックステスト
│   ├── headless/             # ヘッドレスランナー（moon run）
│   │   ├── main.mbt          # バランスチェック・ラン全体テスト
│   │   └── moon.pkg
│   ├── main.mbt              # GUI エントリポイント
│   └── moon.pkg
└── moon.mod.json
```

## ゲームシステム

### Act 1 フロア構成（15フロア）

| フロア | 種別 | 内容 |
|--------|------|------|
| 1-3 | Easy | Jaw Worm, Two Louses |
| 4 | Elite | Red Slaver / Sentry Pair / Gremlin Nob |
| 5 | Rest | HP 30% 回復 |
| 6-8 | Normal | Cultist, Fungi Pair, Red Slaver |
| 9 | Rest | HP 30% 回復 |
| 10-11 | Normal | 同上 |
| 12 | Rest | HP 30% 回復 |
| 13 | Elite | 同上 |
| 14 | Rest | HP 30% 回復 |
| 15 | **Boss** | **The Guardian (240HP) / Hexaghost (250HP)** |

### カード一覧（37枚）

**スターター (3種)**

| カード | コスト | 種別 | 効果 |
|--------|--------|------|------|
| Strike | 1 | Attack | 6 ダメージ |
| Defend | 1 | Skill | 5 ブロック |
| Bash | 2 | Attack | 8 ダメージ, Vulnerable 2 |

**コモン Attack (7種)**

| カード | コスト | 効果 |
|--------|--------|------|
| Cleave | 1 | 8 ダメージ (全体) |
| Pommel Strike | 1 | 9 ダメージ, 1枚ドロー |
| Twin Strike | 1 | 5×2 ダメージ |
| Iron Wave | 1 | 5 ダメージ + 5 ブロック |
| Anger | 0 | 6 ダメージ, 捨て札にコピー追加 |
| Headbutt | 1 | 9 ダメージ, 捨て札→山札トップ |
| Heavy Blade | 2 | 14 ダメージ, 筋力3倍適用 |

**コモン Skill (4種)**

| カード | コスト | 効果 |
|--------|--------|------|
| Shrug It Off | 1 | 8 ブロック, 1枚ドロー |
| Armaments | 1 | 5 ブロック |
| True Grit | 1 | 7 ブロック, ランダム1枚消耗 |
| Flex | 0 | +2 一時筋力（ターン終了時失う） |

**アンコモン Attack (5種)**

| カード | コスト | 効果 |
|--------|--------|------|
| Clothesline | 2 | 12 ダメージ, Weak 2 |
| Uppercut | 2 | 13 ダメージ, Weak 1 + Vulnerable 1 |
| Body Slam | 1 | ダメージ = 現在ブロック値 |
| Sword Boomerang | 1 | 3 ダメージ×3（ランダム対象） |
| Rampage | 1 | 8 ダメージ（使う度 +5） |

**アンコモン Skill (6種)**

| カード | コスト | 効果 |
|--------|--------|------|
| Bloodletting | 0 | -3 HP, +2 エナジー |
| Offering | 0 | -6 HP, +2 エナジー, 3枚ドロー |
| Seeing Red | 1 | +2 エナジー |
| Battle Trance | 0 | 3枚ドロー |
| Shockwave | 2 | Weak 3 + Vulnerable 3 (全体) [消耗] |
| Disarm | 1 | 敵の筋力 -2 [消耗] |

**アンコモン Power (2種)**

| カード | コスト | 効果 |
|--------|--------|------|
| Inflame | 1 | +2 筋力（永続） |
| Metallicize | 1 | ターン終了時 +3 ブロック |

**レア (11種)**

| カード | コスト | 種別 | 効果 |
|--------|--------|------|------|
| Bludgeon | 3 | Attack | 32 ダメージ |
| Whirlwind | X | Attack | 全敵に5ダメージ×X回（X=残エナジー） |
| Feed | 1 | Attack | 10 ダメージ, 撃破時+3最大HP [消耗] |
| Fiend Fire | 2 | Attack | 手札を全消耗, 1枚につき7ダメージ [消耗] |
| Limit Break | 1 | Skill | 筋力を2倍にする [消耗] |
| Impervious | 2 | Skill | 30 ブロック [消耗] |
| Demon Form | 3 | Power | ターン開始時 +2 筋力 |
| Barricade | 3 | Power | ブロックがターン間で維持 |
| Feel No Pain | 1 | Power | 消耗時 +3 ブロック |
| Corruption | 3 | Power | Skillのコスト0, 使用時に消耗 |

### 敵一覧

**Easy**

| 敵 | HP | パターン |
|----|-----|---------|
| Jaw Worm | 42 | Chomp(11) → Bellow(BLK6+STR3) → Thrash(7) |
| Green Louse | 14 | Curl Up(BLK4) → Bite(6) → Bite(6) |
| Red Louse | 13 | Bite(6) → Bite(6) → Grow(+3 STR) |

**Normal**

| 敵 | HP | パターン |
|----|-----|---------|
| Cultist | 50 | Ritual(+3 STR蓄積) → Dark Strike(6) → 繰り返し |
| Fungi Beast | 24 | Bite(6) → Grow(+3 STR) → Bite(6) → Vuln 2 |
| Red Slaver | 46 | Stab(13) → Stab(13) → Scrape(8) → Debuff(WK1+VU1) |

**Elite**

| 敵 | HP | 特殊能力 |
|----|-----|---------|
| Sentry ×2 | 39 | Bolt(9) → Bolt(9) → Beam(5×2) |
| Gremlin Nob | 85 | **Enrage**: プレイヤーが Skill/Power を使うと +2 STR |
| Red Slaver | 46 | Stab(13) → Scrape(8) → Debuff |

**Boss**

| 敵 | HP | パターン |
|----|-----|---------|
| The Guardian | 240 | Twin Slam(8×2) → Fierce Bash(32) → Whirlwind(5×4) → Charge Up(BLK9) → Roll(9) |
| Hexaghost | 250 | Activate → Divider(6×6) → Sear(6) → Tackle(5×2) → Inflame(+2 STR) → Inferno(6×2) |

### レリック

| レリック | 効果 |
|----------|------|
| Burning Blood | 戦闘終了時 HP 6 回復 |
| Vajra | 戦闘開始時 筋力 +1 |
| Anchor | 戦闘開始時 ブロック 10 |
| Orichalcum | ターン終了時ブロック 0 なら +6 ブロック |
| Bag of Marbles | 戦闘開始時 全敵に Vulnerable 1 |
| Lantern | ターン1で +1 エナジー |
| Pen Nib | 10回目の攻撃でダメージ2倍 |
| Meat on the Bone | 戦闘終了時 HP≤50% なら 12 回復 |
| **Red Skull** | **HP≤50%の間、筋力+3（リスク報酬）** |
| **Akabeko** | **各戦闘の最初の攻撃 +8 ダメージ** |
| **Ornamental Fan** | **3回目の攻撃ごとに +4 ブロック** |
| **Happy Flower** | **3ターンごとに +1 エナジー** |

**レリック獲得**: Elite/Boss 撃破時に未所持レリックから1つ自動獲得

## AI戦略

3つの AI 戦略が実装されており、バランスシミュレーションに使用する。

### Smart AI（メイン戦略）

1. **受けるダメージの計算**: 全敵のインテントから合計ダメージを算出
2. **ブロック判断**: 未ブロックダメージ > 5 のとき防御優先
3. **Nob 対策**: Gremlin Nob 存在時は Skill/Power を避ける（Enrage 防止）
4. **ターゲット選択**: HP が最も低い敵を優先（早期撃破）
5. **カード報酬**: デッキアーキタイプ（Strength/Block/Exhaust）に基づくシナジー評価

### Ensemble（混合戦略）

人間プレイヤーの多様な判断を近似するため、3戦略を混合して使用:
- 70% Smart + 20% Aggressive + 10% Defensive

## バランス分析フレームワーク

### Machinations 経済モデル (`economy.mbt`)

Joris Dormans の Machinations フレームワークに基づくリソースフロー分析:

```
[Energy Pool: 3] --gate--> [Card Play] --converter--> [Damage Pool]
                                |                         |
                                v                         v
                          [Block Pool] <--absorb-- [Enemy Damage]
                                |                         |
                                v (overflow)              v
                          [HP Pool: 80] <------------ [HP Drain]
```

- **DPE** (Damage Per Energy): エナジーあたりのダメージ効率
- **BPE** (Block Per Energy): エナジーあたりのブロック効率
- **Efficiency**: 基準値（Strike 6 DPE, Defend 5 BPE）に対する実効率

### 感度分析 (`ml_balance.mbt`)

有限差分法によるパラメータ感度: `sensitivity ≈ (win_rate(param+δ) - win_rate(base)) / δ`

摂動可能パラメータ:
- `PlayerHP` / `PlayerEnergy` — プレイヤー初期値
- `EnemyHP(EnemyId)` / `EnemyDamage(EnemyId)` — 敵のHP/ダメージ

### アーキタイプ検出

デッキ内カードのアフィニティスコアからビルドタイプを自動判定:
- **Strength**: Inflame, Demon Form, Twin Strike, Flex...
- **Block**: Barricade, Metallicize, Body Slam, Impervious...
- **Exhaust**: Feel No Pain, Offering, True Grit...
- **Balanced**: いずれの偏りもない場合

### ML 特徴量（20次元ベクトル）

ゲーム状態から以下の特徴量を抽出（将来の学習パイプライン用）:

| 領域 | 特徴量 |
|------|--------|
| Player (5) | HP%, Energy, Block, Strength, Weak |
| Deck (5) | Size, Hand size, Draw pile, Discard, Exhaust |
| Enemy (5) | Count, Total HP%, Max single HP%, Attacking?, Total intent dmg |
| Battle (5) | Turn, Cards played, Energy spent, Damage dealt, Block gained |

## ヘッドレステスト出力例

```
=== CARD GAME HEADLESS TEST ===

--- Balance Simulation (Smart AI, 50 runs each) ---
  [OK] Jaw Worm (Easy): smart=100% ensemble=100% avg_hp=72
  [OK] Two Louses (Easy): smart=100% ensemble=100% avg_hp=77
  [OK] Cultist (Normal): smart=100% ensemble=100% avg_hp=76
  [OK] Gremlin Nob (Elite): smart=100% ensemble=90% avg_hp=55
  [FAIL] The Guardian (Boss): smart=0% ensemble=0% avg_hp=0
  [FAIL] Hexaghost (Boss): smart=0% ensemble=0% avg_hp=0

--- Run Simulation (30 runs, Smart AI) ---
  Win rate: 50% (15/30)
  Avg floors: 15
  Avg deck size: 18

--- Sample Run Trace (seed=42) ---
  Floor 1: HP=80 Deck=10
  ...
  Floor 15: HP=80 Deck=18
  Result: DEFEAT (reached floor 15)

=== SOME CHECKS FAILED ===
```

**ボスはスターターデッキでは倒せない（0%）が、ラン全体ではデッキ構築により約50%勝利** — StS Act 1 の実際の勝率に近い。Boss 撃破にはビルドが噛み合う必要がある。

## Fun Metrics — StS の面白さの定量分析 (`fun_metrics.mbt`)

StS の面白さを構成する7つの仮説それぞれに計測可能な指標を定義し、シミュレーションから自動計測する。

### 指標一覧

| # | 次元 | 指標 | 計測方法 | 理想値 |
|---|------|------|----------|--------|
| 1 | **適切な緊張感** | tension_ratio | HP<25%になる戦闘の割合 | 15-40% |
| | | lethal_proximity | 勝利ランの最低到達HP平均 | 10-30 |
| | | close_win_rate | HP<20で勝利した割合 | 10-20% |
| 2 | **ドローの揺らぎ** | win_rate_variance | シードグループ間の勝率分散 | >0.01 |
| | | outcome_entropy | 勝敗のShannon エントロピー | 0.7-1.0 |
| 3 | **シナジー爆発力** | synergy_multiplier | 後半DPT / 序盤DPT | >1.5x |
| | | power_curve_slope | フロアあたりのDPT成長 | >0.3 |
| 4 | **リソーストレードオフ** | hp_trade_frequency | HP消費カード使用数/ラン | >0.5 |
| 5 | **敵パーソナリティ分化** | strategy_divergence | 攻撃的/防御的勝率差の分散 | >0.01 |
| 6 | **意思決定の重み** | decision_impact | Smart勝率 - Aggressive勝率 | >10% |
| 7 | **逆転可能性** | comeback_rate | 低HP(<25)からの勝率 | 30-60% |

### 現在の計測結果と StS との乖離分析

```
1. TENSION: 7% (改善中) — Boss実装+レリック報酬により危機的状況が発生するように
   勝利ランの最低HP平均: 18 (StS的には適正範囲)
   ギリギリ勝利(HP<20): 16.6%

2. DRAW VARIANCE: entropy=0.97 (GOOD) — 勝率50%でドロー運による揺らぎが可視化
   勝敗がほぼ半々のため最大エントロピーに近い

3. SYNERGY EXPLOSION: 1.9x (GOOD) — Heavy Blade, Limit Break, Corruption等の
   ピーキーカードにより後半DPTが約2倍に成長

4. RESOURCE TRADEOFF: 1.1/run (GOOD) — Offering/Bloodlettingに加え
   Feed(HP獲得)やCorruption(Skill消耗)のトレードオフが機能

5. ENEMY DIFFERENTIATION: 0.137 (GOOD) — Nob, Sentryなど特殊な最適戦略が存在

6. DECISION WEIGHT: 44.9% (GOOD) — Smart AI vs Aggressive AIで勝率に大きな差
   Boss戦が追加され、賢いプレイが報われるようになった

7. COMEBACK POTENTIAL: (計測中) — Boss戦で低HPバトルが発生し始めている
```

### StS 模倣度サマリー

| 面白さの要素 | 模倣度 | 評価 |
|-------------|--------|------|
| ビルドの成長感 | **GOOD** | スターター→特化デッキへの成長パスが機能 |
| リソースジレンマ | **GOOD** | HP消費カード+ピーキーカードのトレードオフ |
| 敵の個性 | **GOOD** | Nob=Attack縛り、Sentry=高火力等の差別化あり |
| ドキドキ感 | **改善** | Boss戦でHP危険域に入る場面が発生 |
| ドロー運の影響 | **GOOD** | 勝率50%でドロー次第の展開が明確に |
| 判断力の差 | **GOOD** | Smart AIが44.9%の勝率優位を持つ |
| 逆転劇 | 改善中 | Boss戦で低HPからの挽回パターンが出現 |

**総合**: ボス実装+ピーキーカード+レリック報酬の追加により、7指標中5つがGOOD。
残る改善点はTENSION（7%→15-40%目標）とCOMEBACK。
Normal敵の微調整で緊張感をさらに高める余地がある。

## 設計思想

StS の面白さを構成する7つの仮説に基づいてモデル化:

1. **リソーストレードオフ**: HP が普遍的通貨。全ての判断が将来の HP と現在のアドバンテージのトレード
2. **シナジー爆発**: アーキタイプ構築により乗算的なスケーリング（Strength × マルチヒット等）
3. **失敗フィードバック**: 死因が明確で次に活かせる（デッキ構成ミス or 戦闘ミス）
4. **ターン内ランダム性**: ドロー順によるミクロな意思決定の変化
5. **敵パーソナリティ**: 各敵に固有の攻略パターン（Nob = Attack のみ、Cultist = 速攻）
6. **レリックによるゲーム変革**: パッシブ効果がデッキ戦略を根本的に変える
7. **抑制された序盤→OP ビルド**: スターター → 徐々に強化 → ボスを倒せるデッキへ
