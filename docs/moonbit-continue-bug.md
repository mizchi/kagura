# MoonBit `continue` in `for` loop - JS codegen bug

## 概要

MoonBit コンパイラが `for` ループ内の `continue <label>` を JS ターゲットにコンパイルする際、ループカウンタのインクリメントをスキップする `continue` 文を生成し、無限ループになるバグがある。

## 再現コード

```moonbit
for j in 0..<4 {
  let w = weights[j]
  if w <= 0.0 {
    continue j   // ← これが問題
  }
  // ... 残りの処理
}
```

## 生成される JS（問題あり）

```javascript
let _tmp = 0;
while (true) {
    const j = _tmp;
    if (j < 4) {
      const w = weights[j];
      if (w <= 0) {
        continue;  // ← _tmp がインクリメントされないまま while(true) の先頭に戻る
      }
      // ... 残りの処理
      _tmp = j + 1 | 0;  // ← continue で到達しない
      continue;
    } else {
      break;
    }
}
```

`continue` が `_tmp = j + 1 | 0` をスキップするため、`j` が永遠に同じ値のまま無限ループになる。

## 回避策

`continue` を使わず、`if/else` で条件を反転させる。

```moonbit
// NG: continue を使う
for j in 0..<4 {
  let w = weights[j]
  if w <= 0.0 {
    continue j
  }
  do_something(j)
}

// OK: if/else で書き直す
for j in 0..<4 {
  let w = weights[j]
  if w > 0.0 {
    do_something(j)
  }
}
```

## 影響を受けたコード

- `src/skeleton3d/skin.mbt` の `apply_skin()` — ブラウザでページがハングする原因だった

## 備考

- native ターゲットでは未確認（異なるコード生成パスのため問題ない可能性がある）
- moon 0.1.20260209 (b129ae2 2026-02-09) で確認
- 上流への報告を検討すべき
