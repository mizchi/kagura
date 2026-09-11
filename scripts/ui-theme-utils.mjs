/**
 * Palette gate against a declared UI theme.
 *
 * vlmkit's `check palette A B` diffs two PNGs. Game UI needs the same
 * judgement against a token table: colors in the frame that sit far from
 * every token are hard-coded literals; tokens the frame does not use are
 * listed but not a defect (a pause screen will not paint every hover color).
 */

const HEX = /^#([0-9a-f]{6})$/i;

export function parseHex(hex) {
  const match = HEX.exec(String(hex).trim());
  if (match == null) throw new Error(`theme token must be #rrggbb, got "${hex}"`);
  const n = Number.parseInt(match[1], 16);
  return { r: (n >> 16) & 255, g: (n >> 8) & 255, b: n & 255 };
}

export function rgbDistance(a, b) {
  return Math.hypot(a.r - b.r, a.g - b.g, a.b - b.b);
}

function normalizeHex(hex) {
  return `#${parseHex(hex).r.toString(16).padStart(2, "0")}${parseHex(hex).g.toString(16).padStart(2, "0")}${parseHex(hex).b.toString(16).padStart(2, "0")}`;
}

export function loadTheme(theme) {
  if (theme == null || typeof theme !== "object") throw new Error("theme must be an object");
  if (theme.version !== 1) throw new Error(`unsupported theme version: ${theme.version}`);
  if (!Array.isArray(theme.tokens) || theme.tokens.length === 0) {
    throw new Error("theme needs at least one token");
  }
  const tokens = theme.tokens.map((token) => normalizeHex(token));
  const maxDistance = theme.maxDistance ?? 12;
  const minShare = theme.minShare ?? 0.002;
  if (!Number.isFinite(maxDistance) || maxDistance < 0) throw new Error("invalid maxDistance");
  if (!Number.isFinite(minShare) || minShare < 0 || minShare > 1) throw new Error("invalid minShare");
  return { version: 1, tokens, maxDistance, minShare };
}

function nearestToken(color, tokens) {
  let best = { token: tokens[0], distance: Infinity };
  for (const token of tokens) {
    const distance = rgbDistance(color, parseHex(token));
    if (distance < best.distance) best = { token, distance };
  }
  return best;
}

export function analyzeTheme(palette, themeInput) {
  const theme = loadTheme(themeInput);
  const extras = [];
  const used = new Set();
  for (const entry of palette) {
    const share = entry.share ?? 0;
    if (share < theme.minShare) continue;
    const color = parseHex(entry.hex);
    const match = nearestToken(color, theme.tokens);
    if (match.distance <= theme.maxDistance) {
      used.add(match.token);
      continue;
    }
    extras.push({
      hex: normalizeHex(entry.hex),
      share,
      distance: Math.round(match.distance * 100) / 100,
      nearest: match.token,
      message:
        `${normalizeHex(entry.hex)} (${(share * 100).toFixed(2)}%) is ${match.distance.toFixed(1)} ` +
        `from the nearest token ${match.token} — hard-coded literal`,
    });
  }
  const unused = theme.tokens.filter((token) => !used.has(token));
  return { ok: extras.length === 0, extras, unused, theme };
}

export function formatThemeReport(result, { source = "" } = {}) {
  const lines = [];
  if (source !== "") lines.push(`source: ${source}`);
  lines.push(`verdict: ${result.ok ? "CLEAN" : "DEFECTS"}`);
  for (const extra of result.extras) lines.push(`[hardcoded-color] ${extra.message}`);
  if (result.unused.length > 0) {
    lines.push(`unused tokens: ${result.unused.join(", ")}`);
  }
  return lines.join("\n");
}
