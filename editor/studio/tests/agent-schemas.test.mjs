import test from "node:test";
import assert from "node:assert/strict";
import { Type } from "typebox";
import Ajv from "ajv";
import { editorToolSchemas } from "../agent/session.mjs";
import { editorToolNames } from "../agent/tools.mjs";

test("every agent tool has an explicit schema; field edits require a scoped token", () => {
  const schemas = editorToolSchemas(Type);
  assert.deepEqual(Object.keys(schemas).sort(), editorToolNames().sort());
  const validate = new Ajv().compile(schemas.runtime_fields_edit);
  const args = {
    session: "s1",
    revision: 4,
    scope: "training",
    subject: "player",
    field: "position.y",
    value: 4,
  };
  assert.equal(validate(args), true);
  const { scope, ...withoutScope } = args;
  assert.equal(validate(withoutScope), false);
  assert.equal(validate({ ...args, revision: 1.5 }), false);
  assert.equal(validate({ ...args, value: {} }), false);
});
