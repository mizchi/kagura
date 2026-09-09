# Effect Studio

Kagura 上で AI 編集前提の timeline-driven effect を作る workspace です。

- core package: `editor/effect-studio/src`
- editor example: `editor/effect-studio/examples/effect_studio`
- todo: `editor/effect-studio/TODO.md`

最初の実装は `effect document -> runtime plan -> timeline view -> particle preview` の 4 層です。

起動:

```sh
just dev effect_studio
```

workspace 確認:

```sh
just effect-studio-ci
```

E2E:

```sh
just effect-studio-e2e
```
