# TODO (tools/modeling3d)

`tools/modeling3d/` 配下の code-first 3D modeling / VLM review loop に関する未完了タスクを管理する。

関連資料:

- 設計: `docs/modeling-tool-plan.md`
- 現状整理: `docs/modeling-tool-status.md`
- 運用手順: `docs/vlm-modeling-runbook.md`

## Native live-review / renderer parity

- [ ] native `model_authoring` live-review の plain atlas が web と同じ見た目で描画されるようにする
- [ ] native capture の `front / top / side` preset を runtime smoke 相当の probe で検証する

## Authoring quality baseline

- [ ] `hard_surface_prop` 用の role metadata を bundle に追加する
- [ ] `review_alignment / review_overlap` から `snap_to_plane / equalize_spacing / separate_overlap` を自動適用する local loop を 1 コマンドにまとめる
- [ ] `robot_authoring` か `cabinet_authoring` を追加して hard-surface の横展開を進める
- [ ] organic 向けに stamp scaffold と VLM review の結び付きを強める
