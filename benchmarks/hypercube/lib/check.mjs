// Grades one reply line against the answer key. Solutions are checked by
// simulation, so any sequence that solves the puzzle counts.
import { allStickers, applyMoves, inverseMove, isSolved, parseMove, parseMoves } from "./puzzle.mjs";

export function scrambleOf(answer) {
  return answer.reference.map((t) => inverseMove(parseMove(t, answer.n))).reverse();
}

export function grade(problem, answer, reply) {
  if (reply == null) return { ok: false, reason: "missing" };
  if (problem.task === "track") {
    const m = reply.replace(/\s+/g, "").match(/^\(([-+\d,]+)\)([+-][a-z])$/);
    if (!m) return { ok: false, reason: "unparsable" };
    const at = `(${m[1].split(",").map(Number).join(",")})`;
    return { ok: at === answer.at && m[2] === answer.facing, reason: at === answer.at ? (m[2] === answer.facing ? "ok" : "facing") : "position" };
  }
  const moves = parseMoves(reply, problem.n);
  if (!moves) return { ok: false, reason: "unparsable" };
  if (moves.length > problem.max_moves) return { ok: false, reason: "too_long" };
  const solved = isSolved(applyMoves(applyMoves(allStickers(problem.n), scrambleOf(answer)), moves));
  return { ok: solved, reason: solved ? "ok" : "not_solved", length: moves.length };
}
