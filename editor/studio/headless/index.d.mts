import type { SceneDocument, StudioAPI, Reply, Transaction } from '../public/contract.d.ts';
export type EditorRequest =
  | { method: 'snapshot' }
  | { method: 'dispatch'; transaction: Transaction }
  | { method: 'undo' | 'redo'; expectedRevision: number }
  | { method: 'select'; id: string }
  | { method: 'seek'; time: number }
  | { method: 'layout'; value: 'scene' | 'action' };
export interface HeadlessEditor extends StudioAPI {
  request(request: EditorRequest): Reply;
}
export function createHeadlessEditor(document?: SceneDocument): HeadlessEditor;
