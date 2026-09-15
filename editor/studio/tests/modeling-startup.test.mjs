import test from "node:test";
import assert from "node:assert/strict";
import { readModelingStartup } from "../modeling/startup.mjs";

test("modeling links select a built-in preset independently of hosting path", () => {
  assert.deepEqual(
    readModelingStartup(
      "https://example.com/kagura/studio/?mode=modeling&model=kawaiiko",
    ),
    { model: "kawaiiko" },
  );
  assert.deepEqual(
    readModelingStartup("http://localhost:5190/?mode=modeling"),
    { model: null },
  );
  assert.equal(readModelingStartup("http://localhost:5190/"), null);
  assert.equal(
    readModelingStartup("http://localhost:5190/?model=kawaiiko"),
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
        "http://localhost:5190/?mode=modeling&model=kawaiiko&model=unknown",
      ),
    /Duplicate/,
  );
});
