// Offline rotation retargeting, adapted from modeling-playground's Hunyuan importer.
// Collapsed spine/clavicle chains are composed in world space. No runtime Three.js.
import {Quaternion,Vector3,Matrix4,InterpolateLinear} from 'three';

const point=o=>o.getWorldPosition(new Vector3());
const rotation=o=>o.getWorldQuaternion(new Quaternion()).normalize();
const smooth=x=>{x=Math.max(0,Math.min(1,x));return x*x*(3-2*x);};
const rounded=n=>Number(n.toFixed(7));
function valueAt(track,time) {
 const n=track.getValueSize(),ts=track.times;let a=0,b=ts.length-1;
 if(time<=ts[0])return Array.from(track.values.slice(0,n));
 if(time>=ts[b])return Array.from(track.values.slice(b*n,(b+1)*n));
 while(a+1<b){const m=(a+b)>>1;if(ts[m]<=time)a=m;else b=m;}
 const t=(time-ts[a])/(ts[b]-ts[a]),first=Array.from(track.values.slice(a*n,(a+1)*n)),last=Array.from(track.values.slice(b*n,(b+1)*n));
 return n===4?new Quaternion(...first).slerp(new Quaternion(...last),t).normalize().toArray():first.map((v,i)=>v+(last[i]-v)*t);
}

/** Profile: parent-first joints with absolute bind positions, optional source/sourceTip
 * and absolute target tip. Rotations are local XYZW; translation is in-place Y only.
 * mirrorX converts HY's left-positive-X convention to Kagura's right-positive-X rig. */
export function retargetRotationClip(source,clip,profile,options) {
 const {name,frames,duration,start,impact,end,contact,blend=.1,mirrorX=false,aimBone,aimOrigin}=options;
 if(!/^[a-z][a-z0-9_]*$/.test(name)||!Number.isInteger(frames)||frames<3||frames>601||
   ![duration,start,impact,end,contact,blend].every(Number.isFinite)||duration<=0||start<0||start>=impact||impact>=end||end>clip.duration+1e-5||contact<=0||contact>=1||blend<0||blend>=.5)throw Error('Invalid clip options');
 const bones=new Map(),tracks=new Map();
 source.traverse(o=>{if(!o.isBone)return;if(bones.has(o.name)){
  if(o.parent?.name!==o.name||o.position.length()>1e-7||o.quaternion.angleTo(new Quaternion())>1e-7)throw Error(`Duplicate bone: ${o.name}`);
 }else bones.set(o.name,o);});
 for(const t of clip.tracks){
  const match=/^([A-Za-z0-9_]+)\.(quaternion|position)$/.exec(t.name);
  if(!match||!bones.has(match[1])||tracks.has(t.name)||t.getInterpolation()!==InterpolateLinear||!t.times.length||
    t.getValueSize()!==(match[2]==='quaternion'?4:3)||!t.values.every(Number.isFinite)||
    !t.times.every((v,i)=>Number.isFinite(v)&&v>=0&&(!i||v>=t.times[i-1])))throw Error(`Invalid track: ${t.name}`);
  if(match[2]==='quaternion')for(let i=0;i<t.values.length;i+=4)if(Math.abs(Math.hypot(...t.values.slice(i,i+4))-1)>1e-3)throw Error(`Invalid rotation track: ${t.name}`);
  tracks.set(t.name,{track:t,bone:bones.get(match[1]),property:match[2]});
 }
 for(const [i,j] of profile.joints.entries()){
  if(!Number.isInteger(j.parent)||j.parent>=i||j.parent< -1||j.position.length!==3||!j.position.every(Number.isFinite))throw Error('Invalid target hierarchy');
  for(const n of [j.source,j.sourceTip].filter(Boolean))if(!bones.has(n))throw Error(`Missing bone: ${n}`);
 }
 const original=new Map([...bones.values()].map(b=>[b,{p:b.position.clone(),q:b.quaternion.clone()}]));
 const vector=v=>{v=v.clone();if(mirrorX)v.x=-v.x;return v;};
 const reflect=q=>mirrorX?new Quaternion(q.x,-q.y,-q.z,q.w):q.clone();
 source.updateMatrixWorld(true);
 const rest=new Map([...bones].map(([n,b])=>[n,{p:vector(point(b)),q:reflect(rotation(b))}]));
 const alignment=profile.joints.map(j=>j.sourceTip?new Quaternion().setFromUnitVectors(
  new Vector3(...j.tip).sub(new Vector3(...j.position)).normalize(),
  rest.get(j.sourceTip).p.clone().sub(rest.get(j.source).p).normalize()):new Quaternion());
 const apply=time=>{for(const {track,bone,property} of tracks.values())bone[property].fromArray(valueAt(track,time));source.updateMatrixWorld(true);};
 try {
  let heading=new Quaternion();
  if(aimBone){
   if(!bones.has(aimBone)||!bones.has(aimOrigin))throw Error('Missing aim bone');
   apply(impact);const forward=vector(point(bones.get(aimBone)).sub(point(bones.get(aimOrigin))));
   heading.setFromAxisAngle(new Vector3(0,1,0),-Math.atan2(forward.x,forward.z));
  }
  const rotations=[],rootY=[],tips=[];
  for(let f=0;f<frames;f++){
   const phase=f/(frames-1),time=phase<=contact?start+(impact-start)*phase/contact:impact+(end-impact)*(phase-contact)/(1-contact);
   const weight=blend===0?1:smooth(phase/blend)*smooth((1-phase)/blend);
   apply(time);
   const world=[],worldQ=[],local=[];
   for(const [i,j] of profile.joints.entries()){
    const parentQ=j.parent<0?new Quaternion():worldQ[j.parent];
    let desired=j.source?heading.clone().multiply(reflect(rotation(bones.get(j.source)))).multiply(rest.get(j.source).q.clone().invert()).multiply(alignment[i]):parentQ.clone();
    if(j.aimWeapon){
     // A weapon socket holds the spear upright during anticipation, then aims it
     // forward on contact independently of the source actor's missing prop.
     const aim=smooth(phase/contact)*smooth((1-phase)/(1-contact));
     desired=new Quaternion().setFromAxisAngle(new Vector3(1,0,0),Math.PI/2*aim);
    }
    const q=parentQ.clone().invert().multiply(desired).normalize();
    q.slerp(new Quaternion(),1-weight).normalize();
    local.push(q.toArray().map(rounded));worldQ.push(parentQ.clone().multiply(q));
    const pos=new Vector3(...j.position);if(j.parent>=0)pos.sub(new Vector3(...profile.joints[j.parent].position));
    const matrix=new Matrix4().compose(pos,q,new Vector3(1,1,1));
    world.push(j.parent<0?matrix:world[j.parent].clone().multiply(matrix));
   }
   // In-place clips keep X/Z in simulation. Keep the lowest authored sole on ground.
   const sole=profile.soles?.map(s=>new Vector3(...s.position).sub(new Vector3(...profile.joints[s.joint].position)).applyMatrix4(world[s.joint]).y);
   const y=sole?.length?-Math.min(...sole):0;
   rotations.push(local);rootY.push(rounded(y));
   tips.push(profile.joints.map((j,i)=>j.tip?new Vector3(...j.tip).sub(new Vector3(...j.position)).applyMatrix4(world[i]).add(new Vector3(0,y,0)).toArray().map(rounded):null));
  }
  return {version:1,name,duration,frames,contact,joints:profile.joints.map(j=>j.name),rotations,rootY,tips};
 } finally {for(const [b,p] of original){b.position.copy(p.p);b.quaternion.copy(p.q);}source.updateMatrixWorld(true);}
}

export function emitMoonBitClip(clip) {
 const num=n=>{const s=String(rounded(n));return /[.e]/i.test(s)?s:s+'.0';};
 const array=xs=>'['+xs.map(num).join(', ')+']';
 const times=Array.from({length:clip.frames},(_,i)=>i/(clip.frames-1)*clip.duration);
 const channels=clip.joints.map((_,i)=>`    { node_index: ${i}, target: @animation3d.Rotation, interpolation: @animation3d.Linear, times, values: ${array(clip.rotations.flatMap(frame=>frame[i]))}, },`);
 for(const channel of clip.extraChannels??[]){
  if(!Number.isInteger(channel.joint)||channel.joint<0||channel.joint>=clip.joints.length||
    !['Translation','Scale'].includes(channel.target)||!['Linear','Step'].includes(channel.interpolation)||
    channel.values.length!==clip.frames*3||!channel.values.every(Number.isFinite))throw Error('Invalid extra animation channel');
  channels.push(`    { node_index: ${channel.joint}, target: @animation3d.${channel.target}, interpolation: @animation3d.${channel.interpolation}, times, values: ${array(channel.values)}, },`);
 }
 channels.push(`    { node_index: 0, target: @animation3d.Translation, interpolation: @animation3d.Linear, times, values: ${array(clip.rootY.flatMap(y=>[0,y,0]))}, },`);
 return `///|\nfn build_${clip.name}_clip() -> @animation3d.AnimationClip {\n  let times = ${array(times)}\n  let channels : Array[@animation3d.AnimChannel] = [\n${channels.join('\n')}\n  ]\n  { name: "hy_${clip.name}", channels, duration: ${num(clip.duration)}, }\n}\n`;
}
