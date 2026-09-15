import type {
  ModelCommand,
  ModelDocument,
  ModelDocumentInput,
  ModelSnapshot,
} from "../public/modeling.d.ts";
/** Headless editing uses the same MoonBit model as the browser. Invalid commands throw. */
export function createModelEditor(document?: ModelDocumentInput): {
  request(command: ModelCommand): ModelSnapshot;
  snapshot(): ModelSnapshot;
  subscribe(listener: (snapshot: ModelSnapshot) => void): () => void;
};
export function kawaikoDocument(): ModelDocument;
/** Pure evaluation from neutral. Weights must be known expression IDs in [0, 1]. */
export function evaluateModel(
  document: ModelDocumentInput,
  weights?: Record<string, number>,
): ModelDocument;
