/** Browser-side editor host used by the agent RPC. Throws on failed dispatch. */
export function kaguraEditorHost(kagura) {
  return {
    snapshot: () => kagura.snapshot(),
    dispatch: (transaction) => {
      const reply = kagura.dispatch(transaction);
      if (reply && reply.ok === false) throw Error(reply.error?.message ?? 'Dispatch failed');
      return reply;
    },
    select: (id) => kagura.select(id),
    async selectScene(id) {
      if (typeof kagura.selectScene !== 'function') throw Error('Scene switching is not available');
      await kagura.selectScene(id);
      return { ok: true, sceneId: id };
    },
    graph: () => kagura.graph(),
    runtime: kagura.runtime,
  };
}
