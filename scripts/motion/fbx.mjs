import {FBXLoader} from 'three/addons/loaders/FBXLoader.js';
import {LoadingManager,Texture,Matrix4,Group,Bone,AnimationClip,QuaternionKeyframeTrack,VectorKeyframeTrack} from 'three';

/** Parse only local FBX data. Meshes/textures are discarded by the motion importer;
 * never resolve embedded/external texture paths or make a network request. */
export function parseMotionFbx(bytes) {
 const previous=globalThis.window;
 const manager=new LoadingManager();
 manager.addHandler(/.*/,{setPath(){return this;},load(){return new Texture();}});
 globalThis.window={URL:{createObjectURL(){return 'embedded://unused';}}};
 try{return new FBXLoader(manager).parse(bytes.buffer.slice(bytes.byteOffset,bytes.byteOffset+bytes.byteLength),'');}
 finally{if(previous===undefined)delete globalThis.window;else globalThis.window=previous;}
}

// Retain only authored skeleton transforms and animation tracks. The provider's
// preview human mesh/textures are large and are not part of the game's assets.
export function serializeMotionSource(root) {
 root.updateMatrixWorld(true);
 const bones=new Map();root.traverse(o=>{if(o.isBone&&!bones.has(o.name))bones.set(o.name,o);});
 return {version:1,bones:[...bones.values()].map(b=>{
  if(!bones.has(b.parent?.name)&&!b.parent.matrixWorld.equals(new Matrix4()))throw Error('Unsupported FBX armature transform');
  return {name:b.name,parent:bones.has(b.parent?.name)?b.parent.name:null,position:b.position.toArray(),quaternion:b.quaternion.toArray(),scale:b.scale.toArray()};
 }),clips:root.animations.map(c=>({name:c.name,duration:c.duration,tracks:c.tracks.map(t=>({name:t.name,times:Array.from(t.times),values:Array.from(t.values),type:t.ValueTypeName}))}))};
}

export function restoreMotionSource(data) {
 if(data.version!==1||!Array.isArray(data.bones)||!Array.isArray(data.clips))throw Error('Invalid motion source');
 const root=new Group(),bones=new Map();
 for(const spec of data.bones){
  if(bones.has(spec.name)||[...spec.position,...spec.quaternion,...spec.scale].some(v=>!Number.isFinite(v)))throw Error('Invalid source bone');
  const bone=new Bone();bone.name=spec.name;bone.position.fromArray(spec.position);bone.quaternion.fromArray(spec.quaternion);bone.scale.fromArray(spec.scale);bones.set(bone.name,bone);
 }
 for(const spec of data.bones){const parent=spec.parent===null?root:bones.get(spec.parent);if(!parent)throw Error('Missing source parent');parent.add(bones.get(spec.name));}
 root.animations=data.clips.map(c=>new AnimationClip(c.name,c.duration,c.tracks.map(t=>{
  if(t.type!=='quaternion'&&t.type!=='vector')throw Error('Unsupported source track');
  return new (t.type==='quaternion'?QuaternionKeyframeTrack:VectorKeyframeTrack)(t.name,t.times,t.values);
 })));
 return root;
}
