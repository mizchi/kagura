// Prompt text for hypercube-v1. Changing any wording means a new version.
import { formatMove } from "./puzzle.mjs";

export const PROMPT_VERSION = "hypercube-prompt-v1";

export const RULES = `## The puzzle

An n-dimensional 3x3x...x3 twisty puzzle. n = 3 is the ordinary Rubik's cube;
n = 4 is the 3^4 hypercube (as in Magic Cube 4D); n = 5 goes one step further.
Axes are named x, y, z, w, v; an n-dimensional problem uses the first n.

- Pieces sit at integer positions p in {-1,0,1}^n, written (x,y,z,...).
- A piece has one sticker for each nonzero coordinate: if p_a = +1 it has a
  sticker facing +a, if p_a = -1 one facing -a. A sticker's location is
  (position, facing).
- Colours are named after directions (+x, -w, ...). On the solved puzzle every
  sticker's colour equals the direction it faces.

## Moves

A move is written S:i>j, where S is a signed axis (for example +w) and i, j
are two different axes, both different from S's axis.

- It acts on the layer of pieces whose S-axis coordinate equals the sign of S
  (+w:... acts on every piece with w = +1).
- Those pieces rotate 90 degrees in the i-j plane so that the +i direction
  turns into +j: new_j = old_i, new_i = -old_j, all other coordinates unchanged.
- Each sticker's facing turns the same way: +i -> +j, +j -> -i, -i -> -j,
  -j -> +i; facings along other axes are unchanged.
- S:j>i is the inverse of S:i>j. Pieces outside the layer do not move.

Example (n = 3): +z:x>y moves the piece at (1,0,1) to (0,1,1); its sticker
facing +x now faces +y, and its sticker facing +z still faces +z.`;

export function problemText(p) {
  if (p.task === "track") {
    return [
      `### ${p.id}`,
      `n = ${p.n}. Moves, applied in order: ${p.moves.join(", ")}`,
      `Start: the sticker at ${p.start.at} facing ${p.start.facing}.`,
      `Question: after all moves, at which position and facing is that sticker?`,
    ].join("\n");
  }
  return [
    `### ${p.id}`,
    `n = ${p.n}. The puzzle was solved, then ${p.depth} move(s) were applied. Every sticker whose colour`,
    `differs from its facing is listed as "position facing: colour"; all others show their own facing's colour.`,
    ...p.state.map((s) => `${s.at} ${s.facing}: ${s.color}`),
    `Question: give a move sequence (at most ${p.max_moves} moves) that returns the puzzle to solved.`,
  ].join("\n");
}

const FORMAT = {
  track: "<id>: (<coordinates>) <facing>        e.g.  track-000: (1,0,-1,1) +z",
  solve: "<id>: <moves separated by commas>   e.g.  solve-000: +w:y>x, -z:x>w",
};

export function batchPrompt(task, problems) {
  return [
    `# Hypercube benchmark (${PROMPT_VERSION})`,
    "",
    RULES,
    "",
    "## Problems",
    "",
    problems.map(problemText).join("\n\n"),
    "",
    "## Answer format",
    "",
    "Work everything out yourself. End your reply with exactly one line per problem, in order:",
    FORMAT[task],
  ].join("\n");
}

export const movesText = (moves) => moves.map(formatMove);
