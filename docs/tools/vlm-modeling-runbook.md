# VLM Modeling Runbook

Kagura の authoring example を、`live-review` と VLM review loop で回すときの最短手順をまとめる。

authoring workspace は `tools/modeling3d/` に集約してあり、example の実体は `tools/modeling3d/examples/*` にある。

エディタ・レンダラ・export・round-trip review loop は共有ライブラリ
`mizchi/kagura_modeling3d`（`tools/modeling3d/src/`）にあり、各 example が持つのは
モデルデータ（`model_doc.mbt`）とレビュー方針（`authoring_profile.mbt`）だけ。
構成の詳細は [`tools/modeling3d/README.md`](../../tools/modeling3d/README.md)。

VLM の apply-patch が編集する対象は従来どおり各 example の `src/model_doc.mbt`。

対象:

- `model_authoring`
- `chair_authoring`
- `shelf_authoring`
- `frog_authoring`
- `dragon_authoring`

この runbook は日常の反復を速く回すことを目的にしている。基本は `daemon + dry-run`、節目だけ `daemon + --execute` を使う。

## 前提

- OpenRouter を使う場合は `OPENROUTER_API_KEY` を入れておく
- 作業中の preview は `just dev <example>` で起動する
- VLM の高速 loop は browser download ではなく browser state / daemon client を使う

## 基本方針

- 通常の造形中:
  - `dry-run`
  - local screenshot / bundle / prompt / request だけ出す
  - API 待ちは入れない
- 節目の review:
  - `--execute`
  - OpenRouter に実際に投げる
  - `parsed.json` まで生成する

## 最短の再試行手順

### 1. preview を起動

```sh
just dev frog_authoring
```

dev server の URL は terminal に表示される。以下の例では `http://127.0.0.1:8083/` を使う。

### 2. dry-run daemon を起動

```sh
just vlm-daemon-start frog_authoring openrouter 8083 9123
```

意味:

- preview は `8083`
- daemon は `9123`
- browser / page は daemon 側で保持される

### 3. dry-run を 1 回実行

```sh
just vlm-daemon-run 9123 1 output/playwright/daemon-run
```

主な artifact:

- `current-state-review-screenshot.png`
- `current-state-review-vlm-bundle.json`
- `current-state-review-vlm-review.md`
- `current-state-review-request.json`

### 4. daemon を止める

```sh
just vlm-daemon-stop 9123
```

## checkpoint review

`--execute` 付き daemon を別で起動する。

### 1. checkpoint daemon を起動

```sh
just vlm-daemon-start-checkpoint frog_authoring openrouter 8083 9123
```

### 2. 実 review を 1 回実行

```sh
just vlm-daemon-run-checkpoint 9123 1
```

主な artifact:

- `current-state-review-response.json`
- `current-state-review-parsed.json`

### 3. daemon を止める

```sh
just vlm-daemon-stop 9123
```

## benchmark

### daemon dry-run benchmark

```sh
just vlm-perf-live-review-daemon frog_authoring openrouter 8 1 8230
```

### one-shot / persistent benchmark

```sh
just vlm-perf-live-review-persistent frog_authoring openrouter 8 1 8230
```

benchmark の summary は `output/playwright/perf-*/summary.json` に出る。

## artifact の見方

- `*-screenshot.png`
  - atlas capture
- `*-vlm-bundle.json`
  - current document と review profile
- `*-vlm-review.md`
  - VLM に渡した prompt
- `*-request.json`
  - API request payload
- `*-response.json`
  - provider raw response
- `*-parsed.json`
  - structured review

## 運用メモ

- 日常の編集 loop は `dry-run` を使う
- `--execute` の律速はほぼ API 応答で、local capture ではない
- daemon を使うと browser launch / page open を毎回払わずに済む
- `frog_authoring` の latest benchmark では、daemon dry-run の warm mean は約 `164ms/cycle`

## 参考コマンド

`chair_authoring`:

```sh
just dev chair_authoring
just vlm-daemon-start chair_authoring openrouter 8083 9123
just vlm-daemon-run 9123 1 output/playwright/chair-daemon-run
just vlm-daemon-stop 9123
```

`shelf_authoring`:

```sh
just dev shelf_authoring
just vlm-daemon-start shelf_authoring openrouter 8083 9123
just vlm-daemon-run 9123 1 output/playwright/shelf-daemon-run
just vlm-daemon-stop 9123
```

`model_authoring`:

```sh
just dev model_authoring
just vlm-daemon-start model_authoring openrouter 8083 9123
just vlm-daemon-run 9123 1 output/playwright/model-daemon-run
just vlm-daemon-stop 9123
```

`dragon_authoring`:

```sh
just dev dragon_authoring
just vlm-daemon-start dragon_authoring openrouter 8083 9123
just vlm-daemon-run 9123 1 output/playwright/dragon-daemon-run
just vlm-daemon-stop 9123
```
