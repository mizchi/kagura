import { test } from "node:test";
import assert from "node:assert/strict";
import { handleAgentMessage, catalogAgentEvents } from "../agent/bridge.mjs";

test("agent bridge turns a prompt into streamed events and routes editor tools back to the host", async () => {
  const session = {
    subscribe(listener) {
      this.listener = listener;
      return () => {
        this.listener = undefined;
      };
    },
    async prompt(text) {
      this.listener({ type: "text_delta", delta: "Renaming hero." });
      this.listener({
        type: "tool",
        name: "editor_dispatch",
        args: {
          expectedRevision: 0,
          commands: [{ op: "node.rename", id: "hero", name: "Player" }],
        },
      });
    },
  };
  let dispatched;
  const host = {
    editor_dispatch: async (args) => {
      dispatched = args;
      return { ok: true, revision: 1 };
    },
  };
  const out = [];
  await handleAgentMessage(
    { type: "prompt", text: "Rename hero to Player" },
    {
      session,
      host,
      emit: (event) => out.push(event),
    },
  );
  assert.equal(dispatched.commands[0].name, "Player");
  assert.equal(
    out.some(
      (event) =>
        event.type === "text_delta" && event.delta.includes("Renaming"),
    ),
    true,
  );
  assert.equal(out.at(-1).type, "done");
  assert.deepEqual(catalogAgentEvents(), [
    "prompt",
    "abort",
    "text_delta",
    "tool",
    "tool_result",
    "error",
    "done",
  ]);
});

test("SDK-managed tool events never execute the mutation a second time", async () => {
  let calls = 0;
  const session = {
    executesTools: true,
    subscribe(listener) {
      this.listener = listener;
      return () => {};
    },
    async prompt() {
      this.listener({
        type: "tool_execution_start",
        toolCallId: "1",
        toolName: "runtime_fields_edit",
        args: {},
      });
      calls++; // The SDK invokes its registered tool implementation itself.
    },
  };
  const out = [];
  await handleAgentMessage(
    { type: "prompt", text: "Move Player" },
    {
      session,
      host: {
        runtime_fields_edit() {
          calls++;
        },
      },
      emit: (event) => out.push(event),
    },
  );
  assert.equal(calls, 1);
  assert.equal(out.filter((event) => event.type === "tool").length, 1);
});
