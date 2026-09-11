/** Resource id/kind: kagura.scene2d, resource version: 1. */
export interface Scene2DObject {
  id: string;
  name: string;
  /** Interpreted by the game-owned adapter (e.g. bird, ground). */
  kind: string;
  x: number;
  y: number;
  width: number;
  height: number;
  color: number;
}
export interface Scene2D {
  coordinates: 'pixels-y-down';
  width: number;
  height: number;
  background: number;
  objects: Scene2DObject[];
}
export type Object2DChanges = Partial<
  Pick<Scene2DObject, 'x' | 'y' | 'width' | 'height' | 'color' | 'name'>
>;
export interface Scene2DProfile {
  game: string;
  fields: Record<string, (keyof Object2DChanges)[]>;
  /** Throws if the layout cannot be used by this game. */
  validate(layout: Scene2D): void;
  /** Normalize coupled fields before validation, without mutating inputs. */
  edit(object: Scene2DObject, changes: Object2DChanges, layout: Scene2D): Object2DChanges;
}
