// Hand-authored JS ABI contract for the MoonBit-generated ESM. No implementation.
export interface Stick { x:number; y:number }
export interface ControlCommand { key:number; payload:unknown }
export interface ControlInput {
  version:1;
  move(id:number,x:number,y:number):boolean;
  hold(id:number,action:string):void;
  release(id:number):void;
  tap(key:number,payload?:unknown):boolean;
  consumeCommand():ControlCommand|null;
  snapshot():Stick & {actions:string[]};
  clear():void;
}
export function stickVector(dx:number,dy:number,radius:number,options?:{deadZone?:number}):Stick;
export function createControlInput(options?:{capacity?:number}):ControlInput;

export type MenuDirection='up'|'down'|'left'|'right';
export interface PadSnapshot {
  index:number; id:string; mapping:string; connected?:boolean; profile?:string;
  axes:ArrayLike<number>; buttons:ArrayLike<{pressed:boolean;value:number}>;
}
export interface PadFrame {
  connected:boolean; supported:boolean; ready:boolean; index:number; id:string;
  profile:string|null; move:Stick; look:Stick;
  down:number[]; pressed:number[]; released:number[];
  activity:boolean; navigation:MenuDirection|null; dt:number;
}
export function normalizeGamepad(pad:PadSnapshot):PadSnapshot|null;
export function createGamepadReader(options?:{deadZone?:number}):{
  step(pads:ArrayLike<PadSnapshot|null>|null,options?:{enabled?:boolean;now?:number}):PadFrame;
};

export interface ObjectPatch {full:boolean;set:Record<PropertyKey,unknown>;remove:string[]}
export function applyObjectPatch(previous:Record<PropertyKey,unknown>|null,patch:ObjectPatch):Record<PropertyKey,unknown>;
export function createDependencyGate():(dependencies:readonly unknown[])=>boolean;
export function percentile(values:ArrayLike<number>,p:number):number;
export interface FrameSummary {frames:number;elapsedMs:number;fps:number;p50IntervalMs:number;p95IntervalMs:number}
export function summarizeIntervals(timestamps:ArrayLike<number>):FrameSummary;
export interface FrameProfile {
  version:1; frame:number;
  updateMs:number|null; drawCallbackMs:number|null; renderCommandsMs:number|null;
  renderCpuMs:number|null; renderUploadCpuMs:number|null; renderBindGroupCpuMs:number|null;
  renderEncodeCpuMs:number|null; renderSubmitCpuMs:number|null; gpuFrameMs:number|null;
  gpuTimingMethod:string|null; drawCalls:number; indexCount:number; instanceCount:number;
  sharedGeometryDraws:number; residentGeometryBuffers:number;
}
export function readFrameProfile(host?:object):Readonly<FrameProfile>|null;
export function installFrameProfiler(host?:object):Readonly<{version:1;snapshot():Readonly<FrameProfile>|null}>;

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

/** Clips are validated by the asset loader: nonempty, positive duration and fps. */
export interface MotionClip {id:string;duration:number;fps:number}
export interface MotionSnapshot {clip:string;time:number;duration:number;fps:number;frame:number;playing:boolean;speed:number;loop:boolean}
export interface MotionPlayer {
  snapshot():MotionSnapshot; selectClip(id:string):void; play():void; pause():void;
  seek(time:number):void; step(direction:-1|1):void; setSpeed(speed:number):void;
  setLoop(loop:boolean):void; tick(delta:number):void;
}
export function createMotionPlayer(asset:{clips:readonly MotionClip[]}):Readonly<MotionPlayer>;

export interface DrawPolicy {
  instanceCount?:number; instance_count?:number; resourceCacheKey?:number; resource_cache_key?:number;
  isCustom?:boolean; vertexStrideHint?:number; shaderSource?:string;
}
export function isStride32(source:string):boolean;
export function isStride64(source:string):boolean;
export function is3DShader(source:string):boolean;
export function commandNeedsDepth(command:DrawPolicy):boolean;
export function parseTextureBindings(source:string):{binding:number;type:'texture'|'sampler'}[];
export function getInstanceCount(command:DrawPolicy|null):number;
export function getResourceCacheKey(command:DrawPolicy|null):number;
export function equalDwords(a:ArrayLike<number>|null,b:ArrayLike<number>|null,count?:number):boolean;
export function instanceUniformShader(source:string,dwords:number):string;
export interface GeometrySnapshot {vertexData:Float32Array;indices:Uint32Array;immutableGeometry:true;sharedGeometry?:true}
export type GeometryId=string|symbol|number;
export function registerGeometry(owner:object,id:GeometryId,revision:number,vertices:ArrayLike<number>,indices:ArrayLike<number>):GeometrySnapshot;
export function unregisterGeometry(owner:object,id:GeometryId):void;
export function registerStaticGeometry(owner:object,vertices:ArrayLike<number>,indices:ArrayLike<number>):GeometrySnapshot;
export function snapshotDrawGeometry(owner:object,vertices:ArrayLike<number>,indices:ArrayLike<number>):GeometrySnapshot;
