// Adapted from mizchi/modeling-playground motion/generation. Node-only tooling.
import { MODEL, apiInput, mediaUrl, record, requestId } from './contract.ts';
import type { GenerationInput, JobStatus, MotionResult } from './contract.ts';

export type Transport=(url:string,options:RequestInit)=>Promise<Response>;
async function boundedBody(response:Response,limit:number):Promise<Uint8Array>{
  if(Number(response.headers.get('content-length'))>limit){await response.body?.cancel();throw new Error('応答がサイズ上限を超えています');}
  if(!response.body)throw new Error('応答が空です');
  const reader=response.body.getReader(),chunks:Uint8Array[]=[];let size=0;
  try{
    while(true){const {done,value}=await reader.read();if(done)break;size+=value.length;if(size>limit){await reader.cancel();throw new Error('応答がサイズ上限を超えています');}chunks.push(value);}
  }finally{reader.releaseLock();}
  const bytes=new Uint8Array(size);let offset=0;for(const chunk of chunks){bytes.set(chunk,offset);offset+=chunk.length;}return bytes;
}
/** Node-only caller. No retries on POST: a lost response may already have incurred a charge. */
export class FalMotionClient {
  #key:string; #fetch:Transport;
  constructor(key:string,transport:Transport=fetch){
    if(!key||/\s/.test(key))throw new Error('ローカル環境変数 FAL_KEY を設定してください');this.#key=key;this.#fetch=transport;
  }
  private async call(path:string,body?:unknown):Promise<Record<string,unknown>>{
    let response:Response;
    try{response=await this.#fetch(`https://queue.fal.run/${MODEL}${path}`,{method:body===undefined?'GET':'POST',
      headers:{Authorization:`Key ${this.#key}`,'Content-Type':'application/json'},body:body===undefined?undefined:JSON.stringify(body),redirect:'error',signal:AbortSignal.timeout(30_000)});}
    catch{throw new Error('falへの通信が失敗しました。送信済みの可能性があるため、自動再送はしません。');}
    if(!response.ok){await response.body?.cancel();throw new Error(`fal API HTTP ${response.status}。認証・残高・設定・ジョブ状態を確認してください。`);}
    try{return record(JSON.parse(new TextDecoder().decode(await boundedBody(response,1024*1024))));}
    catch{throw new Error('falの応答JSONを検証できませんでした');}
  }
  async submit(input:GenerationInput):Promise<string>{return requestId((await this.call('',apiInput(input))).request_id);}
  async status(id:string):Promise<JobStatus>{
    const p=await this.call(`/requests/${requestId(id)}/status`);
    if(p.error!==undefined&&p.error!==null)throw new Error('生成ジョブが失敗しました。falの管理画面を確認してください。');
    if(p.request_id!==undefined&&p.request_id!==id)throw new Error('応答のrequest IDが一致しません');
    if(p.status!=='IN_QUEUE'&&p.status!=='IN_PROGRESS'&&p.status!=='COMPLETED')throw new Error('未対応の生成ジョブ状態です');return p.status;
  }
  async result(id:string):Promise<MotionResult>{
    const p=await this.call(`/requests/${requestId(id)}`),file=record(p.fbx_file);
    if(typeof p.seed!=='number'||!Number.isInteger(p.seed))throw new Error('生成結果のseedが不正です');return {seed:p.seed,url:mediaUrl(file.url)};
  }
  async download(url:string):Promise<Uint8Array>{
    // Never forward the API key to the CDN, including on redirects.
    let response:Response;
    try{response=await this.#fetch(mediaUrl(url),{method:'GET',redirect:'error',signal:AbortSignal.timeout(60_000)});}
    catch{throw new Error('FBXを取得できませんでした。fetchコマンドで再取得できます。');}
    if(!response.ok){await response.body?.cancel();throw new Error(`FBX取得 HTTP ${response.status}`);}
    const bytes=await boundedBody(response,32*1024*1024),header=new TextDecoder().decode(bytes.slice(0,100));
    if(bytes.length<32||!(header.startsWith('Kaydara FBX Binary  ')||/^;\s*FBX\b/.test(header)))throw new Error('取得したファイルはFBXではありません');
    return bytes;
  }
}
