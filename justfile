# MoonBit project commands

target := "js"

default: check test

# ASHEN HUNT: the two-head-tall hunter built on hacknslash_3d.
hunter-dev:
    node scripts/dev-server.mjs hacknslash_3d

# Rebuild the original sound bank and a WAV audition reel (requires ffmpeg).
hunter-audio:
    node examples/games/hacknslash_3d/scripts/design-audio.mjs

# Reusable game components can be verified without building a particular game.
game-components-test:
    moon -C engine/audio test . --target js
    moon -C engine/kagura_engine test procedural3d --target js
    node --test assets/web/kagura-controls.test.mjs assets/web/kagura-audio.test.mjs assets/web/kagura-presentation.test.mjs scripts/web-runtime-assets.test.mjs scripts/web-demo-pages.test.mjs

hunter-test: game-components-test
    moon -C examples/games/hacknslash_3d check --target js --deny-warn
    moon -C examples/games/hacknslash_3d test game app --target js
    node --test examples/games/hacknslash_3d/web/*.test.mjs

hunter-e2e:
    pnpm exec playwright test --config examples/games/hacknslash_3d/playwright.config.mjs

# Engine-owned browser capture: only the game surface, without page chrome.
[positional-arguments]
capture-web *args:
    node scripts/capture-web.mjs "$@"

hunter-capture:
    node scripts/capture-web.mjs --url 'http://localhost:8080/?snapshot=playing&frames=0&mute=1' --output output/ashen-hunt.png

# IRON YARD: modeling-playground mech TPS on Kagura's renderer and MoonBit simulation.
iron-yard-dev:
    node examples/games/iron_yard/scripts/dev.mjs

iron-yard-build:
    node engine/kagura_engine/draw3d/scripts/embed-wgsl.mjs
    node examples/games/iron_yard/scripts/convert-assets.mjs
    moon -C examples/games/iron_yard build --target js --release
    pnpm exec vite build --config examples/games/iron_yard/vite.config.mjs

iron-yard-test:
    node engine/kagura_engine/draw3d/scripts/embed-wgsl.mjs
    moon -C examples/games/iron_yard check --target js --deny-warn
    moon -C examples/games/iron_yard test sim app --target js
    node examples/games/iron_yard/scripts/convert-assets.mjs
    moon -C examples/games/iron_yard build --target js --release
    node --test examples/games/iron_yard/tests/*.test.mjs

iron-yard-e2e: iron-yard-build
    pnpm exec playwright test --config examples/games/iron_yard/playwright.config.mjs

# Apple Silicon + installed Chrome: exercise the actual Metal backend at Retina resolution.
iron-yard-e2e-metal: iron-yard-build
    IRON_YARD_GPU=metal pnpm exec playwright test --config examples/games/iron_yard/playwright.config.mjs

iron-yard-ci: iron-yard-test iron-yard-e2e

# Build the game-owned editor module referenced by iron-yard.kgrprj.
iron-yard-editor-build: iron-yard-build
    cd editor/studio && pnpm exec vite build --config ../../examples/games/iron_yard/editor/ui/vite.config.mjs

# Build/validate tiny scalar and SIMD Wasm kernels, then compare in Chrome.
iron-yard-simd:
    node examples/games/iron_yard/experiments/simd/bench.mjs

# Price Wasm SIMD and relaxed SIMD against the scalar 3D contact solve.
# Needs `wabt` from npm (not a repo dependency): npm install --no-save wabt
physics-simd:
    node engine/physics/experiments/simd/bench.mjs

# Profile running game URLs in an isolated native Chrome/Metal instance.
# Example: just iron-yard-profile kagura=http://127.0.0.1:5192/ three=http://127.0.0.1:5194/game.html
[positional-arguments]
iron-yard-profile *args:
    node examples/games/iron_yard/scripts/profile.mjs "$@"

iron-yard-gfx-test:
    node --test assets/web/kagura-gfx.test.mjs
    moon -C platform/web_runtime_hooks test --target js
    moon -C engine/kagura_engine test draw3d shadow3d postfx --target js
    moon -C engine/audio test . --target js

# Luna-based integrated authoring workspace (independent MoonBit module).
studio-install:
    pnpm install --frozen-lockfile
    cd editor/studio && moon check --target js
    cd editor/studio && pnpm install --frozen-lockfile

studio-dev:
    cd editor/studio && pnpm dev

# Package other examples for Studio; optional names rebuild only those projects.
[positional-arguments]
studio-examples-build *names:
    @node editor/studio/scripts/build-examples.mjs "$@"

studio-check:
    cd editor/studio && pnpm exec tsc -p tsconfig.contracts.json
    cd editor/studio && moon check --target js --deny-warn
    cd editor/studio && moon test --target js

studio-plugin-test:
    cd editor/studio && moon build --target js --release
    cd editor/studio && node scripts/build-plugins.mjs
    cd editor/studio && node --test tests/plugins.test.mjs tests/plugin-adapters.test.mjs tests/plugin-publication.test.mjs

studio-model-test:
    moon -C editor/model-viewer test . --target js
    node --test editor/studio/tests/model-assets.test.mjs

studio-model-build:
    node editor/studio/scripts/build-model-viewer.mjs

studio-build:
    cd editor/studio && pnpm build

studio-e2e:
    cd editor/studio && moon build --target js --release
    cd editor/studio && node scripts/build-plugins.mjs
    cd editor/studio && node scripts/build-games.mjs
    cd editor/studio && pnpm exec playwright test

[positional-arguments]
studio-headless *args:
    @cd editor/studio && moon build --target js --release headless 1>&2
    @node editor/studio/headless/cli.mjs "$@"

studio-headless-test:
    cd editor/studio && moon build --target js --release
    moon -C examples/games/iron_yard build headless --target js --release
    moon -C examples/games/hacknslash_3d build scene_api --target js --release
    moon -C examples/games/arena3d build scenes --target js --release
    moon -C examples/games/fps_demo build scenes --target js --release
    moon -C examples/games/flappy_bird build scenes --target js --release
    cd editor/studio && node scripts/build-plugins.mjs
    cd editor/studio && node --test tests/*.test.mjs

# Local-only Worker + R2. See editor/studio/worker/.dev.vars.example.
studio-worker-dev: studio-build
    cd editor/studio && WRANGLER_SEND_METRICS=false pnpm exec wrangler dev --local --config worker/wrangler.jsonc --port 8787

studio-worker-check: studio-build
    cd editor/studio && WRANGLER_SEND_METRICS=false pnpm exec wrangler deploy --dry-run --config worker/wrangler.jsonc --outdir .wrangler/dry-run

studio-storage-test:
    cd editor/studio && moon build --target js --release headless
    cd editor/studio && node --test tests/storage.test.mjs tests/worker-storage.test.mjs

studio-ci: studio-check studio-build
    cd editor/studio && node --test tests/*.test.mjs
    cd editor/studio && STUDIO_PREVIEW=1 pnpm exec playwright test
    cd editor/studio && WRANGLER_SEND_METRICS=false pnpm exec wrangler deploy --dry-run --config worker/wrangler.jsonc --outdir .wrangler/dry-run

fmt:
    moon fmt
    for dir in examples/*/*/ editor/modeling3d/examples/*/ editor/effect-studio/examples/*/; do { [ -f "$dir/moon.mod.json" ] || [ -f "$dir/moon.mod" ]; } && (cd "$dir" && moon fmt); done

check: check-workspace check-examples

# The workspace itself, without the example projects.
check-workspace:
    moon check --deny-warn --target {{target}}

# Every example/editor-example project that supports {{target}}.
#
# `shard` is "index/total", 1-based; the default runs all of them. CI passes a
# real shard so the projects divide across runners -- which project belongs to
# which shard is decided by scripts/example-projects.mjs, not here, so every
# runner derives the same split.
check-examples shard="1/1":
    dirs=$(node scripts/example-projects.mjs --target {{target}} --mode check --shard {{shard}}) || { echo "::error title=example listing failed::scripts/example-projects.mjs"; exit 1; }; for dir in $dirs; do echo "check $dir"; (cd "$dir" && moon check --deny-warn --target {{target}}) || { echo "::error file=$dir/moon.mod,title=example check failed::$dir"; exit 1; }; done

modeling3d-check:
    for dir in editor/modeling3d/examples/*/; do { [ -f "$dir/moon.mod.json" ] || [ -f "$dir/moon.mod" ]; } && (cd "$dir" && moon check --deny-warn --target {{target}}); done

effect-studio-check:
    for dir in editor/effect-studio/examples/*/; do { [ -f "$dir/moon.mod.json" ] || [ -f "$dir/moon.mod" ]; } && (cd "$dir" && moon check --deny-warn --target {{target}}); done

test: test-workspace test-examples

# The workspace itself plus the JS-side unit tests, without the example projects.
test-workspace:
    if [ "{{target}}" = "native" ]; then CPATH="$(brew --prefix glfw)/include:${CPATH:-}" LIBRARY_PATH="$(brew --prefix)/lib:${LIBRARY_PATH:-}" moon test --target native || { echo "::error title=moon test failed::root moon test --target native"; exit 1; }; else moon test --target {{target}} || { echo "::error title=moon test failed::root moon test --target {{target}}"; exit 1; }; fi
    if [ "{{target}}" = "js" ] && ls assets/web/*.test.mjs >/dev/null 2>&1; then node --test assets/web/*.test.mjs || { echo "::error title=node test failed::assets/web/*.test.mjs"; exit 1; }; fi

# Every example/editor-example project whose tests can link on {{target}}.
#
# Far fewer projects than `check-examples` on native: anything that links
# wgpu-native is check-only there. See `shard` on `check-examples`.
test-examples shard="1/1":
    dirs=$(node scripts/example-projects.mjs --target {{target}} --mode test --shard {{shard}}) || { echo "::error title=example listing failed::scripts/example-projects.mjs"; exit 1; }; for dir in $dirs; do echo "test $dir"; (cd "$dir" && if [ "{{target}}" = "native" ]; then CPATH="$(brew --prefix glfw)/include:${CPATH:-}" LIBRARY_PATH="$(brew --prefix)/lib:${LIBRARY_PATH:-}" moon test --target native; else moon test --target {{target}}; fi) || { echo "::error file=$dir/moon.mod,title=example test failed::$dir"; exit 1; }; done

modeling3d-test:
    for dir in editor/modeling3d/examples/*/; do { [ -f "$dir/moon.mod.json" ] || [ -f "$dir/moon.mod" ]; } && (cd "$dir" && if [ "{{target}}" = "native" ]; then CPATH="$(brew --prefix glfw)/include:${CPATH:-}" LIBRARY_PATH="$(brew --prefix)/lib:${LIBRARY_PATH:-}" moon test --target native; else moon test --target {{target}}; fi); done

effect-studio-test:
    for dir in editor/effect-studio/examples/*/; do { [ -f "$dir/moon.mod.json" ] || [ -f "$dir/moon.mod" ]; } && if [ "{{target}}" = "native" ]; then echo "skip $dir (effect-studio native validation is check-only for now)"; else (cd "$dir" && moon test --target {{target}}); fi; done

modeling3d-scripts-check:
    node --test editor/modeling3d/scripts/*.test.mjs
    for script in editor/modeling3d/scripts/*.mjs; do node --check "$script"; done
    if ls editor/modeling3d/scripts/*.py >/dev/null 2>&1; then python3 -m py_compile editor/modeling3d/scripts/*.py; fi

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
    for dir in examples/*/*/ editor/modeling3d/examples/*/ editor/effect-studio/examples/*/; do { [ -f "$dir/moon.mod.json" ] || [ -f "$dir/moon.mod" ]; } && (cd "$dir" && moon bench --target {{target}}); done

bench-gate extra="":
    node scripts/bench-gate.mjs {{target}} {{extra}}

# Records the median of 3 runs. One run is one sample, and some benchmarks are
# wider than the gate's own threshold -- see scripts/bench-gate.mjs.
bench-update extra="--runs 3":
    node scripts/bench-gate.mjs {{target}} --update {{extra}}

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
# capture's context_path, then:
#   just ui-check output/ui-snapshot.json
#   just ui-check output/ui-snapshot.json "--image output/frames/ui_demo/ui_demo.png"
ui-check snapshot extra="":
    node scripts/ui-integrity-gate.mjs {{snapshot}} {{extra}}

# Expand snapshot strings (vlmkit stress i18n for canvas UI) and re-run integrity.
# Default profile is German-style +35% word inflation. Pass
# --profiles all  for fullwidth / RTL / emoji / digit overflow + missing glyphs.
ui-i18n-stress snapshot extra="":
    node scripts/ui-i18n.mjs {{snapshot}} {{extra}}

# Replay keyboard/gamepad/pointer input and verify real focus movement and pixels.
ui-interactions example extra="":
    node scripts/ui-interactions.mjs {{example}} {{extra}}

# Capture every transition tick, gate intermediate layout and assert settling.
ui-flipbook example transition extra="":
    node scripts/ui-flipbook.mjs {{example}} {{transition}} {{extra}}

# Ensure verification-only initial-state factories are absent from release artifacts.
check-capture-release target="js":
    node scripts/check-capture-release.mjs {{target}}

# Capture a declared UI state using the native executable.
# Default backend is cpu (portable 2D rasterizer). Pass --backend gpu for wgpu.
#   just ui-capture ui_demo
#   just ui-capture ui_demo idle standard "--backend gpu"
ui-capture example state="idle" viewport="standard" extra="":
    node scripts/ui-capture-native.mjs {{example}} {{state}} {{viewport}} {{extra}}

# Verify rich canvas metadata through vlmkit's image-only integrity gate.
ui-vlmkit-check snapshot image out_dir="output/ui-vlmkit-integrity":
    node scripts/ui-vlmkit-integrity.mjs {{snapshot}} {{image}} {{out_dir}}

# Game-declared input states x viewports; baseline updates are explicit.
#   just ui-matrix ui_demo
#   just ui-matrix --all
#   just ui-matrix --all "--backend native"  # skips js-only examples (hacknslash)
#   just ui-matrix hacknslash_3d "--backend gpu"  # 3D wgpu; not JS CI
ui-matrix example extra="":
    node scripts/ui-matrix.mjs {{example}} {{extra}}

# Theme + i18n follow-ups over output/ui-matrix/*.standard cells.
# i18n gates ui_demo and is advisory for scene games (label rect = glyph box).
ui-matrix-gates extra="--all":
    node scripts/ui-matrix-gates.mjs {{extra}}

# Convert a UI snapshot into a vlmkit --elements-json payload, so a pixel diff
# names the UI node that changed instead of a bare region.
ui-elements snapshot out="output/vlmkit-elements.json":
    mkdir -p "$(dirname {{out}})"
    node scripts/ui-snapshot-to-vlmkit-elements.mjs {{snapshot}} -o {{out}}

# Vet a sprite / icon before it enters a UI slot (browser-free PNG math).
ui-asset-check asset extra="":
    pnpm exec vlmkit check asset {{asset}} {{extra}}

# Check a frame against the example's declared theme tokens.
ui-theme-check image theme="examples/demos-2d/ui_demo/editor/theme.json":
    node scripts/ui-theme.mjs {{image}} {{theme}}

# Run `vlmkit check asset` for every entry in the example's editor/assets.json.
ui-assets example extra="":
    node scripts/ui-assets.mjs {{example}} {{extra}}

# Render one frame of an example directly: no browser, no GPU, no Playwright.
# The engine's headless path runs the example's own update/draw and rasterizes
# the command stream on the CPU, so this works on Linux CI where the canvas
# capture is transparent and the Dawn readback never completes.
#   just render ui_demo "--frames 3"
#   just render ui_demo "--state hover --cursor 100,74"
render example extra="":
    node scripts/render-frame.mjs {{example}} {{extra}}

# Browser-free visual regression gate. Renders every entry in
# `scripts/frame-vrt-manifest.mjs` through the CPU rasterizer and compares it
# to a committed baseline. Unlike `e2e-vrt` this actually gates: the frames are
# pure arithmetic, so they are byte-identical run to run.
#   just frame-vrt              # check everything
#   just frame-vrt ui_demo      # just one example's entries
frame-vrt extra="":
    node scripts/frame-vrt.mjs {{extra}}

# Re-pin the frame baselines after an intended visual change. Read the diff
# first -- `just frame-vrt` prints which UI node moved.
frame-vrt-update extra="":
    node scripts/frame-vrt.mjs --update {{extra}}

# Visual review loop: render a frame, run the deterministic gates over it, then
# ask a VLM only about what a gate cannot measure (hierarchy, balance,
# perceptual contrast beyond the WCAG crop). `--dry-run` builds the request
# without calling the API. `--compare <png>` attributes the change since a
# baseline frame to UI nodes.
#   just vlm-ui-review ui_demo "--frames 3 --dry-run"
#   OPENROUTER_API_KEY=... just vlm-ui-review ui_demo "--frames 3"
vlm-ui-review example extra="":
    node scripts/vlm-ui-review.mjs {{example}} {{extra}}

# Hold the example bundle and serve POST /review jobs. Defaults to --dry-run.
#   just vlm-ui-daemon-start ui_demo
#   OPENROUTER_API_KEY=... just vlm-ui-daemon-start ui_demo "--execute"
vlm-ui-daemon-start example extra="":
    node scripts/vlm-ui-daemon.mjs {{example}} {{extra}}

native-vrt:
    cd examples/smoke/native_vrt && moon run . --target native

native-vrt-update:
    cd examples/smoke/native_vrt && touch .update_baselines && moon run . --target native && rm -f .update_baselines

# Capture a frame + its context natively, the portable path: the web canvas
# capture is transparent headless and the Linux Dawn readback never completes.
# Stages the capture config the example reads, then runs it on the native
# backend. cpu is the 2D rasterizer; gpu is the real wgpu pipeline (3D).
#   just capture ui_demo
#   just capture pbr_demo output/capture "--backend gpu"
# Feed the artifacts to `just ui-check` / `vlmkit diff png`.
capture example out_dir="output/capture" extra="":
    #!/usr/bin/env bash
    set -euo pipefail
    dir=""
    for candidate in examples/*/{{example}} editor/modeling3d/examples/{{example}} editor/effect-studio/examples/{{example}}; do
      if [ -f "$candidate/moon.mod" ] || [ -f "$candidate/moon.mod.json" ]; then dir="$candidate"; break; fi
    done
    if [ -z "$dir" ]; then echo "example not found: {{example}}"; exit 1; fi
    mkdir -p "{{out_dir}}"
    out="$(cd "{{out_dir}}" && pwd)"
    node scripts/stage-capture-config.mjs --example-dir "$dir" --out-dir "$out" {{extra}}
    (cd "$dir" && moon run . --target native)
    rm -f "$dir/kagura_native_capture_config.txt"

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
    node editor/modeling3d/scripts/model-authoring-vlm-handoff.mjs --example {{example}} --edit-profile {{profile}} --provider {{provider}} --serve --port {{port}} {{extra}}

vlm-handoff-interactive example="model_authoring" profile="roundtrip_diff_bundle" provider="openrouter" port="8113" extra="":
    node editor/modeling3d/scripts/model-authoring-vlm-handoff.mjs --example {{example}} --edit-profile {{profile}} --provider {{provider}} --serve --port {{port}} --interactive {{extra}}

vlm-live-review example="model_authoring" provider="openrouter" port="8113" extra="":
    node editor/modeling3d/scripts/model-authoring-vlm-handoff.mjs --example {{example}} --live-review --provider {{provider}} --serve --port {{port}} {{extra}}

vlm-live-review-interactive example="model_authoring" provider="openrouter" port="8113" extra="":
    node editor/modeling3d/scripts/model-authoring-vlm-handoff.mjs --example {{example}} --live-review --provider {{provider}} --serve --port {{port}} --interactive {{extra}}

vlm-live-review-native example="model_authoring" provider="openrouter" extra="":
    node editor/modeling3d/scripts/model-authoring-vlm-handoff.mjs --example {{example}} --live-review --renderer native --provider {{provider}} {{extra}}

vlm-daemon-start example="frog_authoring" provider="openrouter" port="8113" daemon_port="9123" extra="":
    node editor/modeling3d/scripts/model-authoring-vlm-handoff.mjs --example {{example}} --live-review --provider {{provider}} --url http://127.0.0.1:{{port}}/ --daemon --daemon-port {{daemon_port}} {{extra}}

vlm-daemon-start-checkpoint example="frog_authoring" provider="openrouter" port="8113" daemon_port="9123" extra="":
    node editor/modeling3d/scripts/model-authoring-vlm-handoff.mjs --example {{example}} --live-review --provider {{provider}} --url http://127.0.0.1:{{port}}/ --daemon --daemon-port {{daemon_port}} --execute {{extra}}

vlm-daemon-run daemon_port="9123" cycle="1" out_dir="output/playwright/daemon-run" extra="":
    node editor/modeling3d/scripts/model-authoring-vlm-daemon-client.mjs --port {{daemon_port}} --run --cycle {{cycle}} --out-dir {{out_dir}} {{extra}}

vlm-daemon-run-checkpoint daemon_port="9123" cycle="1" out_dir="output/playwright/daemon-checkpoint" extra="":
    node editor/modeling3d/scripts/model-authoring-vlm-daemon-client.mjs --port {{daemon_port}} --run --cycle {{cycle}} --out-dir {{out_dir}} {{extra}}

vlm-daemon-stop daemon_port="9123":
    node editor/modeling3d/scripts/model-authoring-vlm-daemon-client.mjs --port {{daemon_port}} --shutdown

vlm-perf-live-review example="frog_authoring" provider="openrouter" iterations="8" warmup="1" port="8230" extra="":
    node editor/modeling3d/scripts/model-authoring-vlm-perf.mjs --example {{example}} --provider {{provider}} --iterations {{iterations}} --warmup {{warmup}} --port {{port}} {{extra}}

vlm-perf-live-review-persistent example="frog_authoring" provider="openrouter" iterations="8" warmup="1" port="8230" extra="":
    node editor/modeling3d/scripts/model-authoring-vlm-perf.mjs --example {{example}} --provider {{provider}} --renderer web --session-mode both --iterations {{iterations}} --warmup {{warmup}} --port {{port}} {{extra}}

vlm-perf-live-review-daemon example="frog_authoring" provider="openrouter" iterations="8" warmup="1" port="8230" extra="":
    node editor/modeling3d/scripts/model-authoring-vlm-perf.mjs --example {{example}} --provider {{provider}} --renderer web --session-mode daemon --iterations {{iterations}} --warmup {{warmup}} --port {{port}} {{extra}}

vlm-renderer-parity example="frog_authoring" provider="openrouter" port="8210" silhouette_threshold="0.2" visual_threshold="20" extra="":
    node editor/modeling3d/scripts/model-authoring-renderer-parity.mjs --example {{example}} --provider {{provider}} --port {{port}} --silhouette-threshold {{silhouette_threshold}} --visual-threshold {{visual_threshold}} {{extra}}

vlm-close-loop example="model_authoring" profile="" glb="" provider="openrouter" port="8113" extra="":
    if [ -n "{{profile}}" ]; then node editor/modeling3d/scripts/model-authoring-vlm-close-loop.mjs --example {{example}} --edit-profile {{profile}} --provider {{provider}} --port {{port}} {{extra}}; \
    else test -n "{{glb}}" && node editor/modeling3d/scripts/model-authoring-vlm-close-loop.mjs --example {{example}} --import-glb {{glb}} --provider {{provider}} --port {{port}} {{extra}}; fi

vlm-reimport example="model_authoring" glb="" provider="openrouter" port="8113" extra="":
    test -n "{{glb}}"
    node editor/modeling3d/scripts/model-authoring-vlm-handoff.mjs --example {{example}} --import-glb {{glb}} --provider {{provider}} --serve --port {{port}} {{extra}}

vlm-feedback bundle="" parsed="":
    test -n "{{bundle}}" && test -n "{{parsed}}"
    node editor/modeling3d/scripts/model-authoring-vlm-local-feedback.mjs --bundle {{bundle}} --parsed {{parsed}}

vlm-apply target="" patch="" extra="":
    test -n "{{target}}" && test -n "{{patch}}"
    node editor/modeling3d/scripts/model-authoring-vlm-apply-patch.mjs --target {{target}} --patch {{patch}} {{extra}}

run-native name:
    dir=""; for candidate in examples/*/{{name}} editor/modeling3d/examples/{{name}} editor/effect-studio/examples/{{name}}; do if [ -f "$candidate/moon.mod.json" ] || [ -f "$candidate/moon.mod" ]; then dir="$candidate"; break; fi; done; if [ -z "$dir" ]; then echo "example not found: {{name}}"; exit 1; fi; entry="."; if [ -f "$dir/src/moon.pkg" ]; then entry="src"; fi; cd "$dir" && CPATH="$(brew --prefix glfw)/include:${CPATH:-}" LIBRARY_PATH="$(brew --prefix)/lib:${LIBRARY_PATH:-}" moon run "$entry" --target native

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
    for dir in examples/*/*/ editor/modeling3d/examples/*/ editor/effect-studio/examples/*/; do [ -d "$dir" ] && (cd "$dir" && moon clean); done

balance name="playtest":
    cd examples/games/hacknslash_3d && moon run balance --target js 2>&1 | tee /dev/stderr | sed -n '/^=== CSV ===/,$ p' | tail -n +2 > data/hackslash/{{name}}.csv
    @echo "Saved: examples/games/hacknslash_3d/data/hackslash/{{name}}.csv"

balance-autoplay-record out_dir="examples/games/hacknslash_3d/data/hackslash/autoplay_experiments":
    node examples/games/hacknslash_3d/scripts/balance_autoplay_record.mjs --out-dir {{out_dir}}

balance-hypothesis-record out_dir="examples/games/hacknslash_3d/data/hackslash/autoplay_hypothesis_experiments" extra="":
    node examples/games/hacknslash_3d/scripts/balance_hypothesis_record.mjs --out-dir {{out_dir}} {{extra}}

# What the Atomics frame-clock handshake costs per frame, and how far above
# 60Hz it holds up. Reporting only -- wake latency has scheduler outliers, so a
# gate would flake. Run it when assets/web/kagura-wasm-worker.js changes.
bench-frame-clock extra="":
    node scripts/bench-frame-clock.mjs {{extra}}

# Build the wasm1 guest that links moonbitlang/async and run it both ways:
# single-threaded under assets/web/kagura-wasm-host.js, and in a worker with a
# main-thread frame clock via assets/web/kagura-wasm-driver.js. `just test` covers
# this too, via `node --test assets/web/*.test.mjs`.
wasm-host-smoke:
    cd examples/smoke/wasm_async_smoke && moon build --target wasm
    node --test assets/web/kagura-wasm-host.test.mjs assets/web/kagura-wasm-driver.test.mjs

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

# Shared game scene profiles, scene transitions, and project loading contracts.
studio-scene-test:
    moon -C examples/games/arena3d build scenes --target js --release
    moon -C examples/games/fps_demo build scenes --target js --release
    moon -C examples/games/flappy_bird build scenes --target js --release
    moon -C editor/studio build --target js --release
    moon -C game test scene_flow --target js
    moon -C game test scene_data --target js
    moon -C game test scene2d --target js
    moon -C examples/games/arena3d test . --target js
    moon -C examples/games/fps_demo test . --target js
    moon -C examples/games/flappy_bird test . --target js
    node --test editor/studio/tests/moonbit-scene.test.mjs editor/studio/tests/scene-profile.test.mjs editor/studio/tests/project-scenes.test.mjs editor/studio/tests/extension-host.test.mjs editor/studio/tests/scene2d.test.mjs

# Game-owned live state: JS/native headless simulation and debugger/WebMCP contracts.
studio-runtime-test:
    moon -C examples/games/flappy_bird test . --target js
    moon -C examples/games/flappy_bird test . --target native
    node --test editor/studio/tests/runtime-debug.test.mjs editor/studio/tests/extension-host.test.mjs

# Declarative views share hierarchy with the existing 2D/3D renderers.
studio-declarative-test:
    moon -C game test scene --target {{target}}
    moon -C engine/kagura_engine test scene3d --target {{target}}
    moon -C examples/games/flappy_bird test . --target {{target}}
    moon -C examples/games/arena3d test . --target {{target}}
    node --test editor/studio/tests/scene-hierarchy.test.mjs editor/studio/tests/runtime-debug.test.mjs

# Code declarations -> hierarchy subjects -> game-owned Inspector / AI edits.
studio-inspection-test:
    moon -C game test inspection --target {{target}}
    moon -C game test scene --target {{target}}
    moon -C engine/kagura_engine test scene3d --target {{target}}
    moon -C examples/games/flappy_bird test . --target {{target}}
    node --test editor/studio/tests/inspection.test.mjs editor/studio/tests/scene-hierarchy.test.mjs editor/studio/tests/runtime-debug.test.mjs

# Fails when code for inspection remains in the unminified release artifact.
studio-inspection-release-check:
    node scripts/check-inspection-release.mjs {{target}}
