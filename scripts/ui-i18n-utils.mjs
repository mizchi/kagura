/**
 * Game-UI counterpart of `vlmkit stress i18n`.
 *
 * Canvas text is not DOM text, so the DOM inflator cannot run. This module
 * expands the strings the snapshot already published, re-measures them with
 * the same `dot_text_size` arithmetic the renderer uses, and re-runs the
 * integrity gate. Glyphs the 3x5 atlas cannot draw are reported separately —
 * `glyph_pattern` returns a blank cell for those, which is silent tofu.
 */

import { unwrapSnapshot } from "./ui-snapshot-utils.mjs";
import { analyzeSnapshot } from "./ui-integrity-utils.mjs";

const ARABIC_SAMPLE = [..."نقاطالحياة"];

/** Code points `glyph_pattern` actually draws. The `_` arm is a blank cell. */
export const DOT_TEXT_GLYPHS = new Set([
  ..."0123456789",
  ..."ABCDEFGHIJKLMNOPQRSTUVWXYZ",
  ..." :>/+-%",
]);

export const I18N_PROFILES = ["de", "fullwidth", "rtl", "emoji", "digits"];

function isMark(code) {
  return (code >= 0xfe00 && code <= 0xfe0f) || (code >= 0x0300 && code <= 0x036f);
}

function isFullwidthChar(ch) {
  const code = ch.codePointAt(0);
  return code === 0x3000 || (code >= 0xff01 && code <= 0xff5e);
}

export function dotTextSize(charCount, scale = 1) {
  if (charCount <= 0) return { width: 0, height: 0 };
  const px = 3 * scale;
  const charW = 3 * px;
  const gap = px;
  return { width: charCount * charW + (charCount - 1) * gap, height: 5 * px };
}

export function inflateWords(text, factor) {
  return text.split(/(\s+)/).map((token) => {
    if (token === "" || /^\s+$/.test(token)) return token;
    const extra = Math.max(0, Math.ceil(token.length * factor) - token.length);
    return token + "X".repeat(extra);
  }).join("");
}

export function toFullwidth(text) {
  let out = "";
  for (const ch of text) {
    const code = ch.codePointAt(0);
    if (code === 0x20) out += "\u3000";
    else if (code >= 0x21 && code <= 0x7e) out += String.fromCodePoint(code + 0xfee0);
    else out += ch;
  }
  return out;
}

function toRtl(text) {
  let i = 0;
  return [...text].map((ch) => (/\s/.test(ch) ? ch : ARABIC_SAMPLE[i++ % ARABIC_SAMPLE.length])).join("");
}

function stressDigits(text) {
  return text.replace(/-?\d[\d,]*/g, (match) => (match.startsWith("-") ? "-99999" : "9,999,999"));
}

export function applyProfile(text, profile) {
  switch (profile) {
    case "de":
      return inflateWords(text, 1.35);
    case "fullwidth":
      return toFullwidth(text);
    case "rtl":
      return toRtl(text);
    case "emoji":
      return `${text} ⚠️`;
    case "digits":
      return stressDigits(text);
    default:
      throw new Error(`unknown i18n profile: ${profile}`);
  }
}

export function missingGlyphs(text, alphabet = DOT_TEXT_GLYPHS) {
  const seen = new Set();
  const missing = [];
  for (const ch of text) {
    const code = ch.codePointAt(0);
    if (isMark(code) || /\s/.test(ch)) continue;
    if (alphabet.has(ch) || seen.has(ch)) continue;
    seen.add(ch);
    missing.push(ch);
  }
  return missing;
}

function cellCount(text, profile) {
  let count = 0;
  for (const ch of text) {
    const code = ch.codePointAt(0);
    if (isMark(code)) continue;
    if (profile === "fullwidth" && isFullwidthChar(ch)) count += 2;
    else if (profile === "emoji" && code > 0xff) count += 2;
    else count += 1;
  }
  return count;
}

function rescaleMeasured(node, newText, profile) {
  const height = node.text_measured != null && typeof node.text_measured.height === "number"
    ? node.text_measured.height
    : 15;
  const scale = height / 15;
  return dotTextSize(cellCount(newText, profile), scale);
}

export function stressSnapshot(input, profile) {
  const snapshot = structuredClone(unwrapSnapshot(input));
  snapshot.nodes = snapshot.nodes.map((node) => {
    if (typeof node.text !== "string" || node.text.trim() === "") return node;
    const text = applyProfile(node.text, profile);
    return { ...node, text, text_measured: rescaleMeasured(node, text, profile) };
  });
  return snapshot;
}

function resolveProfiles(profiles) {
  if (profiles == null || profiles.length === 0) return ["de"];
  if (profiles.length === 1 && profiles[0] === "all") return [...I18N_PROFILES];
  for (const name of profiles) {
    if (!I18N_PROFILES.includes(name)) throw new Error(`unknown i18n profile: ${name}`);
  }
  return profiles;
}

export function analyzeI18nStress(input, { profiles, alphabet = DOT_TEXT_GLYPHS } = {}) {
  const original = unwrapSnapshot(input);
  const report = { ok: true, profiles: {} };
  for (const name of resolveProfiles(profiles)) {
    const stressed = stressSnapshot(original, name);
    const geometry = analyzeSnapshot(stressed);
    const missing = [];
    for (const node of stressed.nodes) {
      if (typeof node.text !== "string" || node.text.trim() === "") continue;
      const chars = missingGlyphs(node.text, alphabet);
      if (chars.length === 0) continue;
      missing.push({
        id: typeof node.id === "string" ? node.id : "",
        path: typeof node.path === "string" ? node.path : "",
        chars,
      });
    }
    report.profiles[name] = { findings: geometry.findings, missingGlyphs: missing, nodes: stressed.nodes };
    if (geometry.findings.length > 0 || missing.length > 0) report.ok = false;
  }
  return report;
}

export function formatI18nReport(result, { source = "" } = {}) {
  const lines = [];
  if (source !== "") lines.push(`source: ${source}`);
  lines.push(`verdict: ${result.ok ? "CLEAN" : "DEFECTS"}`);
  for (const [name, profile] of Object.entries(result.profiles)) {
    lines.push(`profile: ${name}`);
    for (const finding of profile.findings) lines.push(`[${finding.kind}] ${finding.message}`);
    for (const missing of profile.missingGlyphs) {
      const label = missing.id || missing.path || "<unnamed>";
      lines.push(`[missing-glyph] ${label}: ${missing.chars.join(", ")} not in the renderer alphabet`);
    }
    if (profile.findings.length === 0 && profile.missingGlyphs.length === 0) {
      lines.push("  clean");
    }
  }
  return lines.join("\n");
}
