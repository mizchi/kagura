/**
 * Numeric coercion shared by the UI snapshot tooling.
 *
 * A published snapshot is engine output, so a field can be missing or
 * non-finite (a NaN rect from a degenerate layout, an absent dpr). Both the
 * elements-json converter and the integrity gate have to read such a value as a
 * definite number rather than propagate NaN into a rect comparison, where every
 * inequality silently answers false and a real defect reads as clean.
 */

export function finiteNumber(value, fallback = 0) {
  return typeof value === "number" && Number.isFinite(value) ? value : fallback;
}
