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

## Development Flow

1. Review the design and boundaries of your target area (`docs/architecture.md`, `docs/module_boundaries.md`)
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

Run smoke tests as needed:

```bash
(cd examples/runtime_smoke && moon run src --target js)
(cd examples/runtime_smoke_native && moon run src --target native)
(cd examples/native_triangle && moon build src --target native)
```

## Documentation Layout

- User-facing: `docs/user/`
- Architecture and design: `docs/`
- Contributing guide: `CONTRIBUTING.md`

When adding features, update documentation for the appropriate audience.
