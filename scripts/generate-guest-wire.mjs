import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
const root = resolve(import.meta.dirname, "..");
const wire = JSON.parse(
  readFileSync(resolve(root, "platform_web/host/guest-wire-v0.json"), "utf8"),
);
const banner =
  "Generated from platform_web/host/guest-wire-v0.json. DO NOT EDIT.";
const outputs = {
  "platform_web/host/kagura-guest-wire.generated.js": `// ${banner}\nexport const GUEST_WIRE = Object.freeze(${JSON.stringify(wire, null, 2)});\n`,
  "examples/experimental/wasm_game/guest/moonbit/wire_generated.mbt": `///|\n/// ${banner}\npub fn kagura_guest_abi_version() -> Int32 {\n  ${wire.abiVersion}\n}\n\n///|\nlet wire_draw_header_bytes : Int32 = ${wire.drawHeaderBytes}\n\n///|\nlet wire_vertex_components : Int32 = ${wire.vertexComponents}\n`,
  "examples/experimental/wasm_game/guest/rust/src/wire_generated.rs": `// ${banner}\npub const DRAW_HEADER_BYTES: usize = ${wire.drawHeaderBytes};\npub const VERTEX_COMPONENTS: usize = ${wire.vertexComponents};\n#[no_mangle]\npub extern "C" fn kagura_guest_abi_version() -> i32 { ${wire.abiVersion} }\n`,
  "examples/experimental/wasm_game/guest/zig/src/wire_generated.zig": `// ${banner}\npub const ABI_VERSION: i32 = ${wire.abiVersion};\npub const DRAW_HEADER_BYTES: usize = ${wire.drawHeaderBytes};\npub const VERTEX_COMPONENTS: usize = ${wire.vertexComponents};\n`,
};
for (const [file, source] of Object.entries(outputs)) {
  const path = resolve(root, file);
  if (process.argv.includes("--check")) {
    if (readFileSync(path, "utf8") !== source)
      throw Error(`Stale guest wire: ${file}`);
  } else writeFileSync(path, source);
}
