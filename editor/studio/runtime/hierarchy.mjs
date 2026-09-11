/** Shared inspection contract; this is derived from the rendered view, never saved as source. */
export function validateHierarchy(input) {
  const ids = new Set();
  let count = 0;
  function nodes(values, parent, depth) {
    if (!Array.isArray(values) || depth > 128) throw Error('Invalid scene hierarchy');
    return values.map((value) => {
      if (
        ++count > 10000 ||
        !value ||
        typeof value !== 'object' ||
        Object.keys(value).some(
          (k) => !['id', 'name', 'kind', 'generated', 'children', 'subject'].includes(k),
        ) ||
        typeof value.id !== 'string' ||
        value.id.split('/').some((key) => !/^(?:[A-Za-z0-9_.-]{1,128}|@\d+)$/.test(key)) ||
        value.id.length > 4096 ||
        !value.id ||
        typeof value.name !== 'string' ||
        value.name.length > 256 ||
        typeof value.kind !== 'string' ||
        value.kind.length > 128 ||
        typeof value.generated !== 'boolean' ||
        (value.subject != null && (typeof value.subject !== 'string' || !/^[A-Za-z0-9_.:-]{1,128}$/.test(value.subject)))
      )
        throw Error('Invalid scene hierarchy node');
      if (ids.has(value.id)) throw Error('Duplicate scene hierarchy ID');
      if (value.id.slice(0, Math.max(0, value.id.lastIndexOf('/'))) !== parent)
        throw Error('Invalid scene hierarchy parent');
      ids.add(value.id);
      return {
        id: value.id,
        name: value.name,
        kind: value.kind,
        generated: value.generated,
        ...(value.subject != null ? { subject: value.subject } : {}),
        children: nodes(value.children, value.id, depth + 1),
      };
    });
  }
  return nodes(input, '', 0);
}
