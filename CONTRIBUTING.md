# Contributing to kagura

[日本語](CONTRIBUTING_ja.md)

This guide is for developers who want to contribute to `mizchi/kagura`.
For user-facing documentation, see `docs/user/`.

## Development Principles

- Follow TDD (Explore -> Red -> Green -> Refactor)
- Define API/type contracts first; absorb implementation differences later
- Maintain separation of concerns; do not mix state and logic
- When breaking existing contracts, verify the public API diff with `moon info`

## Setup

- [MoonBit](https://www.moonbitlang.com/)
- Node.js 24+
- pnpm
- [just](https://github.com/casey/just)
- For macOS native: `bash scripts/setup-wgpu-native.sh`

The verified toolchain is `moonc v0.10.20` (`moon 0.1.20261104`).
After `moon upgrade` and `moon update`, run `just moon-deps` to migrate legacy
JSON manifests in downloaded registry dependencies. For a standalone example,
use `just moon-deps examples/games/flappy_bird`. `just check` / `just test`
and CI perform this preparation automatically.

Preparation discovers legacy manifests in the registry cache without parsing
compiler diagnostics. Source repair patches have been removed after updating
crater to `0.19.2` and differentiable_ecs to `0.2.2`; modern dependency packages
and source files are left unchanged. Checks and their targets are executed from
`scripts/moon-check-plan.mjs`, using one catalog for standalone and external modules.

## Development Flow

1. Review the design and boundaries of your target area (`docs/architecture/architecture.md`, `docs/architecture/module_boundaries.md`)
2. Write a failing test first (Red)
3. Implement minimally to make the test pass (Green)
4. Refactor without breaking API boundaries (Refactor)
5. Run the verification steps below before opening a PR

## Local Verification

```bash
just fmt
just check target=js
just test target=js
just check target=native
just test target=native
pnpm e2e:smoke
```

`just check` also checks standalone editors, the Wasm guest and vendored GLFW.
The `crater_paint` / `browser_headless` examples require a sibling `../crater`
checkout; run `just check-external-examples` to check them explicitly.


Run smoke tests as needed:

```bash
(cd examples/smoke/runtime_smoke && moon run src --target js)
(cd examples/smoke/runtime_smoke_native && moon run src --target native)
(cd examples/smoke/native_triangle && moon build src --target native)
```

## Documentation Layout

- User-facing: `docs/user/`
- Architecture and design: `docs/`
- Contributing guide: `CONTRIBUTING.md`

When adding features, update documentation for the appropriate audience.
