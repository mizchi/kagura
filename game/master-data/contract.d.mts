export type Scalar = string | number | boolean | null;
export interface Issue {
  code: string;
  message: string;
  table?: string;
  row?: string;
  column?: string;
}
export interface Column {
  id: string;
  label: string;
  type: "string" | "integer" | "number" | "boolean" | "enum" | "reference";
  nullable?: boolean;
  readOnly?: boolean;
  unique?: boolean;
  min?: number;
  max?: number;
  step?: number;
  minLength?: number;
  maxLength?: number;
  options?: string[];
  table?: string;
  default?: Scalar;
}
export interface Table {
  id: string;
  label: string;
  primaryKey: string;
  labelField?: string;
  description?: string;
  columns: Column[];
  rowIds?: string[];
  lockedValues?: Record<string, Record<string, Scalar>>;
  minRows?: number;
  maxRows?: number;
  allowAdd?: boolean;
  allowRemove?: boolean;
}
export interface Adapter {
  apiVersion: 1;
  schema: { id: string; version: number; title: string; tables: Table[] };
  parameters?: Record<string, { table: string; row: string; column: string }>;
  validate?(document: Document): Issue[];
}
export interface Document {
  format: "kagura.master-data";
  version: number;
  game: string;
  tables: Record<string, Record<string, Scalar>[]>;
}
export interface Snapshot {
  revision: number;
  document: Document;
  issues: Issue[];
  valid: boolean;
  dirty: boolean;
  canUndo: boolean;
  canRedo: boolean;
}
export interface Session {
  readonly adapter: Adapter;
  snapshot(): Snapshot;
  document(): Document;
  edit(edit: {
    revision: number;
    table: string;
    row: string;
    column: string;
    value: Scalar;
  }): void;
  add(table: string, row: Record<string, Scalar>, revision: number): void;
  remove(table: string, row: string, revision: number): void;
  import(document: Document, revision: number): void;
  undo(revision: number): void;
  redo(revision: number): void;
  acknowledge(revision: number): void;
}
export function validateAdapter(adapter: Adapter): Adapter;
export function validateDocument(adapter: Adapter, document: unknown): Issue[];
export function createMasterDataSession(
  adapter: Adapter,
  document: Document,
): Session;
export function parameterSpecs(
  adapter: Adapter,
  document: Document,
): Array<{
  name: string;
  min: number;
  max: number;
  step: number;
  initial: number;
}>;
export function applyParameters(
  adapter: Adapter,
  document: Document,
  parameters: Record<string, number>,
): Document;
