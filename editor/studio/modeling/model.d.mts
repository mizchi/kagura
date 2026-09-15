import type {
  ModelCommand,
  ModelDocument,
  ModelSnapshot,
} from "../public/modeling.d.ts";
/** Headless editing uses the same MoonBit model as the browser. Invalid commands throw. */
export function createModelEditor(document?: ModelDocument): {
  request(command: ModelCommand): ModelSnapshot;
  snapshot(): ModelSnapshot;
  subscribe(listener: (snapshot: ModelSnapshot) => void): () => void;
};
export function kawaiikoDocument(): ModelDocument;
