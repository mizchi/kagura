// Gist methodology: https://gist.github.com/mizchi/9fb6627ffa370f55d482c82bc8d36fcf
// Reproducible leaf-kernel experiment; does not alter the production renderer.
import {spawnSync} from 'node:child_process';
import {mkdir,readFile,writeFile} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import {chromium} from 'playwright';
const root=fileURLToPath(new URL('./',import.meta.url));
const out=fileURLToPath(new URL('../../../../../test-results/iron-yard-simd/',import.meta.url));
await mkdir(out,{recursive:true});
function run(command,args){const r=spawnSync(command,args,{encoding:'utf8'});if(r.status!==0)throw Error(r.stderr||r.stdout);return r.stdout;}
const versions={zig:run('zig',['version']).trim(),wasmTools:run('wasm-tools',['--version']).trim(),wasmOpt:run('wasm-opt',['--version']).trim()};
const variants={};
for(const [name,cpu] of [['scalar','baseline'],['simd','baseline+simd128']]) {
  const file=`${out}${name}.wasm`;
  run('zig',['build-exe',`${root}mvp.zig`,'-target','wasm32-freestanding',`-mcpu=${cpu}`,'-O','ReleaseSmall','-fno-entry','--import-memory','--export=batch_mvp',`-femit-bin=${file}`]);
  run('wasm-tools',['validate',file]);
  const wat=run('wasm-tools',['print',file]);await writeFile(`${out}${name}.wat`,wat);
  if(name==='simd'&&!wat.includes('f64x2.mul'))throw Error('SIMD code generation missing');
  if(name==='scalar'&&/f64x2|v128/.test(wat))throw Error('Scalar control contains SIMD');
  variants[name]=[...await readFile(file)];
}
run('wasm-opt',[`${out}simd.wasm`,'-Oz','--enable-simd','-o',`${out}simd-oz.wasm`]);
run('wasm-tools',['validate',`${out}simd-oz.wasm`]);
variants['simd-oz']=[...await readFile(`${out}simd-oz.wasm`)];
const browser=await chromium.launch({channel:'chrome',headless:false});
try {
  const page=await browser.newPage();
  const results=await page.evaluate(async variants=>{
    const kernels={};
    for(const [name,bytes] of Object.entries(variants)){
      const module=await WebAssembly.compile(new Uint8Array(bytes));
      if(JSON.stringify(WebAssembly.Module.imports(module))!==JSON.stringify([{module:'env',name:'memory',kind:'memory'}]))throw Error('Unexpected imports');
      if(JSON.stringify(WebAssembly.Module.exports(module))!==JSON.stringify([{name:'batch_mvp',kind:'function'}]))throw Error('Unexpected exports');
      const memory=new WebAssembly.Memory({initial:16});
      const instance=await WebAssembly.instantiate(module,{env:{memory}});
      kernels[name]={memory,run:instance.exports.batch_mvp};
    }
    const oracle=(vp,models,out,count)=>{
      for(let i=0;i<count;i++)for(let c=0;c<4;c++)for(let r=0;r<4;r++){
        let sum=0;for(let k=0;k<4;k++)sum+=vp[k*4+r]*models[i*16+c*4+k];
        out[i*16+c*4+r]=sum;
      }
    };
    let seed=123456789;
    const random=()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return (seed/4294967296-.5)*100;};
    const reports=[];
    for(const count of [0,1,3,32,128,882]){
      const vp=Float64Array.from({length:16},random),models=Float64Array.from({length:16*count},random),expected=new Float32Array(16*count);
      // Boundary values and non-affine matrices exercise layout and rounding.
      vp[0]=-0;vp[1]=Number.MIN_VALUE;vp[2]=1e-20;vp[3]=1e20;
      oracle(vp,models,expected,count);
      const modelAddress=131072,outAddress=modelAddress+models.byteLength;
      const vpArray=[...vp],modelArrays=Array.from({length:count},(_,i)=>[...models.subarray(i*16,i*16+16)]);
      const perDrawOutputs=Array.from({length:count},()=>new Float32Array(16));
      const cases={js:()=>oracle(vp,models,expected,count),
        'js/per-draw':()=>{for(let i=0;i<count;i++)oracle(vpArray,modelArrays[i],perDrawOutputs[i],1);}};
      for(const [name,kernel] of Object.entries(kernels)){
        const vpView=new Float64Array(kernel.memory.buffer,65536,16);
        const modelView=new Float64Array(kernel.memory.buffer,modelAddress,16*count);
        const outView=new Float32Array(kernel.memory.buffer,outAddress,16*count);
        vpView.set(vp);modelView.set(models);kernel.run(65536,modelAddress,outAddress,count);
        for(let i=0;i<expected.length;i++)if(!Object.is(expected[i],outView[i]))throw Error(`${name} mismatch count=${count} offset=${i}: ${expected[i]} != ${outView[i]}`);
        const copy=new Float32Array(16*count);
        cases[`${name}/resident`]=()=>kernel.run(65536,modelAddress,outAddress,count);
        cases[`${name}/copy`]=()=>{vpView.set(vp);modelView.set(models);kernel.run(65536,modelAddress,outAddress,count);copy.set(outView);};
        if(count){
          const oneModel=new Float64Array(kernel.memory.buffer,modelAddress,16);
          const oneOut=new Float32Array(kernel.memory.buffer,outAddress,16);
          cases[`${name}/per-draw`]=()=>{
            for(let i=0;i<count;i++){
              vpView.set(vpArray);oneModel.set(modelArrays[i]);kernel.run(65536,modelAddress,outAddress,1);perDrawOutputs[i].set(oneOut);
            }
          };
        }
      }
      const samples=Object.fromEntries(Object.keys(cases).map(k=>[k,[]]));
      // Rotate variant order to reduce thermal/JIT order bias. Warm each first.
      for(const fn of Object.values(cases))for(let n=0;n<2000;n++)fn();
      for(let trial=0;trial<7;trial++){
        const entries=Object.entries(cases),iterations=Math.max(500,Math.floor(200000/Math.max(1,count)));
        for(let j=0;j<entries.length;j++){
          const [name,fn]=entries[(j+trial)%entries.length];const start=performance.now();
          for(let i=0;i<iterations;i++)fn();
          samples[name].push((performance.now()-start)*1000/iterations);
        }
      }
      reports.push({count,microseconds:Object.fromEntries(Object.entries(samples).map(([k,v])=>[k,v.sort((a,b)=>a-b)[3]]))});
    }
    return {browser:navigator.userAgent,bytes:Object.fromEntries(Object.entries(variants).map(([name,bytes])=>[name,bytes.length])),reports};
  },variants);
  results.tools=versions;
  await writeFile(`${out}results.json`,JSON.stringify(results,null,2));console.log(JSON.stringify(results,null,2));
}finally{await browser.close();}
