import test from "node:test";
import assert from "node:assert/strict";
import { readRuntimeSubjectView } from "../runtime/subject-view.mjs";

test("read-only subject views carry a scope without inventing mutation tokens", () => {
  const observation = {
    game: "arena3d",
    source: "scene",
    inspection: {
      scope: "training",
      subjects: [{ id: "player", name: "Player", fields: [] }],
    },
  };
  const host = {
    transport: () => ({ playing: true, debugging: false, paused: true }),
    observe: () => observation,
    debug() {
      throw Error("A read-only view must not use the debugger");
    },
  };
  const view = readRuntimeSubjectView(host);
  assert.equal(view.writable, false);
  assert.equal(view.paused, true);
  assert.equal(view.token, undefined);
  assert.equal(view.subjects[0].id, "player");
  assert.notEqual(
    readRuntimeSubjectView(host, {
      ...observation,
      inspection: { ...observation.inspection, scope: "second" },
    }).key,
    view.key,
  );
});

test("editable subject views retain the exact debugger token and release on stop", () => {
  let playing = true;
  const token = { session: "s1", revision: 3, paused: true, subjects: [] };
  const host = {
    transport: () => ({ playing, debugging: playing, paused: true }),
    debug: () => token,
    observe() {
      throw Error("A debugger supplies its own view");
    },
  };
  const view = readRuntimeSubjectView(host);
  assert.equal(view.writable, true);
  assert.equal(view.token, token);
  const captured = readRuntimeSubjectView(
    host,
    {
      game: "fixture",
      source: "scene",
      inspection: { scope: "training", subjects: [] },
    },
    { readonly: true },
  );
  assert.equal(captured.writable, false);
  assert.equal(captured.token, undefined);
  playing = false;
  assert.equal(readRuntimeSubjectView(host), null);
});

test("field-only views grant edits through their own API; captured views never grant edits", () => {
  const token = {
    session: "fields1",
    revision: 4,
    scope: "training",
    paused: true,
    subjects: [{ id: "player", name: "Player", fields: [] }],
  };
  const observation = {
    game: "arena3d",
    source: "scene",
    inspection: { scope: "training", subjects: token.subjects },
  };
  const host = {
    transport: () => ({
      playing: true,
      debugging: false,
      fieldEditing: true,
      paused: true,
    }),
    fields: () => token,
    observe: () => observation,
    debug() {
      throw Error("Field editing must not use full snapshot APIs");
    },
  };
  const live = readRuntimeSubjectView(host);
  assert.equal(live.editor, "fields");
  assert.equal(live.token, token);
  assert.equal(live.writable, true);
  const captured = readRuntimeSubjectView(host, observation, {
    readonly: true,
  });
  assert.equal(captured.key, live.key);
  assert.equal(captured.writable, false);
  assert.equal(captured.token, undefined);
});
