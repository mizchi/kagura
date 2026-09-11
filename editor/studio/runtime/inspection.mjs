const id = (value) => typeof value === 'string' && /^[A-Za-z0-9_.:-]{1,128}$/.test(value);
const record = (value, keys) =>
  value &&
  typeof value === 'object' &&
  !Array.isArray(value) &&
  Object.keys(value).every((key) => keys.includes(key));
const text = (value) => typeof value === 'string' && value.length <= 256;
const typed = (kind, value) =>
  kind === 'number'
    ? typeof value === 'number' && Number.isFinite(value)
    : kind === 'boolean'
      ? typeof value === 'boolean'
      : kind === 'string' && typeof value === 'string';
/** Data shared by generic UI, headless tools and game-owned reducers. No guessed state paths. */
export function validateInspection(subjects) {
  if (!Array.isArray(subjects) || subjects.length > 10000)
    throw Error('Invalid inspection subjects');
  const ids = new Set();
  let count = 0;
  for (const subject of subjects) {
    if (
      !record(subject, ['id', 'name', 'fields']) ||
      !id(subject.id) ||
      ids.has(subject.id) ||
      !text(subject.name) ||
      !Array.isArray(subject.fields)
    )
      throw Error('Invalid inspection subject');
    ids.add(subject.id);
    const fields = new Set();
    for (const field of subject.fields) {
      if (
        ++count > 10000 ||
        !record(field, ['id', 'label', 'kind', 'value', 'access', 'unit']) ||
        !id(field.id) ||
        fields.has(field.id) ||
        !text(field.label) ||
        !text(field.unit) ||
        !['runtime', 'readonly'].includes(field.access) ||
        !typed(field.kind, field.value)
      )
        throw Error('Invalid inspection field');
      fields.add(field.id);
    }
  }
  return subjects;
}
export function validateInspectionEdit(edit, subjects) {
  if (!record(edit, ['subject', 'field', 'value']) || !id(edit.subject) || !id(edit.field))
    throw Error('Invalid inspection edit');
  const field = subjects
    .find((subject) => subject.id === edit.subject)
    ?.fields.find((field) => field.id === edit.field);
  if (!field || field.access !== 'runtime') throw Error('Inspection field is not writable');
  if (!typed(field.kind, edit.value)) throw Error('Invalid inspection value');
}
