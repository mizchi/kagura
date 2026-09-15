import test from "node:test";
import assert from "node:assert/strict";
import { readModelingStartup } from "../modeling/startup.mjs";

test("modeling links select a built-in preset independently of hosting path", () => {
  assert.deepEqual(
    readModelingStartup(
      "https://example.com/kagura/studio/?mode=modeling&model=kawaiko",
    ),
    { model: "kawaiko" },
  );
  assert.deepEqual(
    readModelingStartup("http://localhost:5190/?mode=modeling"),
    { model: null },
  );
  assert.equal(readModelingStartup("http://localhost:5190/"), null);
  assert.equal(
    readModelingStartup("http://localhost:5190/?model=kawaiko"),
    null,
  );
  assert.throws(
    () =>
      readModelingStartup("http://localhost:5190/?mode=modeling&model=unknown"),
    /Unknown modeling model/,
  );
  assert.throws(
    () => readModelingStartup("http://localhost:5190/?mode=modeling&model="),
    /Unknown modeling model/,
  );
  assert.throws(
    () =>
      readModelingStartup(
        "http://localhost:5190/?mode=modeling&model=kawaiko&model=unknown",
      ),
    /Duplicate/,
  );
});

test("previously shared kawaiiko links resolve to the canonical kawaiko preset", () => {
  assert.deepEqual(
    readModelingStartup("https://example.com/kagura/studio/?mode=modeling&model=kawaiiko"),
    { model: "kawaiko" },
  );
  assert.throws(
    () => readModelingStartup("https://example.com/?mode=modeling&model=kawaiko&model=kawaiiko"),
    /Duplicate/,
  );
});
