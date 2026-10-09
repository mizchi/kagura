// The n-dimensional 3x3x...x3 puzzle (n = 3 is the Rubik's cube, n = 4 the
// 3^4 hypercube of Magic Cube 4D), as a set of stickers.
//
// A piece sits at p in {-1,0,1}^n and carries one sticker per nonzero
// coordinate, facing sign(p_a) * e_a. A move `S:i>j` takes the layer whose
// S-axis coordinate equals S's sign and rotates it 90 degrees in the i-j
// plane, turning +i into +j: new_j = old_i, new_i = -old_j. Facings rotate
// the same way. Centres (one nonzero coordinate) never move, so "solved"
// means every sticker shows the colour of the direction it faces.

export const AXES = "xyzwv";

export function facingName(f) {
  const a = f.findIndex((c) => c !== 0);
  return `${f[a] > 0 ? "+" : "-"}${AXES[a]}`;
}

export const formatPos = (p) => `(${p.join(",")})`;

export function parseMove(text, n) {
  const m = text.trim().match(/^([+-])([a-z]):([a-z])\s*>\s*([a-z])$/);
  if (!m) return null;
  const [axis, i, j] = [m[2], m[3], m[4]].map((c) => AXES.indexOf(c));
  if ([axis, i, j].some((k) => k < 0 || k >= n) || new Set([axis, i, j]).size !== 3) return null;
  return { sign: m[1] === "+" ? 1 : -1, axis, i, j };
}

export const formatMove = (m) => `${m.sign > 0 ? "+" : "-"}${AXES[m.axis]}:${AXES[m.i]}>${AXES[m.j]}`;
export const inverseMove = (m) => ({ ...m, i: m.j, j: m.i });

// Splits "a, b c;d" into moves; null if any token is not a valid move.
export function parseMoves(text, n) {
  const tokens = text.split(/[\s,;]+/).filter(Boolean);
  const moves = tokens.map((t) => parseMove(t, n));
  return moves.every(Boolean) ? moves : null;
}

function rot(v, i, j) {
  const r = [...v];
  r[j] = v[i];
  r[i] = -v[j];
  return r;
}

export function applyToSticker(s, m) {
  if (s.p[m.axis] !== m.sign) return s;
  return { ...s, p: rot(s.p, m.i, m.j), f: rot(s.f, m.i, m.j) };
}

export function allStickers(n) {
  const out = [];
  const total = 3 ** n;
  for (let k = 0; k < total; k++) {
    const p = [];
    for (let d = 0, r = k; d < n; d++, r = Math.floor(r / 3)) p.push((r % 3) - 1);
    for (let a = 0; a < n; a++) {
      if (p[a] === 0) continue;
      const f = Array(n).fill(0);
      f[a] = p[a];
      out.push({ p, f, color: facingName(f) });
    }
  }
  return out;
}

export const applyMoves = (stickers, moves) => stickers.map((s) => moves.reduce(applyToSticker, s));

// Stickers whose colour differs from their facing, sorted by location.
export function visibleDifferences(stickers) {
  return stickers
    .filter((s) => s.color !== facingName(s.f))
    .map((s) => ({ at: formatPos(s.p), facing: facingName(s.f), color: s.color }))
    .sort((a, b) => (a.at + a.facing < b.at + b.facing ? -1 : 1));
}

export const isSolved = (stickers) => visibleDifferences(stickers).length === 0;

export function randomMove(rng, n, prev) {
  for (;;) {
    const axis = rng.int(n);
    const sign = rng.next() < 0.5 ? -1 : 1;
    if (prev && prev.axis === axis && prev.sign === sign) continue; // same layer would merge
    const rest = [...Array(n).keys()].filter((k) => k !== axis);
    const i = rest.splice(rng.int(rest.length), 1)[0];
    const j = rest[rng.int(rest.length)];
    return { sign, axis, i, j };
  }
}

export class Rng {
  constructor(seed) {
    this.s = seed >>> 0 || 1;
  }
  next() {
    // mulberry32
    let t = (this.s = (this.s + 0x6d2b79f5) >>> 0);
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  }
  int(k) {
    return Math.floor(this.next() * k);
  }
}
