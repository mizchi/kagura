// Offline only. Export the original Three.js PMREM and rendered reference patches.
import {chromium} from '@playwright/test';
import {writeFile} from 'node:fs/promises';
const browser=await chromium.launch({args:['--use-angle=swiftshader','--enable-unsafe-swiftshader']});
try {
 const page=await browser.newPage();
 await page.goto(`${process.argv[2] ?? 'http://127.0.0.1:5194'}/game.html`);
 const data=await page.evaluate(async()=>{
  const T=await import('/node_modules/.vite/deps/three.js');
  const {RoomEnvironment}=await import('/node_modules/three/examples/jsm/environments/RoomEnvironment.js');
  // Sample the exact center of an odd-sized viewport; a 1px raster is unstable at grazing angles.
  const renderer=new T.WebGLRenderer({antialias:false,preserveDrawingBuffer:true});renderer.setSize(33,33);
  renderer.toneMapping=T.ACESFilmicToneMapping;renderer.outputColorSpace=T.SRGBColorSpace;
  const generator=new T.PMREMGenerator(renderer),room=new RoomEnvironment(),env=generator.fromScene(room,.04);
  const half=new Uint16Array(env.width*env.height*4);renderer.readRenderTargetPixels(env,0,0,env.width,env.height,half);
  const samples=[];
  const scenarios=[
   {name:'floor',hex:0x566269,metallic:0,roughness:.95},
   {name:'outer-floor',hex:0x46555c,metallic:0,roughness:.95},
   {name:'road-yellow',hex:0xbfa064,metallic:.15,roughness:.78},
   {name:'ring-yellow',hex:0xd5b570,metallic:0,roughness:1},
   {name:'blue-metal',hex:0x5675b1,metallic:.8,roughness:.35},
   {name:'rough-metal',hex:0x818181,metallic:1,roughness:.9},
   {name:'smooth-metal',hex:0xc8ced4,metallic:1,roughness:.0525},
   {name:'red',hex:0xd12c18,metallic:0,roughness:.4},
   {name:'white',hex:0xffffff,metallic:0,roughness:.8},
  ];
  for(const spec of scenarios)for(const angle of [.2,.8])for(const distance of [10,110]){
   const scene=new T.Scene();scene.environment=env.texture;scene.environmentIntensity=.55;
   scene.fog=new T.Fog(0xa4b3bd,65,180);
   scene.add(new T.HemisphereLight(0xe1edff,0x465154,1.3));
   const sun=new T.DirectionalLight(0xfff0d7,3.2);sun.position.set(-35,65,-25);scene.add(sun);
   const color=new T.Color(spec.hex);
   const material=new T.MeshStandardMaterial({color,metalness:spec.metallic,roughness:spec.roughness});
   // Keep vertices away from the near plane so clipping does not perturb view interpolation.
   const mesh=new T.Mesh(new T.PlaneGeometry(distance*1.2,distance*1.2),material);mesh.rotation.x=-Math.PI/2;scene.add(mesh);
   const camera=new T.PerspectiveCamera(58,1,.15,260);camera.position.set(distance*Math.sqrt(1-angle*angle),distance*angle,0);camera.lookAt(0,0,0);
   renderer.setRenderTarget(null);renderer.render(scene,camera);
   const pixel=new Uint8Array(4);renderer.getContext().readPixels(16,16,1,1,renderer.getContext().RGBA,renderer.getContext().UNSIGNED_BYTE,pixel);
   samples.push({...spec,albedo:color.toArray(),normal:[0,1,0],view:camera.position.toArray().map(v=>v/distance),distance,pixel:Array.from(pixel)});
   mesh.geometry.dispose();material.dispose();
  }
  const toneSamples=[];
  for(const rgb of [[.18,.18,.18],[1,1,1],[4,1,.1],[.05,.2,.8],[16,8,1]]) {
   const scene=new T.Scene(),camera=new T.Camera();
   const material=new T.MeshBasicMaterial({color:new T.Color().fromArray(rgb)});
   const mesh=new T.Mesh(new T.PlaneGeometry(2,2),material);scene.add(mesh);renderer.render(scene,camera);
   const pixel=new Uint8Array(4);renderer.getContext().readPixels(16,16,1,1,renderer.getContext().RGBA,renderer.getContext().UNSIGNED_BYTE,pixel);
   toneSamples.push({rgb,pixel:Array.from(pixel)});mesh.geometry.dispose();material.dispose();
  }
  return {width:env.width,height:env.height,half:Array.from(half),samples,toneSamples,revision:T.REVISION};
 });
 const {half,...metadata}=data;
 await writeFile(new URL('../assets/source/room-pmrem.rgba16f',import.meta.url),new Uint8Array(new Uint16Array(half).buffer));
 await writeFile(new URL('../assets/source/room-pmrem.json',import.meta.url),JSON.stringify({source:`Three.js ${data.revision} RoomEnvironment / PMREMGenerator blur .04`,width:data.width,height:data.height,format:'rgba16float',layout:'cube-uv',byteOrder:'little-endian'},null,2));
 await writeFile(new URL('../tests/render-reference.json',import.meta.url),JSON.stringify(metadata,null,2));
 console.log(`PMREM ${data.width}x${data.height}, ${data.samples.length} PBR patches, ${data.toneSamples.length} tone patches`);
}finally{await browser.close();}
