import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';
const identity = () => [1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1];
function multiply(a,b) { return Array.from({length:16},(_,i) => [0,1,2,3].reduce((sum,k)=>sum+a[k*4+i%4]*b[Math.floor(i/4)*4+k],0)); }
function matrix(node) {
  if(node.matrix) return node.matrix;
  const [x,y,z,w]=node.rotation??[0,0,0,1], [sx,sy,sz]=node.scale??[1,1,1], [tx,ty,tz]=node.translation??[0,0,0];
  return [(1-2*y*y-2*z*z)*sx,(2*x*y+2*z*w)*sx,(2*x*z-2*y*w)*sx,0,
    (2*x*y-2*z*w)*sy,(1-2*x*x-2*z*z)*sy,(2*y*z+2*x*w)*sy,0,
    (2*x*z+2*y*w)*sz,(2*y*z-2*x*w)*sz,(1-2*x*x-2*y*y)*sz,0,tx,ty,tz,1];
}
function point(m,v) { return [0,1,2].map(i=>m[i]*v[0]+m[4+i]*v[1]+m[8+i]*v[2]+m[12+i]); }
function normal(m,v) {
  const a=m[0],b=m[4],c=m[8],d=m[1],e=m[5],f=m[9],g=m[2],h=m[6],i=m[10];
  const det=a*(e*i-f*h)-b*(d*i-f*g)+c*(d*h-e*g); if(Math.abs(det)<1e-15)throw Error('Singular mesh transform');
  const n=[(e*i-f*h)*v[0]+(f*g-d*i)*v[1]+(d*h-e*g)*v[2],(c*h-b*i)*v[0]+(a*i-c*g)*v[1]+(b*g-a*h)*v[2],(b*f-c*e)*v[0]+(c*d-a*f)*v[1]+(a*e-b*d)*v[2]].map(x=>x/det);
  const length=Math.hypot(...n)||1;return n.map(x=>x/length);
}
const check = (ok,message) => {if(!ok)throw Error(message);};
/** Asset-specific rigid-skin import into Kagura batches. No Three.js or new renderer. */
export function convertGLB(bytes) {
  const file = Buffer.from(bytes); check(file.readUInt32LE(0)===0x46546c67&&file.readUInt32LE(4)===2,'Expected GLB v2');
  const jsonLength=file.readUInt32LE(12), doc=JSON.parse(file.subarray(20,20+jsonLength)), data=file.subarray(28+jsonLength);
  function accessor(index) {
    const a=doc.accessors[index],v=doc.bufferViews[a.bufferView];check(!a.sparse&&v.buffer===0,'Unsupported accessor');
    const readers={5121:['readUInt8',1],5123:['readUInt16LE',2],5125:['readUInt32LE',4],5126:['readFloatLE',4]}, [read,size]=readers[a.componentType]??[];
    check(read,'Unsupported component type'); const count={SCALAR:1,VEC2:2,VEC3:3,VEC4:4,MAT4:16}[a.type], stride=v.byteStride??count*size;
    return Array.from({length:a.count},(_,i)=>Array.from({length:count},(_,j)=>data[read]((v.byteOffset??0)+(a.byteOffset??0)+i*stride+j*size)));
  }
  const parents=doc.nodes.map(()=>-1);doc.nodes.forEach((n,i)=>(n.children??[]).forEach(c=>parents[c]=i));
  const worlds=new Map();function world(i) {if(!worlds.has(i))worlds.set(i,parents[i]<0?matrix(doc.nodes[i]):multiply(world(parents[i]),matrix(doc.nodes[i])));return worlds.get(i);}
  const joints=doc.skins?.[0]?.joints??[], jointMap=new Map(joints.map((id,i)=>[id,i]));
  const bones=joints.map(id=>{const n=doc.nodes[id];check(!n.matrix,'Joint matrix requires decomposition');return {name:n.name,parent:jointMap.get(parents[id])??-1,position:n.translation??[0,0,0],rotation:n.rotation??[0,0,0,1],scale:n.scale??[1,1,1]};});
  const batches=new Map();let sourceMeshes=0;
  for(let ni=0;ni<doc.nodes.length;ni++) {
    const node=doc.nodes[ni];if(node.mesh===undefined)continue;sourceMeshes++;
    for(const primitive of doc.meshes[node.mesh].primitives) {
      check((primitive.mode??4)===4,'Expected triangles');
      const positions=accessor(primitive.attributes.POSITION),normals=accessor(primitive.attributes.NORMAL),uv=primitive.attributes.TEXCOORD_0===undefined?null:accessor(primitive.attributes.TEXCOORD_0);
      let bone=-1, transform=world(ni);
      if(node.skin!==undefined) {
        const skin=doc.skins[node.skin];check(JSON.stringify(skin.joints)===JSON.stringify(joints),'Different skeletons require separate assets');
        const indices=accessor(primitive.attributes.JOINTS_0),weights=accessor(primitive.attributes.WEIGHTS_0);
        for(let i=0;i<positions.length;i++) {
          const active=weights[i].map((w,j)=>[w,indices[i][j]]).filter(([w])=>w!==0);
          check(active.length===1&&active[0][0]===1,'Expected rigid one-bone skin');
          if(bone<0)bone=active[0][1];check(bone===active[0][1],'Expected one rigid joint per primitive');
        }
        transform=skin.inverseBindMatrices===undefined?identity():accessor(skin.inverseBindMatrices)[bone];
      }
      const source=doc.materials?.[primitive.material]??{},pbr=source.pbrMetallicRoughness??{};
      const material={color:pbr.baseColorFactor??[1,1,1,1],metallic:pbr.metallicFactor??1,roughness:pbr.roughnessFactor??1,emissive:source.emissiveFactor??[0,0,0],texture:doc.textures?.[pbr.baseColorTexture?.index]?.source??-1,alpha:source.alphaMode??'OPAQUE',unlit:!!source.extensions?.KHR_materials_unlit,doubleSided:source.doubleSided??false};
      const key=JSON.stringify([bone,material]);if(!batches.has(key))batches.set(key,{bone,material,vertices:[],indices:[]});const batch=batches.get(key),base=batch.vertices.length/8;
      for(let i=0;i<positions.length;i++)batch.vertices.push(...point(transform,positions[i]),...normal(transform,normals[i]),...(uv?.[i]??[0,0]));
      const indices=primitive.indices===undefined?positions.map((_,i)=>i):accessor(primitive.indices).flat();batch.indices.push(...indices.map(i=>i+base));
      if(material.doubleSided)for(let i=0;i<indices.length;i+=3)batch.indices.push(base+indices[i+2],base+indices[i+1],base+indices[i]);
    }
  }
  const clips=(doc.animations??[]).map(a=>({name:a.name,channels:a.channels.filter(c=>jointMap.has(c.target.node)).map(c=>{const s=a.samplers[c.sampler];check(['LINEAR','STEP'].includes(s.interpolation??'LINEAR'),'Unsupported animation interpolation');return {bone:jointMap.get(c.target.node),path:c.target.path,interpolation:s.interpolation??'LINEAR',times:accessor(s.input).flat(),values:accessor(s.output).flat()};})}));
  for(const clip of clips)clip.duration=Math.max(...clip.channels.flatMap(c=>c.times));
  const images=(doc.images??[]).map(image=>{check(image.bufferView!==undefined,'Expected embedded image');const view=doc.bufferViews[image.bufferView];return {mime:image.mimeType,data:data.subarray(view.byteOffset??0,(view.byteOffset??0)+view.byteLength).toString('base64')};});
  for(const texture of doc.textures??[]) {
    const sampler=doc.samplers?.[texture.sampler]??{magFilter:9729,minFilter:9987,wrapS:10497,wrapT:10497};
    check([9728,9729].includes(sampler.minFilter??9987),'This asset importer requires non-mipmapped textures');
    const image=images[texture.source];
    check(!image.sampler||JSON.stringify(image.sampler)===JSON.stringify(sampler),'Conflicting samplers for one image');
    image.sampler=sampler;
  }
  return {version:1,batches:[...batches.values()],bones,clips,images,stats:{sourceMeshes:doc.meshes.length,meshInstances:sourceMeshes}};
}
if(process.argv[1]&&resolve(process.argv[1])===fileURLToPath(import.meta.url)) {
  const root=new URL('../',import.meta.url);await mkdir(new URL('assets/generated/',root),{recursive:true});
  for(const name of ['strix','bastion']) {
    const asset=convertGLB(await readFile(new URL(`assets/source/${name}.glb`,root)));
    await writeFile(new URL(`assets/generated/${name}.json`,root),JSON.stringify(asset,(_,value)=>typeof value==='number'?Number(value.toPrecision(9)):value));
    console.log(`${name}: ${asset.stats.sourceMeshes} meshes -> ${asset.batches.length} batches`);
  }
}
