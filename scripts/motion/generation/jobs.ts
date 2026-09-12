// Adapted from mizchi/modeling-playground motion/generation. Node-only tooling.
import { mkdir, readFile, writeFile, link, unlink, stat } from 'node:fs/promises';
import { dirname, join, resolve } from 'node:path';
import { createHash, randomUUID } from 'node:crypto';
import { MODEL, validateGeneration, validateReceipt, record } from './contract.ts';
import type { GenerationInput, JobReceipt, JobStatus, MotionResult } from './contract.ts';
interface SubmitClient {submit(input:GenerationInput):Promise<string>}
interface CollectClient {status(id:string):Promise<JobStatus>;result(id:string):Promise<MotionResult>;download(url:string):Promise<Uint8Array>}
function code(error:unknown):string|undefined{return typeof error==='object'&&error!==null&&'code'in error?String(error.code):undefined;}
export async function readJson(file:string):Promise<unknown>{
  if((await stat(file)).size>64*1024)throw new Error('設定JSONは64KB以下です');return JSON.parse(await readFile(file,'utf8'));
}
/** Publish complete files atomically; never truncate an existing user's output. */
async function publish(file:string,data:string|Uint8Array):Promise<void>{
  const temp=join(dirname(file),`.${randomUUID()}.tmp`);
  await writeFile(temp,data,{flag:'wx',mode:0o600});
  try{await link(temp,file);}finally{await unlink(temp);}
}
const digest=(bytes:Uint8Array)=>createHash('sha256').update(bytes).digest('hex');
export async function submitJob(input:GenerationInput,output:string,execute:boolean,client:SubmitClient):Promise<JobReceipt>{
  if(!execute)throw new Error('課金を伴う送信には --execute が必要です。先に plan で確認してください。');
  const validated=validateGeneration(input),directory=resolve(output);
  await mkdir(dirname(directory),{recursive:true});
  // Existing directory also protects an ambiguous/failed previous submit from being repeated.
  await mkdir(directory,{mode:0o700});
  await publish(join(directory,'request.json'),JSON.stringify(validated,null,2));
  let id:string;
  try{id=await client.submit(validated);}catch{throw new Error('送信結果を確認できません。request.jsonを保持しました。再送せずfal管理画面で受付状況を確認してください。');}
  const receipt=validateReceipt({version:1,model:MODEL,requestId:id,input:validated});
  try{await publish(join(directory,'job.json'),JSON.stringify(receipt,null,2));}
  catch{throw new Error(`受付済みですがjob.jsonを保存できません。request ID: ${receipt.requestId}。再送しないでください。`);}
  return receipt;
}
export async function collectJob(output:string,client:CollectClient):Promise<{status:JobStatus|'SAVED';file?:string}>{
  const directory=resolve(output),receipt=validateReceipt(await readJson(join(directory,'job.json'))),file=join(directory,'motion.fbx');
  try{
    const saved=record(await readJson(join(directory,'result.json'))),bytes=await readFile(file);
    if(saved.requestId!==receipt.requestId||saved.sha256!==digest(bytes))throw new Error('保存済みFBXの検証に失敗しました。上書きはしません。');
    return {status:'SAVED',file};
  }catch(e){if(code(e)!=='ENOENT')throw e;}
  const status=await client.status(receipt.requestId);if(status!=='COMPLETED')return {status};
  const result=await client.result(receipt.requestId),bytes=await client.download(result.url),sha256=digest(bytes);
  try{await publish(file,bytes);}catch(e){
    if(code(e)!=='EEXIST')throw e;
    if(digest(await readFile(file))!==sha256)throw new Error('異なるmotion.fbxが存在します。上書きはしません。');
  }
  const saved={version:1,requestId:receipt.requestId,seed:result.seed,sha256,bytes:bytes.length};
  try{await publish(join(directory,'result.json'),JSON.stringify(saved,null,2));}catch(e){
    if(code(e)!=='EEXIST')throw e;
    const existing=record(await readJson(join(directory,'result.json')));
    if(existing.requestId!==receipt.requestId||existing.sha256!==sha256)throw new Error('異なるresult.jsonが存在します');
  }
  return {status:'SAVED',file};
}
