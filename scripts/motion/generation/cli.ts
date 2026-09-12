// Adapted from mizchi/modeling-playground motion/generation. Node-only tooling.
import { parseArgs } from 'node:util';
import { MODEL, apiInput, validateGeneration } from './contract.ts';
import { FalMotionClient } from './fal.ts';
import { readJson, submitJob, collectJob } from './jobs.ts';

const help=`Motion generation (Node 24 / local only)
  plan   --input recipe.json                 送信内容の確認（通信なし）
  submit --input recipe.json --out run-dir --execute  課金APIへ1回送信
  fetch  --job run-dir                       状態確認・完成FBXの保存

FAL_KEY は環境変数で指定。CLI引数やJSONには含めないでください。
送信後は fetch を繰り返せます。再生成のためのsubmitは行いません。
生成中にCLIを終了してもジョブは継続します。キャンセル操作はfal管理画面で行ってください。`;
async function main(){
  const {values,positionals}=parseArgs({allowPositionals:true,strict:true,options:{input:{type:'string'},out:{type:'string'},job:{type:'string'},execute:{type:'boolean'},help:{type:'boolean'}}});
  if(values.help||!positionals.length){console.log(help);return;}
  if(positionals.length!==1)throw new Error('コマンドは1つ指定してください');
  const command=positionals[0];
  if(command==='plan'||command==='submit'){
    if(!values.input||values.job)throw new Error('--input recipe.json を指定してください');
    const input=validateGeneration(await readJson(values.input));
    if(command==='plan'){
      if(values.execute||values.out)throw new Error('planは --input のみ対応します');
      console.log(JSON.stringify({model:MODEL,input:apiInput(input),notice:'未送信。submit --executeで課金が発生します。'},null,2));return;
    }
    if(!values.execute)throw new Error('送信には --execute が必要です');
    if(!values.out)throw new Error('新規の出力ディレクトリを --out で指定してください');
    const client=new FalMotionClient(process.env.FAL_KEY??'');
    const receipt=await submitJob(input,values.out,true,client);
    console.log(`受付済み: ${receipt.requestId}\n保存先: ${values.out}\nfetch --job で結果を取得してください。`);return;
  }
  if(command==='fetch'){
    if(!values.job||values.input||values.out||values.execute)throw new Error('fetchは --job run-dir を指定してください');
    const result=await collectJob(values.job,new FalMotionClient(process.env.FAL_KEY??''));
    console.log(result.status==='SAVED'?`保存済み: ${result.file}\nオフラインのインポータでゲーム用クリップへ変換してください。`:`${result.status} — 後で同じfetchコマンドを実行してください。`);return;
  }
  throw new Error('未対応のコマンドです。--help を参照してください');
}
try{await main();}catch(error){
  // Neither provider bodies nor fetch errors are propagated by the API layer.
  const message=error instanceof Error?error.message:'処理に失敗しました';
  const key=process.env.FAL_KEY;console.error(key?message.split(key).join('[redacted]'):message);process.exitCode=1;
}
