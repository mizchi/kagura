import test from 'node:test';
import assert from 'node:assert/strict';
import {fileURLToPath} from 'node:url';
import {resolve} from 'node:path';
import {TARGETS} from '../examples/experimental/wasm_game/test-wasm-harness.mjs';

test('guest test artifacts resolve from their module even outside the repository working directory', () => {
  const guestRoot = fileURLToPath(new URL('../examples/experimental/wasm_game/', import.meta.url));
  const expected = {
    moonbit: 'guest/moonbit/_build/wasm/debug/build/wasm_game_guest.wasm',
    rust: 'guest/rust/target/wasm32-unknown-unknown/release/kagura_wasm_guest_rust.wasm',
    zig: 'guest/zig/zig-out/lib/kagura_wasm_guest_zig.wasm',
  };
  for (const [name, path] of Object.entries(expected)) assert.equal(TARGETS[name].path, resolve(guestRoot, path));
});
