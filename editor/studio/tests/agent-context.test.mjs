import { test } from "node:test";
import assert from "node:assert/strict";
import { editorTurnContext, formatEditorTurn } from "../agent/context.mjs";
import { runAgentTurn } from "../agent/session.mjs";

test("editor turn context is the live graph, revision and selection, not a guessed tree", () => {
  const context = editorTurnContext({
    snapshot: () => ({
      revision: 4,
      selection: "hero",
      document: { name: "Arena", nodes: [{ id: "hero" }, { id: "block" }] },
    }),
    graph: () => ({
      activeScene: "training",
      subjects: [{ id: "bird" }],
      view: [{ id: "world" }],
    }),
  });
  assert.deepEqual(context, {
    revision: 4,
    selection: "hero",
    scene: "training",
    subjects: ["bird"],
    nodes: ["hero", "block"],
  });
  const prompt = formatEditorTurn("Rename hero to Player", context);
  assert.match(prompt, /revision: 4/);
  assert.match(prompt, /selection: hero/);
  assert.match(prompt, /scene: training/);
  assert.match(prompt, /subjects: bird/);
  assert.match(prompt, /Rename hero to Player/);
});

test("runAgentTurn prepends live editor state before the user prompt", async () => {
  let received;
  const session = {
    subscribe(listener) {
      this.listener = listener;
      return () => {
        this.listener = undefined;
      };
    },
    async prompt(text) {
      received = text;
    },
  };
  const host = {
    snapshot: () => ({
      revision: 2,
      selection: "hero",
      document: { nodes: [{ id: "hero" }] },
    }),
    graph: () => ({ activeScene: "", subjects: [], view: [] }),
  };
  await runAgentTurn(
    { type: "prompt", text: "Select the hero" },
    {
      host,
      emit() {},
      cwd: process.cwd(),
      createSession: async () => session,
    },
  );
  assert.match(received, /revision: 2/);
  assert.match(received, /Select the hero/);
});

test("agent prompts await RPC snapshots and graphs before formatting context", async () => {
  let received;
  const host = {
    snapshot: async () => ({
      revision: 9,
      selection: "",
      document: { nodes: [] },
    }),
    graph: async () => ({
      activeScene: "training",
      subjects: [{ id: "player" }],
      view: [],
    }),
  };
  const session = {
    subscribe() {
      return () => {};
    },
    async prompt(text) {
      received = text;
    },
  };
  await runAgentTurn(
    { type: "prompt", text: "Inspect player" },
    { host, emit() {}, createSession: async () => session },
  );
  assert.match(received, /revision: 9/);
  assert.match(received, /subjects: player/);
});

test("runtime graph selection takes precedence over authored selection, including no selection", () => {
  let selection = { kind: "subject", id: "player" };
  const host = {
    snapshot: () => ({
      revision: 1,
      selection: "spawn",
      document: { nodes: [] },
    }),
    graph: () => ({
      activeScene: "training",
      subjects: [{ id: "player" }],
      view: [],
      selection,
    }),
  };
  assert.equal(editorTurnContext(host).selection, "player");
  selection = null;
  assert.equal(editorTurnContext(host).selection, "");
});
