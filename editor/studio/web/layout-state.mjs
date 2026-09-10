// Layout state is independent of authoring documents and DOM lifetimes.
export const GAP = 6;
export const defaults = layout => ({
  columns: [0.17, 0.60, 0.23],
  rows: layout === 'action' ? [0.6, 0.55, 0.6] : [0.7, 0.7, 0.7],
});
export const clamp = (value, min, max) => Math.max(min, Math.min(max, value));
export function validSizes(value) {
  return value && ['columns', 'rows'].every(key => Array.isArray(value[key]) && value[key].length === 3 &&
    value[key].every(n => Number.isFinite(n) && n > 0 && n < 1)) &&
    Math.abs(value.columns.reduce((sum, n) => sum + n, 0) - 1) < 0.001;
}
export function columnGeometry(weights, width) {
  const total = Math.max(1, width - GAP * 2);
  const scale = Math.min(1, total / 480);
  const minimums = [140, 180, 160].map(n => n * scale);
  const left = clamp(weights[0] * total, minimums[0], total - minimums[1] - minimums[2]);
  const right = clamp(weights[2] * total, minimums[2], total - left - minimums[1]);
  return { total, minimums, widths: [left, total - left - right, right] };
}
export function rowGeometry(ratio, height) {
  const total = Math.max(1, height - GAP);
  const minimum = Math.min(80, total / 2);
  return { total, minimum, top: clamp(ratio * total, minimum, total - minimum) };
}
export function resizeColumns(geometry, index, delta) {
  const { widths, minimums, total } = geometry;
  const pair = widths[index] + widths[index + 1];
  const first = clamp(widths[index] + delta, minimums[index], pair - minimums[index + 1]);
  return widths.map((n, i) => (i === index ? first : i === index + 1 ? pair - first : n) / total);
}
