// Adapted from mizchi/modeling-playground motion/generation. Node-only tooling.
export const MODEL='fal-ai/hunyuan-motion';
export interface GenerationInput {version:1;prompt:string;duration:number;seed:number;guidanceScale:number}
export interface JobReceipt {version:1;model:typeof MODEL;requestId:string;input:GenerationInput}
export type JobStatus='IN_QUEUE'|'IN_PROGRESS'|'COMPLETED';
export interface MotionResult {seed:number;url:string}
export function record(value:unknown):Record<string,unknown>{
  if(!value||typeof value!=='object'||Array.isArray(value))throw new Error('JSONオブジェクトが必要です');
  return value as Record<string,unknown>;
}
export function validateGeneration(value:unknown):GenerationInput{
  const p=record(value),fields=['version','prompt','duration','seed','guidanceScale'];
  if(Object.keys(p).length!==fields.length||fields.some(k=>!Object.hasOwn(p,k))||p.version!==1)throw new Error('生成設定のversion / フィールドが不正です');
  if(typeof p.prompt!=='string'||!p.prompt.trim()||p.prompt.length>2000)throw new Error('promptは1〜2000文字です');
  const bounded=(v:unknown,min:number,max:number):number=>{
    if(typeof v!=='number'||!Number.isFinite(v)||v<min||v>max)throw new Error(`数値の範囲が不正です (${min}〜${max})`);return v;
  };
  const seed=bounded(p.seed,0,2147483647);if(!Number.isInteger(seed))throw new Error('seedは整数です');
  return {version:1,prompt:p.prompt.trim(),duration:bounded(p.duration,.5,12),seed,guidanceScale:bounded(p.guidanceScale,0,20)};
}
export function apiInput(input:GenerationInput){
  const p=validateGeneration(input);return {prompt:p.prompt,duration:p.duration,seed:p.seed,guidance_scale:p.guidanceScale,output_format:'fbx' as const};
}
export function requestId(value:unknown):string{
  if(typeof value!=='string'||! /^[A-Za-z0-9_-]{1,128}$/.test(value))throw new Error('request IDが不正です');return value;
}
export function validateReceipt(value:unknown):JobReceipt{
  const p=record(value);if(p.version!==1||p.model!==MODEL)throw new Error('未対応のジョブです');
  return {version:1,model:MODEL,requestId:requestId(p.requestId),input:validateGeneration(p.input)};
}
export function mediaUrl(value:unknown):string{
  if(typeof value!=='string')throw new Error('FBXのURLがありません');
  let url:URL;try{url=new URL(value);}catch{throw new Error('FBXのURLが不正です');}
  if(url.protocol!=='https:'||url.username||url.password||url.port||url.hash||!(url.hostname==='fal.media'||url.hostname.endsWith('.fal.media')))throw new Error('FBXの取得先はHTTPSのfal.mediaに限定しています');
  return url.href;
}
