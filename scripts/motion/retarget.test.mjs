import {test} from 'node:test';
import assert from 'node:assert/strict';
import {Bone,Group,Quaternion,Vector3,AnimationClip,QuaternionKeyframeTrack} from 'three';
import {retargetRotationClip,emitMoonBitClip} from './retarget.mjs';

test('retarget composes unmapped ancestors and converts T pose to a short downward arm',()=>{
 const root=new Group(),chest=new Bone(),collar=new Bone(),arm=new Bone(),elbow=new Bone();
 chest.name='chest';collar.name='collar';arm.name='arm';elbow.name='elbow';
 root.add(chest);chest.add(collar);collar.add(arm);arm.add(elbow);elbow.position.set(1,0,0);
 const q=new Quaternion().setFromAxisAngle(new Vector3(0,1,0),-Math.PI/2);
 const clip=new AnimationClip('thrust',1,[new QuaternionKeyframeTrack('collar.quaternion',[0,1],[0,0,0,1,...q.toArray()])]);
 const profile={joints:[{name:'root',parent:-1,position:[0,0,0]}, {name:'arm',parent:0,position:[.2,.6,0],source:'arm',sourceTip:'elbow',tip:[.2,.3,0]}]};
 const out=retargetRotationClip(root,clip,profile,{name:'thrust',frames:3,duration:1,start:0,impact:.5,end:1,contact:.5,blend:0});
 const rotation=out.rotations[2][1];
 const direction=new Vector3(0,-1,0).applyQuaternion(new Quaternion(...rotation));
 assert.ok(direction.distanceTo(new Vector3(0,0,1))<1e-5);
 assert.deepEqual(arm.quaternion.toArray(),[0,0,0,1],'source state restored');
 assert.ok(emitMoonBitClip(out).includes('build_thrust_clip'));
});

test('retarget rejects missing bones and nonfinite tracks instead of producing a broken runtime clip',()=>{
 const root=new Group();const bone=new Bone();bone.name='arm';root.add(bone);
 const profile={joints:[{name:'root',parent:-1,position:[0,0,0],source:'missing'}]};
 const clip=new AnimationClip('bad',1,[]);
 const options={name:'bad',frames:3,duration:1,start:0,impact:.5,end:1,contact:.5,blend:0};
 assert.throws(()=>retargetRotationClip(root,clip,profile,options),/bone/);
 clip.tracks.push(new QuaternionKeyframeTrack('arm.quaternion',[0,1],[NaN,0,0,1,0,0,0,1]));
 assert.throws(()=>retargetRotationClip(root,clip,{joints:[{name:'arm',parent:-1,position:[0,0,0],source:'arm'}]},options),/track/);
});

test('prop channels preserve step visibility and reject invalid skeletal targets',()=>{
 const clip={name:'bow',frames:3,duration:1,joints:['root','arrow'],rotations:Array.from({length:3},()=>[[0,0,0,1],[0,0,0,1]]),rootY:[0,0,0],
  extraChannels:[{joint:1,target:'Scale',interpolation:'Step',values:[1,1,1,0,0,0,0,0,0]}]};
 assert.match(emitMoonBitClip(clip),/target: @animation3d.Scale, interpolation: @animation3d.Step/);
 for(const invalid of [{joint:2},{values:[NaN,0,0,0,0,0,0,0,0]},{values:[]},{target:'Rotation'},{interpolation:'Unknown'}]){
  assert.throws(()=>emitMoonBitClip({...clip,extraChannels:[{...clip.extraChannels[0],...invalid}]}),/Invalid extra animation channel/);
 }
});
