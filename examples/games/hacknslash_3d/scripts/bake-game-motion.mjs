import {Matrix4,Quaternion,Vector3} from 'three';
import {retargetRotationClip} from '../../../../scripts/motion/retarget.mjs';
const smooth=t=>{t=Math.max(0,Math.min(1,t));return t*t*(3-2*t);};
const round=xs=>xs.map(x=>Number(x.toFixed(7)));

// Body motion comes from HY. These prop constraints adapt its missing bow to the
// short rig: keep the bow vertical, pin the drawn string to the right hand, and
// remove the nocked arrow on the exact gameplay release phase.
export function bakeGameMotion(source,animation,profile,options){
 const clip=retargetRotationClip(source,animation,profile,options);
 if(options.name!=='bow_shot')return clip;
 const translations=[],scales=[];
 for(let f=0;f<clip.frames;f++){
  const phase=f/(clip.frames-1),weight=smooth(phase/.1)*smooth((1-phase)/.1);
  const world=[],worldQ=[];
  for(const [i,j] of profile.joints.entries()){
   const parentQ=j.parent<0?new Quaternion():worldQ[j.parent];
   if(j.name==='bow')clip.rotations[f][i]=round(new Quaternion().slerp(parentQ.clone().invert(),weight).toArray());
   const q=new Quaternion(...clip.rotations[f][i]);
   worldQ.push(parentQ.clone().multiply(q));
   const pos=new Vector3(...j.position);
   if(j.parent>=0)pos.sub(new Vector3(...profile.joints[j.parent].position));
   const m=new Matrix4().compose(pos,q,new Vector3(1,1,1));
   world.push(j.parent<0?m:world[j.parent].clone().multiply(m));
  }
  const rest=new Vector3(0,0,-.13);
  const hand=new Vector3(.275,.35,.06); // Right-hand bind tip.
  hand.sub(new Vector3(...profile.joints[6].position)).applyMatrix4(world[6]);
  const drawn=hand.applyMatrix4(world[13].clone().invert());
  const pull=phase<clip.contact?smooth(phase/.18):1-smooth((phase-clip.contact)/.045);
  const nock=rest.clone().lerp(drawn,pull*weight);
  translations.push(...round(nock.toArray()));
  clip.rotations[f][15]=round(new Quaternion().setFromUnitVectors(new Vector3(0,0,1),nock.clone().negate().normalize()).toArray());
  const visible=phase>=.08&&phase<clip.contact?1:0;
  scales.push(visible,visible,visible);
 }
 clip.extraChannels=[
  {joint:14,target:'Translation',interpolation:'Linear',values:translations},
  {joint:15,target:'Scale',interpolation:'Step',values:scales},
 ];
 return clip;
}
