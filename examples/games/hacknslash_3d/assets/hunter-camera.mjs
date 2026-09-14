// Transport only: MoonBit owns validation, presets, framing and collision.
export function createCameraInput({save=()=>{},schedule=setTimeout,cancel=clearTimeout}={}) {
  const commands=[];
  let lookX=0,lookY=0,pendingSave=null,timer=null;
  const flush=()=>{if(timer!==null)cancel(timer);timer=null;if(pendingSave!==null){save(pendingSave);pendingSave=null;}};
  return {
    command(field,value){
      if(!Number.isInteger(field)||field<0||field>6||!Number.isFinite(value))return;
      const last=commands.at(-1);
      if(last?.[0]===field&&field!==0&&field!==6)last[1]=value;
      else commands.push([field,value]);
    },
    consumeCommand:()=>commands.shift()??[],
    look(x,y){lookX+=x;lookY+=y;},
    consumeLook(){const v=lookX||lookY?[lookX,lookY]:[];lookX=lookY=0;return v;},
    clear(){commands.length=0;lookX=lookY=0;},
    save(value){pendingSave=value;if(timer!==null)cancel(timer);timer=schedule(flush,200);},
    flush,
  };
}

const fields=[
  [1,'tilt','Tilt · 傾き',20,80,1,'°'],
  [2,'distance','カメラの距離',8,26,.1,''],
  [3,'side','左右の位置',-2,2,.05,''],
  [4,'height','注視点の高さ',.2,2,.05,''],
  [5,'forward','前後の位置',-2,3,.05,''],
];
const display=(field,value)=>field===1?`${Math.round(value)}°`:Number(value).toFixed(2);
export function renderCameraPanel(camera) {
  const tps=camera.mode===1;
  return `<button class="close-panel" data-key="27" aria-label="一時停止メニューに戻る">←</button>
    <p class="eyebrow">FRAME YOUR HUNT</p><h2>カメラ設定</h2>
    <p class="camera-preview-note">フィールドを止めてプレビュー中</p>
    <div class="camera-modes" role="group" aria-label="視点モード">
      <button data-camera-mode="0" aria-pressed="${!tps}" data-autofocus>クオータービュー</button>
      <button data-camera-mode="1" aria-pressed="${tps}">TPS</button>
    </div>
    <div class="camera-sliders">${fields.map(([id,key,label,min,max,step])=>{
      if(tps&&id===1){min=5;max=60;}if(tps&&id===2){min=2;max=8;}
      return `<label><span>${label}<output data-camera-output="${id}">${display(id,camera.tuning[key])}</output></span><input type="range" aria-label="${label}" data-camera-field="${id}" data-camera-name="${key}" min="${min}" max="${max}" step="${step}" value="${camera.tuning[key]}"></label>`;
    }).join('')}</div>
    <p class="camera-help">左右・前後は視点を基準に調整します。<br>${tps?'中ボタンドラッグで見回し、マウス操作中は中央を狙います。タッチでは画面の空いた場所をドラッグ。':'Q・E／中ボタンドラッグで回転。ホイールで距離を調整。'}<br>設定はモードごとに自動保存。Zで視点切替。</p>
    <div class="camera-actions"><button data-key="78">地形実験</button><button data-camera-reset>この視点をリセット</button><button data-key="80">冒険を再開する</button></div>`;
}

export function bindCameraPanel(root,camera) {
  root.addEventListener('input',event=>{
    const field=event.target.dataset.cameraField;
    if(field===undefined)return;
    const value=Number(event.target.value);
    root.querySelector(`[data-camera-output="${field}"]`).textContent=display(Number(field),value);
    camera.command(Number(field),value);
  });
  root.addEventListener('click',event=>{
    const b=event.target.closest('[data-camera-mode],[data-camera-reset]');
    if(!b)return;
    event.preventDefault();event.stopPropagation();
    if(b.hasAttribute('data-camera-reset'))camera.command(6,0);
    else camera.command(0,Number(b.dataset.cameraMode));
  });
  // Ranges must keep focus and drag capture while HUD values arrive each frame.
  return view=>{
    for(const range of root.querySelectorAll('[data-camera-field]')){
      if(range===root.ownerDocument.activeElement)continue;
      const value=view.tuning[range.dataset.cameraName];
      range.value=value;
      root.querySelector(`[data-camera-output="${range.dataset.cameraField}"]`).textContent=display(Number(range.dataset.cameraField),value);
    }
  };
}

// The engine owns fullscreen canvas styles. Reserve editor space through its API
// so resizing and game-only capture retain the same presentation contract.
export function syncCameraViewport(root,editing) {
  const presentation=root.ownerDocument.defaultView.__kaguraPresentation;
  if(!editing){presentation?.setViewportInsets();return;}
  const panel=root.querySelector('.panel-camera,.panel-terrain');
  if(!panel)return;
  const host=root.ownerDocument.defaultView;
  const rect=panel.getBoundingClientRect();
  presentation?.setViewportInsets(rect.width>=host.innerWidth-1
    ?{bottom:host.innerHeight-rect.top}
    :{right:host.innerWidth-rect.left+16});
}

export function bindTouchCamera(stage,camera,enabled) {
  let pointer=null,previous=null;
  stage.addEventListener('pointerdown',event=>{
    if(event.pointerType!=='touch'||!enabled()||pointer!==null)return;
    pointer=event.pointerId;previous=[event.clientX,event.clientY];
    stage.setPointerCapture(pointer);
  });
  stage.addEventListener('pointermove',event=>{
    if(event.pointerId!==pointer||!previous||!enabled())return;
    camera.look((event.clientX-previous[0])*.008,(event.clientY-previous[1])*.006);
    previous=[event.clientX,event.clientY];
  });
  const cancel=()=>{pointer=previous=null;camera.consumeLook();};
  stage.addEventListener('pointerup',event=>{if(event.pointerId===pointer)pointer=previous=null;});
  for(const type of ['pointercancel','lostpointercapture'])stage.addEventListener(type,event=>{if(event.pointerId===pointer)cancel();});
  stage.ownerDocument.defaultView.addEventListener('blur',cancel);
}
