import test from "node:test";
import assert from "node:assert/strict";
import { parseMoonMod, serializeMoonMod } from "./moon-mod-manifest.mjs";

test("publication manifests round trip metadata, escaped strings and native prebuild options", () => {
  const input = {
    name: "test/lib",
    version: "0.7.0",
    description: 'A "quoted" description\nwith Unicode 日本語',
    license: "Apache-2.0",
    keywords: ['gpu "native"', "日本語"],
    deps: { "test/core": "0.7.0" },
    source: "src",
    "--moonbit-unstable-prebuild": "scripts/prebuild.cjs",
    "preferred-target": "js",
    "warn-list": "-6",
  };
  const output = parseMoonMod(serializeMoonMod(input));
  for (const [key, value] of Object.entries(input))
    assert.deepEqual(output[key], value, key);
});

test("publication refuses unresolved local dependencies and unhandled metadata", () => {
  assert.throws(
    () =>
      serializeMoonMod({
        name: "test/lib",
        deps: { "test/core": { path: "../core" } },
      }),
    /Unresolved/,
  );
  assert.throws(
    () => serializeMoonMod({ name: "test/lib", unknown: { value: 1 } }),
    /Unsupported/,
  );
});
