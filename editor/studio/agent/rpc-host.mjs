/** Node-side host: each method is an RPC round-trip to the browser editor. */
export function createRpcHost(send, pending) {
  let next = 0;
  function call(name, args = {}) {
    const id = String(++next);
    return new Promise((resolve, reject) => {
      pending.set(id, { resolve, reject });
      send({ type: "tool_call", id, name, args });
    });
  }
  return {
    snapshot: () => call("editor_snapshot"),
    dispatch: (args) => call("editor_dispatch", args),
    select: (id) => call("editor_select", { id }),
    selectScene: (id) => call("select_scene", { id }),
    graph: () => call("scene_graph"),
    runtime: {
      observe: () => call("runtime_observe"),
      inspect: () => call("runtime_inspect"),
      pause: () => call("runtime_pause"),
      edit: (edit, token) => call("runtime_edit", { ...edit, ...token }),
      fields: {
        inspect: () => call("runtime_fields_inspect"),
        pause: () => call("runtime_fields_pause"),
        resume: (token) => call("runtime_fields_resume", token),
        edit: (edit, token) =>
          call("runtime_fields_edit", { ...edit, ...token }),
      },
    },
  };
}

export function resolveRpc(pending, message) {
  const waiter = pending.get(message.id);
  if (!waiter) return false;
  pending.delete(message.id);
  if (message.error) waiter.reject(Error(message.error));
  else waiter.resolve(message.result);
  return true;
}
