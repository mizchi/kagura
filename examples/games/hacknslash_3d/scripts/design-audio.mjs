// Original ASHEN HUNT effects: filtered air, material transients and resonant
// bodies. No recorded samples, oscillating UI beeps or runtime dependencies.
import {mkdirSync, writeFileSync} from 'node:fs';
import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {resolve} from 'node:path';
import {createHash} from 'node:crypto';

const RATE=44100;
const TAU=Math.PI*2;
const smooth=x=>{x=Math.max(0,Math.min(1,x));return x*x*(3-2*x);};
function random(seed){
  let s=seed>>>0;
  return ()=>{s^=s<<13;s^=s>>>17;s^=s<<5;return (s>>>0)/4294967296;};
}

class Sound {
  constructor(seconds,seed){this.data=new Float64Array(Math.round(seconds*RATE));this.random=random(seed);}
  // Band-limited noise with a moving low-pass: air, cloth, combustion, fractures.
  air(start,length,{gain=.5,low=80,high=2200,endHigh=high,attack=.006,decay=.1,swell=false}={}){
    const first=Math.round(start*RATE),count=Math.round(length*RATE);
    let lp=0,hp=0;
    const hpAlpha=1-Math.exp(-TAU*low/RATE);
    for(let i=0;i<count && first+i<this.data.length;i++){
      const t=i/RATE,x=i/count;
      const alpha=1-Math.exp(-TAU*(high+(endHigh-high)*x)/RATE);
      lp+=alpha*((this.random()*2-1)-lp);
      hp+=hpAlpha*(lp-hp);
      const envelope=swell ? Math.sin(Math.PI*x)**2 : smooth(t/attack)*Math.exp(-t/decay);
      this.data[first+i]+=(lp-hp)*gain*envelope*smooth((length-t)/.025);
    }
    return this;
  }
  // Inharmonic damped modes make a struck material, not a sustained note.
  modes(start,length,frequency,partials,{gain=.2,decay=.1,attack=.003,bend=0}={}){
    const first=Math.round(start*RATE),count=Math.round(length*RATE);
    for(const [ratio,weight,damping=1] of partials){
      let phase=this.random()*TAU;
      for(let i=0;i<count && first+i<this.data.length;i++){
        const t=i/RATE;
        phase+=TAU*frequency*ratio*(1+bend*Math.exp(-t/.055))/RATE;
        const envelope=smooth(t/attack)*Math.exp(-t/(decay*damping))*smooth((length-t)/.04);
        this.data[first+i]+=Math.sin(phase)*weight*gain*envelope;
      }
    }
    return this;
  }
  crackle(start,length,count,gain,high=4600){
    for(let i=0;i<count;i++){
      const t=length*this.random();
      this.air(start+t,.014+this.random()*.022,{gain:gain*(.3+this.random()*.7)*(1-t/length),low:650,high,attack:.001,decay:.005});
    }
    return this;
  }
  finish({peak=.58,room=.09}={}){
    const mono=this.data,stereo=new Float32Array(mono.length*2);
    const taps=[[.023,.34],[.041,.24],[.073,.18],[.113,.12],[.167,.08]];
    let dc=0,low=0,max=0;
    for(let i=0;i<mono.length;i++){
      dc+=(1-Math.exp(-TAU*28/RATE))*(mono[i]-dc);
      low+=(1-Math.exp(-TAU*7200/RATE))*(mono[i]-dc-low);
      mono[i]=Math.tanh(low*1.35);
    }
    for(let i=0;i<mono.length;i++){
      for(let channel=0;channel<2;channel++){
        let value=mono[i];
        for(const [delay,weight] of taps){
          const index=i-Math.round((delay+channel*.0037)*RATE);
          if(index>=0)value+=mono[index]*room*weight;
        }
        const t=i/RATE,remaining=(mono.length-1-i)/RATE;
        // Finish before the file boundary, even after the diffuse reflections.
        value*=smooth(t/.004)*smooth((remaining-.006)/.065);
        stereo[i*2+channel]=value;
        max=Math.max(max,Math.abs(value));
      }
    }
    for(let i=0;i<stereo.length;i++)stereo[i]*=peak/Math.max(max,.00001);
    return stereo;
  }
}

export function createSoundBank(){
  const bank=[];
  const add=(id,label,description,sound,master)=>bank.push({id,label,description,sampleRate:RATE,channels:2,samples:sound.finish(master)});
  add('attack_slash','斬撃','短い刃の風切り、革の擦れ、控えめな鋼の余韻',
    new Sound(.28,103)
      .air(0,.19,{gain:1.9,low:180,high:900,endHigh:3100,swell:true})
      .air(0,.075,{gain:.6,low:70,high:650,decay:.028})
      .modes(.068,.14,740,[[1,1],[1.73,.3,.6],[2.91,.12,.4]],{gain:.035,decay:.035}),{peak:.56,room:.06});
  add('enemy_hit','命中','肉厚な打撃に、乾いた骨と革のひびを重ねる',
    new Sound(.20,211)
      .modes(0,.14,118,[[1,1],[1.61,.38],[2.37,.2,.5]],{gain:.35,decay:.035,bend:.22})
      .air(0,.095,{gain:1.2,low:280,high:2600,decay:.018})
      .crackle(.008,.045,4,.38),{peak:.48,room:.04});
  add('hurt_hit','被弾','低い衝撃と厚手のコートが擦れる音',
    new Sound(.36,307)
      .modes(0,.23,77,[[1,1],[1.46,.45],[2.34,.17,.7]],{gain:.48,decay:.068,bend:.15})
      .air(.002,.22,{gain:1.5,low:100,high:1450,endHigh:430,decay:.075})
      .air(.012,.06,{gain:.65,low:600,high:3800,decay:.014}),{peak:.62,room:.08});
  add('dodge_cloak','回避','コートの裾と靴が素早く空気を払う',
    new Sound(.32,409)
      .air(0,.21,{gain:1.8,low:100,high:650,endHigh:1700,swell:true})
      .air(.13,.10,{gain:.6,low:180,high:1200,decay:.045})
      .modes(.14,.10,125,[[1,1],[1.6,.3]],{gain:.045,decay:.025}),{peak:.42,room:.04});
  const loot=new Sound(.44,503);
  for(const [i,t] of [0,.055,.105].entries())loot
    .modes(t,.24,1420-i*137,[[1,1],[1.49,.32,.8],[2.17,.19,.4]],{gain:.075/(1+i*.3),decay:.048})
    .air(t,.055,{gain:.26,low:650,high:3700,decay:.011});
  add('pickup_loot','戦利品','小さな金属片が袋へ落ちる三つの軽い音',loot,{peak:.38,room:.08});
  const health=new Sound(.48,601).air(.03,.26,{gain:.42,low:120,high:840,decay:.12});
  for(const [i,t] of [0,.065,.13,.19].entries())health.modes(t,.15,280+i*43,[[1,1],[1.72,.18]],{gain:.14,decay:.026,bend:.45});
  health.modes(.20,.20,1050,[[1,1],[2.23,.15]],{gain:.021,decay:.05});
  add('pickup_health','回復','小瓶の液体と丸い気泡、淡い余韻',health,{peak:.40,room:.12});
  const lightning=new Sound(.65,701)
    .air(0,.095,{gain:1.7,low:750,high:5900,decay:.014})
    .air(.027,.45,{gain:1.05,low:70,high:1100,endHigh:260,decay:.12})
    .modes(.019,.25,62,[[1,1],[1.31,.34],[2.63,.11,.6]],{gain:.28,decay:.06})
    .crackle(.035,.20,15,.8,6300);
  add('spell_chain_lightning','連鎖雷撃','鋭い放電と低い雷鳴。鐘の音は使わない',lightning,{peak:.60,room:.22});
  add('spell_fireball','分裂火弾','低く押し出す発火と短い燃焼、火の粉',
    new Sound(.58,809)
      .modes(0,.30,84,[[1,1],[1.47,.20]],{gain:.27,decay:.065,bend:.2})
      .air(.005,.40,{gain:2.2,low:45,high:780,endHigh:230,attack:.012,decay:.15})
      .air(.055,.29,{gain:.40,low:500,high:3100,endHigh:950,swell:true})
      .crackle(.11,.23,14,.28),{peak:.59,room:.12});
  const ice=new Sound(.68,907)
    .air(0,.15,{gain:1.4,low:500,high:4700,decay:.029})
    .air(.04,.40,{gain:.42,low:1300,high:6200,endHigh:2800,decay:.13})
    .modes(0,.17,177,[[1,1],[2.28,.2]],{gain:.17,decay:.035});
  for(let i=0;i<8;i++)ice.modes(.025+i*.027,.26,1180+i*211,[[1,1],[1.41,.26,.5]],{gain:.028,decay:.037+i*.003});
  add('spell_ice_nova','霜の輪','氷面が割れ、細かな欠片が広がる',ice,{peak:.54,room:.20});
  add('spell_homing_missile','追尾の呪弾','空洞を通る風と低い呪力の共鳴',
    new Sound(.55,1009)
      .air(0,.34,{gain:1.5,low:230,high:1900,endHigh:680,swell:true})
      .modes(.015,.36,211,[[1,1],[1.38,.26],[2.11,.16,.6]],{gain:.095,attack:.025,decay:.11,bend:-.09})
      .air(.20,.17,{gain:.40,low:780,high:3100,decay:.05}),{peak:.50,room:.21});
  add('floor_complete','夜の終わり','遠くの低い鐘が一度だけ響き、静かに消える',
    new Sound(2.2,1103)
      .modes(0,2.05,146,[[1,1,1.1],[2.01,.42,.8],[2.76,.27,.6],[4.08,.13,.3],[6.73,.025,.16]],{gain:.26,decay:.47,attack:.006})
      .air(0,.11,{gain:.38,low:110,high:1700,decay:.017})
      .air(.09,.40,{gain:.12,low:55,high:370,decay:.15}),{peak:.52,room:.32});
  return bank;
}

export function encodeWav({samples,sampleRate,channels}){
  const pcm=Buffer.alloc(44+samples.length*2);
  pcm.write('RIFF');pcm.writeUInt32LE(pcm.length-8,4);pcm.write('WAVEfmt ',8);
  pcm.writeUInt32LE(16,16);pcm.writeUInt16LE(1,20);pcm.writeUInt16LE(channels,22);
  pcm.writeUInt32LE(sampleRate,24);pcm.writeUInt32LE(sampleRate*channels*2,28);
  pcm.writeUInt16LE(channels*2,32);pcm.writeUInt16LE(16,34);
  pcm.write('data',36);pcm.writeUInt32LE(samples.length*2,40);
  for(let i=0;i<samples.length;i++)pcm.writeInt16LE(Math.round(Math.max(-1,Math.min(1,samples[i]))*32767),44+i*2);
  return pcm;
}

function main(){
  const destination=fileURLToPath(new URL('../assets/audio/',import.meta.url));
  mkdirSync(destination,{recursive:true});
  const bank=createSoundBank(),manifest=[];
  const encoders=spawnSync('ffmpeg',['-hide_banner','-encoders'],{encoding:'utf8'});
  if(encoders.status!==0)throw new Error('ffmpeg is required to rebuild the sound bank');
  const encoder=encoders.stdout.includes('libvorbis') ? ['-c:a','libvorbis'] : ['-c:a','vorbis','-strict','-2'];
  for(const sound of bank){
    const wav=encodeWav(sound),file=`${sound.id}.ogg`;
    const result=spawnSync('ffmpeg',['-hide_banner','-loglevel','error','-y','-i','pipe:0',...encoder,'-q:a','5','-map_metadata','-1','-metadata',`title=ASHEN HUNT - ${sound.id}`,resolve(destination,file)],{input:wav});
    if(result.status!==0)throw new Error(`ffmpeg: ${result.stderr?.toString() ?? result.error}`);
    manifest.push({id:sound.id,file,label:sound.label,description:sound.description,duration:sound.samples.length/2/RATE,sampleRate:RATE,channels:2,pcmSha256:createHash('sha256').update(wav).digest('hex')});
  }
  writeFileSync(resolve(destination,'bank.json'),JSON.stringify({version:1,author:'ASHEN HUNT',source:'Original procedural sound design; no third-party samples.',sounds:manifest},null,2)+'\n');
  const pause=Math.round(RATE*.30)*2;
  const samples=new Float32Array(bank.reduce((n,s)=>n+s.samples.length+pause,0));
  let offset=0;
  for(const sound of bank){samples.set(sound.samples,offset);offset+=sound.samples.length+pause;}
  const output=resolve('output/ashen-sfx-preview.wav');mkdirSync(resolve('output'),{recursive:true});
  writeFileSync(output,encodeWav({samples,sampleRate:RATE,channels:2}));
  console.log(`Rendered ${bank.length} original effects and ${output}`);
}

if(process.argv[1] && resolve(process.argv[1])===fileURLToPath(import.meta.url))main();
