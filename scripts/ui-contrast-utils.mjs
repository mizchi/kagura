/**
 * PNG-derived text contrast for canvas UI.
 *
 * vlmkit's image-only `check integrity` skips `low-contrast-text` because it
 * has no computed colors. Crop the node (intersected with its scissor) out of
 * the frame and split ink from backdrop the same way `check asset --against-bg`
 * splits figure from ground: two luminance clusters, then the WCAG 2 contrast
 * ratio of their mean colours.
 */

export const WCAG_NORMAL_FLOOR = 4.5;
export const WCAG_LARGE_FLOOR = 3;
/** WCAG 2.2 large text: 18pt ≈ 24 CSS px. Bold-at-14pt is unavailable without weight. */
export const LARGE_TEXT_PX = 24;

const MIN_PIXELS = 4;
const MIN_MINORITY_SHARE = 0.02;

function srgbToLinear(channel) {
  const s = channel / 255;
  return s <= 0.04045 ? s / 12.92 : ((s + 0.055) / 1.055) ** 2.4;
}

export function relativeLuminance(r, g, b) {
  return 0.2126 * srgbToLinear(r) + 0.7152 * srgbToLinear(g) + 0.0722 * srgbToLinear(b);
}

function luminanceOf(color) {
  return Array.isArray(color) ? relativeLuminance(color[0], color[1], color[2]) : color;
}

export function contrastRatio(a, b) {
  const la = luminanceOf(a);
  const lb = luminanceOf(b);
  const [hi, lo] = la >= lb ? [la, lb] : [lb, la];
  return (hi + 0.05) / (lo + 0.05);
}

function hex(r, g, b) {
  const byte = (value) => Math.round(value).toString(16).padStart(2, "0");
  return `#${byte(r)}${byte(g)}${byte(b)}`;
}

function luma8(r, g, b) {
  return Math.round(0.2126 * r + 0.7152 * g + 0.0722 * b);
}

function otsuThreshold(hist, total) {
  let sum = 0;
  for (let i = 0; i < 256; i += 1) sum += i * hist[i];
  let sumB = 0;
  let wB = 0;
  let maxVar = -1;
  let threshold = 0;
  for (let t = 0; t < 256; t += 1) {
    wB += hist[t];
    if (wB === 0) continue;
    const wF = total - wB;
    if (wF === 0) break;
    sumB += t * hist[t];
    const mB = sumB / wB;
    const mF = (sum - sumB) / wF;
    const between = wB * wF * (mB - mF) ** 2;
    if (between >= maxVar) {
      maxVar = between;
      threshold = t;
    }
  }
  return threshold;
}

/**
 * Two-cluster contrast of the opaque pixels in `rect`.
 *
 * Returns null when the crop is empty, too small, or a single colour — there
 * is no figure/ground pair to score, and inventing 21:1 would hide a missing
 * glyph just as badly as inventing 1:1 would flag a solid panel.
 */
export function measureRegionContrast(image, rect) {
  if (image == null || image.data == null) return null;
  const width = image.width;
  const height = image.height;
  const left = Math.max(0, Math.floor(rect.left));
  const top = Math.max(0, Math.floor(rect.top));
  const right = Math.min(width, Math.ceil(rect.right ?? rect.left + rect.width));
  const bottom = Math.min(height, Math.ceil(rect.bottom ?? rect.top + rect.height));
  if (right - left < 1 || bottom - top < 1) return null;

  const hist = new Array(256).fill(0);
  const pixels = [];
  for (let y = top; y < bottom; y += 1) {
    for (let x = left; x < right; x += 1) {
      const i = (y * width + x) * 4;
      if (image.data[i + 3] < 16) continue;
      const r = image.data[i];
      const g = image.data[i + 1];
      const b = image.data[i + 2];
      const luma = luma8(r, g, b);
      hist[luma] += 1;
      pixels.push({ r, g, b, luma });
    }
  }
  if (pixels.length < MIN_PIXELS) return null;

  const threshold = otsuThreshold(hist, pixels.length);
  const lo = { r: 0, g: 0, b: 0, n: 0 };
  const hi = { r: 0, g: 0, b: 0, n: 0 };
  for (const pixel of pixels) {
    const bucket = pixel.luma <= threshold ? lo : hi;
    bucket.r += pixel.r;
    bucket.g += pixel.g;
    bucket.b += pixel.b;
    bucket.n += 1;
  }
  if (lo.n === 0 || hi.n === 0) return null;
  const minority = Math.min(lo.n, hi.n);
  if (minority < 2 || minority / pixels.length < MIN_MINORITY_SHARE) return null;

  const mean = (bucket) => [bucket.r / bucket.n, bucket.g / bucket.n, bucket.b / bucket.n];
  const loRgb = mean(lo);
  const hiRgb = mean(hi);
  const fgRgb = lo.n <= hi.n ? loRgb : hiRgb;
  const bgRgb = lo.n <= hi.n ? hiRgb : loRgb;
  return {
    ratio: Math.round(contrastRatio(loRgb, hiRgb) * 100) / 100,
    fg: hex(...fgRgb),
    bg: hex(...bgRgb),
  };
}
