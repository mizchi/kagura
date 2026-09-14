// Hand-authored JS ABI contract for game/inventory_web.
export interface Footprint {
  width:number; height:number; rotated:boolean; cells:readonly (readonly [number,number])[];
}
export interface InventoryItem extends Footprint {source:number;slot:number;x:number;y:number}
export interface InventoryView {width:number;height:number;items:readonly InventoryItem[]}
export function rotatedCells(item:Footprint,rotated?:boolean):[number,number][];
export function dimensions(item:Footprint,rotated?:boolean):[number,number];
export function previewPlacement(view:InventoryView,item:InventoryItem,x:number,y:number,rotated?:boolean):{
  cells:[number,number][]; valid:boolean; swap:boolean;
};
export interface Rect {left:number;top:number;right:number;bottom:number}
export function isInventoryGroundDrop(x:number,y:number,dialog:Rect|null,surface:Rect|null):boolean;
export interface StatItem {slot:number;stats:readonly (readonly [string,number])[]}
export function comparisonRows(view:{equipment:readonly {id:number;item?:{stats:StatItem['stats']}|null}[]},item:StatItem):{
  label:string;value:number;before:number;delta:number;
}[];
