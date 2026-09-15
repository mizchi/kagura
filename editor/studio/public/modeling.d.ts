/** Mesh modeling documents contain no renderer state. Metres, Y up, +Z forward. */
export interface ModelMesh {
  id: string;
  name: string;
  color: number;
  position: [number, number, number];
  vertices: [number, number, number][];
  /** Indexed polygons, 3-32 unique indices each; concave faces are allowed. */
  faces: number[][];
}
export interface ModelDocument {
  version: 1;
  format: "kagura.mesh";
  name: string;
  source: string;
  nodes: ModelMesh[];
}
export type ModelMode = "object" | "vertex" | "face";
export type ModelTransform = "move" | "rotate" | "scale" | "extrude";
export interface ModelSnapshot {
  document: ModelDocument;
  revision: number;
  selected: string;
  mode: ModelMode;
  vertices: number[];
  face: number;
  canUndo: boolean;
  canRedo: boolean;
  modal: null | { kind: ModelTransform; normal: [number, number, number] };
}
export type ModelCommand =
  | {
      op:
        | "snapshot"
        | "undo"
        | "redo"
        | "confirm"
        | "cancel"
        | "duplicate"
        | "remove";
    }
  | { op: "select"; id: string }
  | { op: "mode"; value: ModelMode }
  | { op: "vertices"; indices: number[] }
  | { op: "face"; index: number }
  | { op: "begin"; kind: ModelTransform }
  /** Absolute delta from begin, never accumulated. Rotation values are XYZ radians. */
  | { op: "preview"; value: [number, number, number] }
  | { op: "replace"; document: ModelDocument }
  | { op: "add"; kind: "cube" | "sphere" }
  | { op: "material"; color: number }
  | { op: "rename"; name: string };
export interface ModelingAPI {
  open(): void;
  close(): void;
  active(): boolean;
  snapshot(): ModelSnapshot;
  /** Invalid edits return null and report a message; the document remains unchanged. */
  request(command: ModelCommand): ModelSnapshot | null;
  save(): Promise<void>;
  exportJSON(): void;
  exportGLB(): Promise<void>;
  stats(): {
    drawCalls: number;
    triangles: number;
    geometries: number;
    camera: "orthographic" | "perspective";
  } | null;
}
