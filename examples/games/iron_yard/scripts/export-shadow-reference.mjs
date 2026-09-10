// Offline reference: execute Three r185's actual PCF chunk with a native comparison sampler.
import {chromium} from '@playwright/test';
import {writeFile} from 'node:fs/promises';
const browser=await chromium.launch({args:['--use-angle=swiftshader','--enable-unsafe-swiftshader']});
try{
 const page=await browser.newPage();await page.goto(`${process.argv[2]??'http://127.0.0.1:5194'}/game.html`);
 const reference=await page.evaluate(async()=>{
  const T=await import('/node_modules/.vite/deps/three.js');
  const canvas=document.createElement('canvas');canvas.width=canvas.height=33;
  const gl=canvas.getContext('webgl2',{antialias:false,preserveDrawingBuffer:true});
  const compile=(type,source)=>{const shader=gl.createShader(type);gl.shaderSource(shader,source);gl.compileShader(shader);if(!gl.getShaderParameter(shader,gl.COMPILE_STATUS))throw Error(gl.getShaderInfoLog(shader));return shader};
  const program=gl.createProgram();gl.attachShader(program,compile(gl.VERTEX_SHADER,`#version 300 es
  void main(){vec2 p=vec2((gl_VertexID<<1)&2,gl_VertexID&2);gl_Position=vec4(p*2.-1.,0.,1.);}`));
  gl.attachShader(program,compile(gl.FRAGMENT_SHADER,`#version 300 es
  precision highp float;precision highp sampler2DShadow;
  #define NUM_SPOT_LIGHT_COORDS 0
  #define NUM_SPOT_LIGHT_MAPS 0
  #define NUM_DIR_LIGHT_SHADOWS 0
  #define NUM_SPOT_LIGHT_SHADOWS 0
  #define NUM_POINT_LIGHT_SHADOWS 0
  #define USE_SHADOWMAP
  #define SHADOWMAP_TYPE_PCF
  #define PI2 6.283185307179586
  ${T.ShaderChunk.shadowmap_pars_fragment}
  uniform sampler2DShadow depthMap;uniform vec2 uv;out vec4 color;
  void main(){float s=getShadow(depthMap,vec2(8.),1.,0.,1.,vec4(uv,.5,1.));color=vec4(s,s,s,1.);}`));
  gl.linkProgram(program);if(!gl.getProgramParameter(program,gl.LINK_STATUS))throw Error(gl.getProgramInfoLog(program));gl.useProgram(program);
  const depths=Array.from({length:64},(_,i)=>i%8<4&&Math.floor(i/8)<5?.25:.75);
  const tex=gl.createTexture();gl.bindTexture(gl.TEXTURE_2D,tex);gl.texImage2D(gl.TEXTURE_2D,0,gl.DEPTH_COMPONENT24,8,8,0,gl.DEPTH_COMPONENT,gl.UNSIGNED_INT,new Uint32Array(depths.map(d=>Math.round(d*0xffffffff))));
  for(const pname of [gl.TEXTURE_MIN_FILTER,gl.TEXTURE_MAG_FILTER])gl.texParameteri(gl.TEXTURE_2D,pname,gl.LINEAR);
  for(const pname of [gl.TEXTURE_WRAP_S,gl.TEXTURE_WRAP_T])gl.texParameteri(gl.TEXTURE_2D,pname,gl.CLAMP_TO_EDGE);
  gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_COMPARE_MODE,gl.COMPARE_REF_TO_TEXTURE);gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_COMPARE_FUNC,gl.LEQUAL);
  const samples=[];
  for(const uv of [[.2,.2],[.4,.4],[.48,.5],[.51,.6],[.6,.7],[.9,.9],[-.1,.5],[1.1,.5]]){
   gl.uniform2fv(gl.getUniformLocation(program,'uv'),uv);gl.viewport(0,0,33,33);gl.drawArrays(gl.TRIANGLES,0,3);
   for(const position of [[4,3],[16,16],[27,29]]){const pixel=new Uint8Array(4);gl.readPixels(...position,1,1,gl.RGBA,gl.UNSIGNED_BYTE,pixel);samples.push({uv,position,pixel:Array.from(pixel)})}
  }
  if(gl.getError()!==gl.NO_ERROR)throw Error('Reference WebGL validation failed');
  return {revision:T.REVISION,width:8,height:8,viewportHeight:33,depths,samples};
 });
 await writeFile(new URL('../tests/shadow-reference.json',import.meta.url),JSON.stringify(reference,null,2));console.log(`Exported ${reference.samples.length} original PCF patches`);
}finally{await browser.close()}
