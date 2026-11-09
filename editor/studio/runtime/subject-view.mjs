/** UI projection only. Read-only observations never acquire debugger mutation tokens. */
export function readRuntimeSubjectView(
  host,
  observation,
  { readonly = false } = {},
) {
  const transport = host.transport();
  if (!transport.playing) return null;
  if (transport.debugging && !readonly) {
    const token = host.debug("inspect");
    return {
      key: "debug:" + token.session,
      subjects: token.subjects,
      paused: token.paused,
      writable: true,
      editor: "debug",
      token,
    };
  }
  const fields = transport.fieldEditing ? host.fields("inspect") : null;
  if (fields && !readonly)
    return {
      key: JSON.stringify(["fields", fields.session, fields.scope]),
      subjects: fields.subjects,
      paused: fields.paused,
      writable: true,
      editor: "fields",
      token: fields,
    };
  const published = observation ?? host.observe?.();
  return {
    key: fields
      ? JSON.stringify(["fields", fields.session, published?.inspection?.scope])
      : JSON.stringify([
          "observation",
          published?.game,
          published?.source,
          published?.inspection?.scope,
        ]),
    subjects: published?.inspection?.subjects ?? [],
    paused: transport.paused,
    writable: false,
  };
}
