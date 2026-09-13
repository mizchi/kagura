// Shared spatial footprint operations for pointer previews and pad navigation.
export const rotatedCells=(item,rotated=item.rotated)=>item.cells.map(([x,y])=>rotated?[item.height-1-y,x]:[x,y]);
export const dimensions=(item,rotated=item.rotated)=>rotated?[item.height,item.width]:[item.width,item.height];
export function previewPlacement(view,item,x,y,rotated) {
  const cells=rotatedCells(item,rotated).map(([cx,cy])=>[x+cx,y+cy]);
  const inside=cells.every(([cx,cy])=>cx>=0&&cy>=0&&cx<view.width&&cy<view.height);
  const overlaps=view.items.filter(other=>other.source!==item.source&&other.x>=0&&rotatedCells(other).some(([cx,cy])=>cells.some(([tx,ty])=>tx===other.x+cx&&ty===other.y+cy)));
  return {cells,valid:inside&&overlaps.length<=1&&(item.source>=0||overlaps.every(other=>other.slot===item.slot)),swap:overlaps.length===1};
}
