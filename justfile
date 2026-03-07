# MoonBit project commands

target := "js"

default: check test

fmt:
    moon fmt
    [ -f modules/js_runtime/moon.mod.json ] && (cd modules/js_runtime && moon fmt)
    for dir in examples/*/; do [ -f "$dir/moon.mod.json" ] && (cd "$dir" && moon fmt); done

check:
    moon check --deny-warn --target {{target}}
    if [ "{{target}}" = "js" ] && [ -f modules/js_runtime/moon.mod.json ]; then (cd modules/js_runtime && moon check --deny-warn --target js); fi
    for dir in examples/*/; do [ -f "$dir/moon.mod.json" ] && (cd "$dir" && moon check --deny-warn --target {{target}}); done

test:
    if [ "{{target}}" = "native" ]; then CPATH="$(brew --prefix glfw)/include:${CPATH:-}" LIBRARY_PATH="$(brew --prefix)/lib:${LIBRARY_PATH:-}" moon test --target native; else moon test --target {{target}}; fi
    if [ "{{target}}" = "js" ] && [ -f modules/js_runtime/moon.mod.json ]; then (cd modules/js_runtime && moon test --target js); fi
    for dir in examples/*/; do if [ -f "$dir/moon.mod.json" ]; then if [ "{{target}}" = "native" ] && [ "$dir" = "examples/runtime_smoke_native/" ]; then echo "skip $dir (native smoke app is validated in native-macos build job)"; continue; fi; (cd "$dir" && if [ "{{target}}" = "native" ]; then CPATH="$(brew --prefix glfw)/include:${CPATH:-}" LIBRARY_PATH="$(brew --prefix)/lib:${LIBRARY_PATH:-}" moon test --target native; else moon test --target {{target}}; fi) || exit 1; fi; done

bench:
    moon bench --target {{target}}
    for dir in examples/*/; do [ -f "$dir/moon.mod.json" ] && (cd "$dir" && moon bench --target {{target}}); done

test-update:
    moon test --update --target {{target}}

e2e-install:
    pnpm install
    pnpm e2e:install

e2e:
    pnpm e2e

e2e-smoke:
    pnpm e2e:smoke

e2e-vrt:
    pnpm exec playwright test e2e/vrt.spec.ts

e2e-vrt-update:
    pnpm exec playwright test e2e/vrt.spec.ts --update-snapshots

info:
    moon info

dev name:
    node scripts/dev-server.mjs {{name}}

run-native name:
    cd examples/{{name}} && CPATH="$(brew --prefix glfw)/include:${CPATH:-}" LIBRARY_PATH="$(brew --prefix)/lib:${LIBRARY_PATH:-}" moon run src/ --target native

pages:
    bash scripts/build-pages.sh

check-release:
    @echo "Checking for local path dependencies..."
    @if grep -q '"path"' moon.mod.json; then echo "ERROR: moon.mod.json contains local path dependencies"; grep '"path"' moon.mod.json; exit 1; else echo "OK: No local path dependencies found"; fi
    moon check --target js
    [ -f modules/js_runtime/moon.mod.json ] && (cd modules/js_runtime && moon check --target js)
    moon check --target native

clean:
    moon clean
    [ -f modules/js_runtime/moon.mod.json ] && (cd modules/js_runtime && moon clean)
    for dir in examples/*/; do (cd "$dir" && moon clean); done

# WASM game host tasks
wasm-build-moonbit:
    cd examples/wasm_game/guest/moonbit && moon build --target wasm
    mkdir -p examples/wasm_game/host/public
    cp examples/wasm_game/guest/moonbit/_build/wasm/debug/build/wasm_game_guest.wasm examples/wasm_game/host/public/game.wasm

wasm-build-rust:
    cd examples/wasm_game/guest/rust && RUSTC="$(rustup which --toolchain stable rustc)" "$(rustup which --toolchain stable cargo)" build --target wasm32-unknown-unknown --release
    mkdir -p examples/wasm_game/host/public
    cp examples/wasm_game/guest/rust/target/wasm32-unknown-unknown/release/kagura_wasm_guest_rust.wasm examples/wasm_game/host/public/game.wasm

wasm-build-zig:
    mkdir -p examples/wasm_game/guest/zig/zig-out/lib
    zig build-exe examples/wasm_game/guest/zig/src/main.zig -target wasm32-freestanding -O ReleaseSmall -fno-entry --export-memory -rdynamic -ofmt=wasm -femit-bin=examples/wasm_game/guest/zig/zig-out/lib/kagura_wasm_guest_zig.wasm
    mkdir -p examples/wasm_game/host/public
    cp examples/wasm_game/guest/zig/zig-out/lib/kagura_wasm_guest_zig.wasm examples/wasm_game/host/public/game.wasm

wasm-host-install:
    cd examples/wasm_game/host && pnpm install --frozen-lockfile

wasm-host-check:
    just wasm-host-install
    cd examples/wasm_game/host && pnpm exec tsc --noEmit
    cd examples/wasm_game/host && pnpm build

wasm-wit-validate:
    wasm-tools component wit examples/wasm_game/wit/kagura-app-v0.wit > /dev/null

wasm-verify:
    just wasm-wit-validate
    just wasm-build-moonbit
    just wasm-build-rust
    just wasm-build-zig
    just wasm-test all
    just wasm-test-abi all
    just wasm-host-check

wasm-test guest="all":
    node examples/wasm_game/test-wasm.mjs {{guest}}

wasm-test-abi guest="all":
    node examples/wasm_game/test-wasm-abi.mjs {{guest}}

wasm-dev guest="moonbit": (wasm-build guest)
    cd examples/wasm_game/host && pnpm dev

[private]
wasm-build guest:
    @if [ "{{guest}}" = "moonbit" ]; then just wasm-build-moonbit; elif [ "{{guest}}" = "rust" ]; then just wasm-build-rust; elif [ "{{guest}}" = "zig" ]; then just wasm-build-zig; else echo "Unknown guest: {{guest}}"; exit 1; fi
