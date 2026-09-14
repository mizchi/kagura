# Kagura CLI

Install with the MoonBit toolchain and Node.js 24 or later:

```sh
moon install mizchi/kagura_cli/kagura@0.5.0
kagura new my-game --web
cd my-game
pnpm install
kagura dev
kagura build
```

The generated project uses published Kagura modules and includes the browser
runtime. `kagura --help` lists available options. Set `KAGURA_ROOT` to a Kagura
checkout to run its examples or launch `kagura studio`.
