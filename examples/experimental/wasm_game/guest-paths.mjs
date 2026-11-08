import {fileURLToPath} from 'node:url';

export const MOONBIT_SOURCE_DIR = fileURLToPath(new URL('./guest/moonbit', import.meta.url));
export const TARGETS = {
  moonbit: {
    label: 'MoonBit',
    path: fileURLToPath(new URL('./guest/moonbit/_build/wasm/debug/build/wasm_game_guest.wasm', import.meta.url)),
  },
  rust: {
    label: 'Rust',
    path: fileURLToPath(new URL('./guest/rust/target/wasm32-unknown-unknown/release/kagura_wasm_guest_rust.wasm', import.meta.url)),
  },
  zig: {
    label: 'Zig',
    path: fileURLToPath(new URL('./guest/zig/zig-out/lib/kagura_wasm_guest_zig.wasm', import.meta.url)),
  },
};
