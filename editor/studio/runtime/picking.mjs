/** UI snapshot paths use >; declared hierarchy paths use /. No subjects are inferred. */
export function runtimePickTargets(hierarchy, snapshot, subjects) {
  const bindings = new Map();
  function visit(nodes) {
    for (const node of nodes ?? []) {
      if (node.subject && subjects.has(node.subject))
        bindings.set(node.id, node.subject);
      visit(node.children);
    }
  }
  visit(hierarchy);
  return (snapshot?.nodes ?? []).flatMap((node) => {
    const subject = bindings.get(node.path?.split(">").join("/"));
    const bounds = [node.left, node.top, node.width, node.height];
    return subject &&
      node.visible &&
      bounds.every(Number.isFinite) &&
      node.width > 0 &&
      node.height > 0
      ? [
          {
            subject,
            left: node.left,
            top: node.top,
            width: node.width,
            height: node.height,
          },
        ]
      : [];
  });
}
