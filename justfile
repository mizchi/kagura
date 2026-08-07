# MoonBit project commands

target := "js"

default: check test

fmt:
    moon fmt
    for dir in examples/*/*/ tools/modeling3d/examples/*/ tools/effect-studio/examples/*/; do { [ -f "$dir/moon.mod.json" ] || [ -f "$dir/moon.mod" ]; } && (cd "$dir" && moon fmt); done

check:
    moon check --deny-warn --target {{target}}
    for dir in examples/*/*/ tools/modeling3d/examples/*/ tools/effect-studio/examples/*/; do if [ -f "$dir/moon.mod.json" ] || [ -f "$dir/moon.mod" ]; then case "$dir" in examples/experimental/crater_paint/|examples/smoke/browser_headless/) echo "skip $dir (depends on out-of-repo mizchi/crater checkout)"; continue;; esac; if [ "{{target}}" != "native" ] && [ -f "$dir/src/moon.pkg" ] && grep -q 'supported_targets = "native"' "$dir/src/moon.pkg"; then echo "skip $dir (supports native only)"; continue; fi; (cd "$dir" && moon check --deny-warn --target {{target}}); fi; done

modeling3d-check:
    for dir in tools/modeling3d/examples/*/; do { [ -f "$dir/moon.mod.json" ] || [ -f "$dir/moon.mod" ]; } && (cd "$dir" && moon check --deny-warn --target {{target}}); done

effect-studio-check:
    for dir in tools/effect-studio/examples/*/; do { [ -f "$dir/moon.mod.json" ] || [ -f "$dir/moon.mod" ]; } && (cd "$dir" && moon check --deny-warn --target {{target}}); done

test:
    if [ "{{target}}" = "native" ]; then CPATH="$(brew --prefix glfw)/include:${CPATH:-}" LIBRARY_PATH="$(brew --prefix)/lib:${LIBRARY_PATH:-}" moon test --target native || { echo "::error title=moon test failed::root moon test --target native"; exit 1; }; else moon test --target {{target}} || { echo "::error title=moon test failed::root moon test --target {{target}}"; exit 1; }; fi
    if [ "{{target}}" = "js" ] && ls lib/web/*.test.mjs >/dev/null 2>&1; then node --test lib/web/*.test.mjs || { echo "::error title=node test failed::lib/web/*.test.mjs"; exit 1; }; fi
    for dir in examples/*/*/ tools/modeling3d/examples/*/ tools/effect-studio/examples/*/; do if [ -f "$dir/moon.mod.json" ] || [ -f "$dir/moon.mod" ]; then case "$dir" in examples/experimental/crater_paint/|examples/smoke/browser_headless/) echo "skip $dir (depends on out-of-repo mizchi/crater checkout)"; continue;; esac; if [ "{{target}}" != "native" ] && [ -f "$dir/src/moon.pkg" ] && grep -q 'supported_targets = "native"' "$dir/src/moon.pkg"; then echo "skip $dir (supports native only)"; continue; fi; if [ "{{target}}" = "native" ] && grep -rq "wgpu_native" "$dir/src/moon.pkg" 2>/dev/null; then echo "skip $dir (requires wgpu-native at link time)"; continue; fi; if [ "{{target}}" = "native" ] && [ "$dir" = "tools/effect-studio/examples/effect_studio/" ]; then echo "skip $dir (native test limited to check-only)"; continue; fi; echo "test $dir"; (cd "$dir" && if [ "{{target}}" = "native" ]; then CPATH="$(brew --prefix glfw)/include:${CPATH:-}" LIBRARY_PATH="$(brew --prefix)/lib:${LIBRARY_PATH:-}" moon test --target native; else moon test --target {{target}}; fi) || { echo "::error file=$dir/moon.mod,title=example test failed::$dir"; exit 1; }; fi; done

modeling3d-test:
    for dir in tools/modeling3d/examples/*/; do { [ -f "$dir/moon.mod.json" ] || [ -f "$dir/moon.mod" ]; } && (cd "$dir" && if [ "{{target}}" = "native" ]; then CPATH="$(brew --prefix glfw)/include:${CPATH:-}" LIBRARY_PATH="$(brew --prefix)/lib:${LIBRARY_PATH:-}" moon test --target native; else moon test --target {{target}}; fi); done

effect-studio-test:
    for dir in tools/effect-studio/examples/*/; do { [ -f "$dir/moon.mod.json" ] || [ -f "$dir/moon.mod" ]; } && if [ "{{target}}" = "native" ]; then echo "skip $dir (effect-studio native validation is check-only for now)"; else (cd "$dir" && moon test --target {{target}}); fi; done

modeling3d-scripts-check:
    node --test tools/modeling3d/scripts/*.test.mjs
    for script in tools/modeling3d/scripts/*.mjs; do node --check "$script"; done
    if ls tools/modeling3d/scripts/*.py >/dev/null 2>&1; then python3 -m py_compile tools/modeling3d/scripts/*.py; fi

modeling3d-ci:
    just modeling3d-scripts-check
    just target=js modeling3d-check
    just target=js modeling3d-test
    just target=native modeling3d-check

effect-studio-ci:
    just target=js effect-studio-check
    just target=js effect-studio-test
    just target=native effect-studio-check

effect-studio-e2e:
    pnpm exec playwright test e2e/effect_studio.spec.ts

hacknslash3d-effects-e2e:
    pnpm exec playwright test e2e/hacknslash_3d_effects.spec.ts

# Publish public library modules to mooncakes (excludes example games / tools).
# `just publish-dry` to validate without uploading.
publish:
    bash scripts/publish.sh

# Read-only: show per-module NEW / UNCHANGED / CHANGED status, upload nothing.
publish-status:
    bash scripts/publish.sh --status

coverage:
    bash scripts/check-coverage.sh {{target}}

bench:
    moon bench --target {{target}}
    for dir in examples/*/*/ tools/modeling3d/examples/*/ tools/effect-studio/examples/*/; do { [ -f "$dir/moon.mod.json" ] || [ -f "$dir/moon.mod" ]; } && (cd "$dir" && moon bench --target {{target}}); done

bench-gate:
    node scripts/bench-gate.mjs {{target}}

bench-update:
    node scripts/bench-gate.mjs {{target}} --update

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

# Deterministic UI integrity gate over a published UI snapshot.
# Produce the snapshot from `globalThis.__kaguraUISnapshot` (js) or the native
# capture's context_path, then: just ui-check output/ui-snapshot.json
ui-check snapshot extra="":
    node scripts/ui-integrity-gate.mjs {{snapshot}} {{extra}}

# Convert a UI snapshot into a vlmkit --elements-json payload, so a pixel diff
# names the UI node that changed instead of a bare region.
ui-elements snapshot out="output/vlmkit-elements.json":
    mkdir -p "$(dirname {{out}})"
    node scripts/ui-snapshot-to-vlmkit-elements.mjs {{snapshot}} -o {{out}}

# Vet a sprite / icon before it enters a UI slot (browser-free PNG math).
ui-asset-check asset extra="":
    pnpm exec vlmkit check asset {{asset}} {{extra}}

native-vrt:
    cd examples/smoke/native_vrt && moon run src --target native

native-vrt-update:
    cd examples/smoke/native_vrt && touch .update_baselines && moon run src --target native && rm -f .update_baselines

hacknslash3d-gpu-perf port="8282" samples="120" warmup="30" extra="--headed":
    node scripts/hacknslash_3d_gpu_perf.mjs --serve --port {{port}} --samples {{samples}} --warmup {{warmup}} {{extra}}

info:
    moon info

dev name:
    node scripts/dev-server.mjs {{name}}

fal-trellis-demo-generate image="" extra="":
    test -n "{{image}}"
    node examples/experimental/fal_trellis_demo/scripts/fal_trellis_asset.mjs --image {{image}} {{extra}}

fal-trellis-demo-generate-sample sample="proxy-chest" extra="":
    image="examples/experimental/fal_trellis_demo/assets/fal_samples/{{sample}}.png"; test -f "$image"
    node examples/experimental/fal_trellis_demo/scripts/fal_trellis_asset.mjs --image "$image" {{extra}}

fal-trellis-demo-check:
    moon -C examples/experimental/fal_trellis_demo test --target js
    moon -C examples/experimental/fal_trellis_demo check --target js
    node --test examples/experimental/fal_trellis_demo/scripts/fal_trellis_asset_utils.test.mjs
    node --check examples/experimental/fal_trellis_demo/scripts/fal_trellis_asset.mjs examples/experimental/fal_trellis_demo/scripts/fal_trellis_asset_utils.mjs
    python3 -m py_compile examples/experimental/fal_trellis_demo/scripts/fal_trellis_preprocess.py

vlm-handoff example="model_authoring" profile="roundtrip_diff_bundle" provider="openrouter" port="8113" extra="":
    node tools/modeling3d/scripts/model-authoring-vlm-handoff.mjs --example {{example}} --edit-profile {{profile}} --provider {{provider}} --serve --port {{port}} {{extra}}

vlm-handoff-interactive example="model_authoring" profile="roundtrip_diff_bundle" provider="openrouter" port="8113" extra="":
    node tools/modeling3d/scripts/model-authoring-vlm-handoff.mjs --example {{example}} --edit-profile {{profile}} --provider {{provider}} --serve --port {{port}} --interactive {{extra}}

vlm-live-review example="model_authoring" provider="openrouter" port="8113" extra="":
    node tools/modeling3d/scripts/model-authoring-vlm-handoff.mjs --example {{example}} --live-review --provider {{provider}} --serve --port {{port}} {{extra}}

vlm-live-review-interactive example="model_authoring" provider="openrouter" port="8113" extra="":
    node tools/modeling3d/scripts/model-authoring-vlm-handoff.mjs --example {{example}} --live-review --provider {{provider}} --serve --port {{port}} --interactive {{extra}}

vlm-live-review-native example="model_authoring" provider="openrouter" extra="":
    node tools/modeling3d/scripts/model-authoring-vlm-handoff.mjs --example {{example}} --live-review --renderer native --provider {{provider}} {{extra}}

vlm-daemon-start example="frog_authoring" provider="openrouter" port="8113" daemon_port="9123" extra="":
    node tools/modeling3d/scripts/model-authoring-vlm-handoff.mjs --example {{example}} --live-review --provider {{provider}} --url http://127.0.0.1:{{port}}/ --daemon --daemon-port {{daemon_port}} {{extra}}

vlm-daemon-start-checkpoint example="frog_authoring" provider="openrouter" port="8113" daemon_port="9123" extra="":
    node tools/modeling3d/scripts/model-authoring-vlm-handoff.mjs --example {{example}} --live-review --provider {{provider}} --url http://127.0.0.1:{{port}}/ --daemon --daemon-port {{daemon_port}} --execute {{extra}}

vlm-daemon-run daemon_port="9123" cycle="1" out_dir="output/playwright/daemon-run" extra="":
    node tools/modeling3d/scripts/model-authoring-vlm-daemon-client.mjs --port {{daemon_port}} --run --cycle {{cycle}} --out-dir {{out_dir}} {{extra}}

vlm-daemon-run-checkpoint daemon_port="9123" cycle="1" out_dir="output/playwright/daemon-checkpoint" extra="":
    node tools/modeling3d/scripts/model-authoring-vlm-daemon-client.mjs --port {{daemon_port}} --run --cycle {{cycle}} --out-dir {{out_dir}} {{extra}}

vlm-daemon-stop daemon_port="9123":
    node tools/modeling3d/scripts/model-authoring-vlm-daemon-client.mjs --port {{daemon_port}} --shutdown

vlm-perf-live-review example="frog_authoring" provider="openrouter" iterations="8" warmup="1" port="8230" extra="":
    node tools/modeling3d/scripts/model-authoring-vlm-perf.mjs --example {{example}} --provider {{provider}} --iterations {{iterations}} --warmup {{warmup}} --port {{port}} {{extra}}

vlm-perf-live-review-persistent example="frog_authoring" provider="openrouter" iterations="8" warmup="1" port="8230" extra="":
    node tools/modeling3d/scripts/model-authoring-vlm-perf.mjs --example {{example}} --provider {{provider}} --renderer web --session-mode both --iterations {{iterations}} --warmup {{warmup}} --port {{port}} {{extra}}

vlm-perf-live-review-daemon example="frog_authoring" provider="openrouter" iterations="8" warmup="1" port="8230" extra="":
    node tools/modeling3d/scripts/model-authoring-vlm-perf.mjs --example {{example}} --provider {{provider}} --renderer web --session-mode daemon --iterations {{iterations}} --warmup {{warmup}} --port {{port}} {{extra}}

vlm-renderer-parity example="frog_authoring" provider="openrouter" port="8210" silhouette_threshold="0.2" visual_threshold="20" extra="":
    node tools/modeling3d/scripts/model-authoring-renderer-parity.mjs --example {{example}} --provider {{provider}} --port {{port}} --silhouette-threshold {{silhouette_threshold}} --visual-threshold {{visual_threshold}} {{extra}}

vlm-close-loop example="model_authoring" profile="" glb="" provider="openrouter" port="8113" extra="":
    if [ -n "{{profile}}" ]; then node tools/modeling3d/scripts/model-authoring-vlm-close-loop.mjs --example {{example}} --edit-profile {{profile}} --provider {{provider}} --port {{port}} {{extra}}; \
    else test -n "{{glb}}" && node tools/modeling3d/scripts/model-authoring-vlm-close-loop.mjs --example {{example}} --import-glb {{glb}} --provider {{provider}} --port {{port}} {{extra}}; fi

vlm-reimport example="model_authoring" glb="" provider="openrouter" port="8113" extra="":
    test -n "{{glb}}"
    node tools/modeling3d/scripts/model-authoring-vlm-handoff.mjs --example {{example}} --import-glb {{glb}} --provider {{provider}} --serve --port {{port}} {{extra}}

vlm-feedback bundle="" parsed="":
    test -n "{{bundle}}" && test -n "{{parsed}}"
    node tools/modeling3d/scripts/model-authoring-vlm-local-feedback.mjs --bundle {{bundle}} --parsed {{parsed}}

vlm-apply target="" patch="" extra="":
    test -n "{{target}}" && test -n "{{patch}}"
    node tools/modeling3d/scripts/model-authoring-vlm-apply-patch.mjs --target {{target}} --patch {{patch}} {{extra}}

run-native name:
    dir=""; for candidate in examples/*/{{name}} tools/modeling3d/examples/{{name}} tools/effect-studio/examples/{{name}}; do if [ -f "$candidate/moon.mod.json" ] || [ -f "$candidate/moon.mod" ]; then dir="$candidate"; break; fi; done; if [ -z "$dir" ]; then echo "example not found: {{name}}"; exit 1; fi; cd "$dir" && CPATH="$(brew --prefix glfw)/include:${CPATH:-}" LIBRARY_PATH="$(brew --prefix)/lib:${LIBRARY_PATH:-}" moon run src/ --target native

pages:
    bash scripts/build-pages.sh

check-release:
    node --test scripts/*.test.mjs
    node scripts/check-moon-release.mjs
    node scripts/check-moon-boundaries.mjs
    node scripts/prepare-moon-release.mjs --dry-run
    moon check --deny-warn --target js
    moon check --deny-warn --target native

release-stage out_dir=".moon-release":
    node scripts/prepare-moon-release.mjs --out {{out_dir}}

release-manifests out_dir=".moon-release":
    just release-stage {{out_dir}}

clean:
    moon clean
    for dir in examples/*/*/ tools/modeling3d/examples/*/ tools/effect-studio/examples/*/; do [ -d "$dir" ] && (cd "$dir" && moon clean); done

balance name="playtest":
    cd examples/games-3d/hacknslash_3d && moon run src/balance --target js 2>&1 | tee /dev/stderr | sed -n '/^=== CSV ===/,$ p' | tail -n +2 > data/hackslash/{{name}}.csv
    @echo "Saved: examples/games-3d/hacknslash_3d/data/hackslash/{{name}}.csv"

balance-autoplay-record out_dir="examples/games-3d/hacknslash_3d/data/hackslash/autoplay_experiments":
    node examples/games-3d/hacknslash_3d/scripts/balance_autoplay_record.mjs --out-dir {{out_dir}}

balance-hypothesis-record out_dir="examples/games-3d/hacknslash_3d/data/hackslash/autoplay_hypothesis_experiments" extra="":
    node examples/games-3d/hacknslash_3d/scripts/balance_hypothesis_record.mjs --out-dir {{out_dir}} {{extra}}

# WASM game host tasks
wasm-build-moonbit:
    cd examples/experimental/wasm_game/guest/moonbit && moon build --target wasm
    mkdir -p examples/experimental/wasm_game/host/public
    cp examples/experimental/wasm_game/guest/moonbit/_build/wasm/debug/build/wasm_game_guest.wasm examples/experimental/wasm_game/host/public/game.wasm

wasm-build-rust:
    cd examples/experimental/wasm_game/guest/rust && RUSTC="$(rustup which --toolchain stable rustc)" "$(rustup which --toolchain stable cargo)" build --target wasm32-unknown-unknown --release
    mkdir -p examples/experimental/wasm_game/host/public
    cp examples/experimental/wasm_game/guest/rust/target/wasm32-unknown-unknown/release/kagura_wasm_guest_rust.wasm examples/experimental/wasm_game/host/public/game.wasm

wasm-build-zig:
    mkdir -p examples/experimental/wasm_game/guest/zig/zig-out/lib
    zig build-exe examples/experimental/wasm_game/guest/zig/src/main.zig -target wasm32-freestanding -O ReleaseSmall -fno-entry --export-memory -rdynamic -ofmt=wasm -femit-bin=examples/experimental/wasm_game/guest/zig/zig-out/lib/kagura_wasm_guest_zig.wasm
    mkdir -p examples/experimental/wasm_game/host/public
    cp examples/experimental/wasm_game/guest/zig/zig-out/lib/kagura_wasm_guest_zig.wasm examples/experimental/wasm_game/host/public/game.wasm

wasm-host-install:
    cd examples/experimental/wasm_game/host && pnpm install --frozen-lockfile

wasm-host-check:
    just wasm-host-install
    cd examples/experimental/wasm_game/host && pnpm exec tsc --noEmit
    cd examples/experimental/wasm_game/host && pnpm build

wasm-wit-validate:
    wasm-tools component wit examples/experimental/wasm_game/wit/kagura-app-v0.wit > /dev/null

wasm-verify:
    just wasm-wit-validate
    just wasm-build-moonbit
    just wasm-build-rust
    just wasm-build-zig
    just wasm-test all
    just wasm-test-abi all
    just wasm-host-check

wasm-test guest="all":
    node examples/experimental/wasm_game/test-wasm.mjs {{guest}}

wasm-test-abi guest="all":
    node examples/experimental/wasm_game/test-wasm-abi.mjs {{guest}}

wasm-dev guest="moonbit": (wasm-build guest)
    cd examples/experimental/wasm_game/host && pnpm dev

[private]
wasm-build guest:
    @if [ "{{guest}}" = "moonbit" ]; then just wasm-build-moonbit; elif [ "{{guest}}" = "rust" ]; then just wasm-build-rust; elif [ "{{guest}}" = "zig" ]; then just wasm-build-zig; else echo "Unknown guest: {{guest}}"; exit 1; fi
