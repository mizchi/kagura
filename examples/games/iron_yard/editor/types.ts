// Ported from mizchi/modeling-playground game.
export type Vec3 = [number, number, number];
export interface PilotInput { forward:number; strafe:number; boost:boolean; jump:boolean; yaw:number; pitch:number }
export interface PilotState { position:Vec3; velocity:Vec3; yaw:number; pitch:number; gaitTime:number; boostWeight:number;
  grounded:boolean;jumpHeldTime:number;jumpWasDown:boolean }
export interface Solid { id:string; kind:'warehouse'|'container'|'barrier'|'tower'|'wall'; center:Vec3; size:Vec3; color:string }
export interface Target { id:string; position:Vec3; yaw:number }
export interface StageDefinition {
  bounds:{minX:number;maxX:number;minZ:number;maxZ:number}; spawn:Vec3;
  solids:readonly Solid[]; targets:readonly Target[];
}
