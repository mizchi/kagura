// Ported from mizchi/modeling-playground game.
import type { Solid, StageDefinition } from './types.ts';

const solid=(id:string,kind:Solid['kind'],center:Solid['center'],size:Solid['size'],color:string):Solid=>({id,kind,center,size,color});
// Keep deployment fixed, with enough rear clearance for the longer TPS boom.
const bounds={minX:-48,maxX:48,minZ:-60,maxZ:54};
const width=bounds.maxX-bounds.minX,depth=bounds.maxZ-bounds.minZ,centerZ=(bounds.minZ+bounds.maxZ)/2;
export const STAGE:StageDefinition={
  bounds,spawn:[0,0,-36],
  solids:[
    solid('hangar-a','warehouse',[-28,7,-15],[22,14,30],'#656f74'),
    solid('hangar-b','warehouse',[28,9,-4],[22,18,26],'#616a6c'),
    solid('cooling-a','tower',[-33,13,34],[16,26,14],'#707b7e'),
    solid('cooling-b','tower',[33,16,38],[16,32,18],'#606e76'),
    solid('central-cover','barrier',[0,1.7,6],[12,3.4,3],'#69716e'),
    solid('container-a','container',[-12,1.6,20],[5,3.2,12],'#9a6746'),
    solid('container-b','container',[-17,1.6,20],[5,3.2,12],'#415e64'),
    solid('container-c','container',[16,1.6,-28],[5,3.2,12],'#9b7949'),
    solid('container-d','container',[14,1.6,34],[5,3.2,12],'#415e64'),
    solid('north-wall','wall',[0,4,bounds.maxZ+1],[width+4,8,2],'#677271'),
    solid('south-wall','wall',[0,4,bounds.minZ-1],[width+4,8,2],'#677271'),
    solid('east-wall','wall',[bounds.maxX+1,4,centerZ],[2,8,depth],'#677271'),
    solid('west-wall','wall',[bounds.minX-1,4,centerZ],[2,8,depth],'#677271'),
  ],
  targets:[{id:'B-01',position:[-9,0,-9],yaw:.5},{id:'B-02',position:[10,0,20],yaw:3.6},{id:'B-03',position:[-6,0,41],yaw:Math.PI}],
};

export function stageColliders(stage:StageDefinition):Solid[] {
  return [...stage.solids,...stage.targets.map(t=>solid(t.id,'barrier',[t.position[0],3,t.position[2]],[5.4,6,5.4],'#000'))];
}
