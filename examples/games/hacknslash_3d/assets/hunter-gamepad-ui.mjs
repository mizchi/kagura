export const gamepadGuide=`<details id="gamepad-guide"><summary id="gamepad-status">ゲームパッド · 接続を確認</summary><div>
  <p id="gamepad-connection" role="status">接続を確認しています</p>
  <p id="gamepad-connect-help">ゲーム画面をクリックしてから、パッドのボタンを押して離してください。未検出のままなら、本体の接続モードを確認してください。</p>
  <pre id="gamepad-raw-input" aria-label="ゲームパッドの入力状態"></pre>
  <strong>標準配置 · Xbox / PlayStation</strong>
  <p>左スティック：移動<br>右スティック：照準／TPS見回し<br>離すとオートターゲット</p>
  <p>A / ×：決定／近くの品を拾う<br>X / □：通常攻撃（長押し）<br>RB / R1：盾ガード（長押し）<br>B / ○：回避／取消</p>
  <p id="gamepad-primary-skills">Y / △：通常攻撃<br>RT / R2：ワールウィンド（長押し）<br>LB / L1：分裂火弾<br>LT / L2 ＋ 十字 ↓：霜の輪</p>
  <p>習得後：<br>LT / L2 ＋ 十字 ↑：連鎖雷撃<br>LT / L2 ＋ 十字 ←：追尾の呪弾<br>LT / L2 ＋ 十字 →：反撃の構え</p>
  <p>十字 ↑：宝箱を開ける<br>十字 ←：武器切替<br>十字 ↓：星落とし<br>十字 →：突進斬り<br>L3：突進斬り / R3：TPS切替</p>
  <p>View / Share：装備袋<br>Menu / Options：一時停止<br>メニュー：十字／左スティックで選択、A / ×で決定、B / ○で戻る<br>スライダー：左右で調整</p>
  <p>装備袋：十字／左スティックでマス選択、右スティックで比較ページ切替、A / ×で持つ・置く、X / □で装備・外す、Y / △で回転、LB/RB / L1/R1で部位とバッグ切替、R3で捨てる、B / ○で取消・閉じる</p>
  <p>星落とし：右スティックで位置指定、A / ×で発動、B / ○で取消</p>
</div></details>`;

export function gamepadConnectionStatus(frame,capture='ready'){
  if(capture==='unavailable')return 'このブラウザーはGamepad API非対応です';
  if(capture==='denied')return 'ブラウザーがゲームパッドの利用を許可していません';
  if(capture==='error')return 'ゲームパッドの取得に失敗しました';
  if(capture==='hidden'||capture==='unfocused')return 'ゲーム画面をクリックして入力を有効にしてください';
  if(!frame.connected)return 'ゲームパッド未検出 · パッドのボタンを押してください';
  if(!frame.supported)return '接続済み · 標準配置として認識されていません';
  if(!frame.ready)return '接続済み · ボタンとスティックを一度離してください';
  return '接続済み · 操作できます';
}

export function createGamepadGuide(root){
  const guide=root.querySelector('#gamepad-guide'),status=root.querySelector('#gamepad-status');
  const connection=root.querySelector('#gamepad-connection'),raw=root.querySelector('#gamepad-raw-input');
  let connected=false,lastDetails=-Infinity;
  const text=(element,value)=>{if(element&&element.textContent!==value)element.textContent=value;};
  return {
    status(frame,active){
      connected=frame.connected;
      root.classList.toggle('gamepad-connected',connected);
      const runtime=globalThis.__kaguraWebRuntime;
      const message=gamepadConnectionStatus(frame,runtime?.gamepadCaptureStatus);
      text(status,!frame.connected?'ゲームパッド · 接続を確認':!frame.ready?`ゲームパッド · ${message}`:active?'ゲームパッド操作 · 配置を見る':'ゲームパッド接続中 · 配置を見る');
      text(connection,message);
      const now=performance.now();
      if(guide.open&&now-lastDetails>=250){
        lastDetails=now;
        const pads=runtime?.gamepadFrame??[];
        text(raw,pads.length?pads.map(p=>{
          const profile=p.index===frame.index&&frame.profile==='victrix-pro-bfg-ps5-mac'?'Victrix Pro BFG PS5（Kagura補正）':p.mapping||'未割当';
          return `${p.id}\n配置: ${profile} / 機器 ${p.index}\nブラウザー配置: ${p.mapping||'未割当'}\n軸: ${p.axes.map(v=>v.toFixed(2)).join(', ')}\n押下: ${p.buttons.flatMap((b,i)=>b.pressed||b.value>=.55?[i]:[]).join(', ')||'なし'}`;
        }).join('\n\n'):'ブラウザーから届いている機器: 0');
      }
    },
    render(hud,active){
      guide.hidden=hud.menu==='inventory'||(!connected&&hud.mode==='playing'&&!hud.paused&&hud.menu==='none');
      root.classList.toggle('gamepad-active',active);
      text(root.querySelector('#gamepad-primary-skills'),['Y / △','RT / R2','LB / L1','LT / L2 ＋ 十字 ↓'].map((label,i)=>`${label}：${hud.skills?.[i]?.name??''}${hud.skills?.[i]?.hold?'（長押し）':''}`).join('\n'));
      for(const [i,label] of ['Y / △','RT / R2','LB / L1','LT / L2 + ↓'].entries())text(root.querySelector(`[data-skill="${i}"] kbd`),active?label:i<2?`${i+1} / ${i===0?'左':'右'}`:String(i+1));
      text(root.querySelector('#attack-button kbd'),active?'X / □':'J / □');
      if(hud.dodge<=0)text(root.querySelector('#dodge-status'),active?'B / ○':'SPACE');
      if(!hud.arts.guarding&&hud.arts.guard_recovery<=0)text(root.querySelector('#guard-status'),active?'RB / R1 長押し':'F / 長押し');
      if(!hud.arts.targeting&&hud.arts.ground_remaining<=0)text(root.querySelector('#astral-status'),active?'十字 ↓ / 位置指定':'T / 位置指定');
      if(hud.arts.dash_remaining<=0)text(root.querySelector('#dash-strike-status'),active?'十字 →':'V');
      text(root.querySelector('.weapon-picker kbd'),active?'十字 ←':'X');
      text(root.querySelector('#chest-prompt kbd'),active?'十字 ↑':'B');
      text(root.querySelector('#target-hint kbd'),active?'B / ○':'ESC');
      if(hud.arts.targeting&&active)text(root.querySelector('#target-hint span'),hud.arts.target_valid?'右スティックで位置指定 · A / ×で発動 · B / ○で取消':'遮蔽物のない地面へ右スティックで移動');
      for(const s of hud.extra_skills)if(s.remaining<=0)text(root.querySelector(`#learned-arts [data-key="${s.key}"] small`),active?({53:'LT / L2 + ↑',54:'LT / L2 + ←',56:'LT / L2 + →'}[s.key]??String.fromCharCode(s.key)):String.fromCharCode(s.key));
    },
  };
}
