/** Mechanical evidence for an experience review. This cannot establish whether
 * a human finds the game satisfying, or whether pixels/sound communicate it. */
export function auditReceipts(before,after){
  const last=Math.max(0,...before.effects.map(e=>e.id));
  const cues=after.effects.filter(e=>e.id>last);
  let checks=0,mismatches=0;
  const team=(name,a,b)=>{
    for(let i=0;i<a.length;i++){
      if(!b?.[i])continue;
      const delta=cues.filter(e=>e.team===name&&e.target===i).reduce((sum,e)=>sum+(e.kind==='heal'?e.amount:-e.amount),0);
      const levelGain=Math.max(0,(b[i].maxHp??0)-(a[i].maxHp??0));
      const actual=name==='party'&&after.event==='defeat'?0:b[i].hp;
      const expected=Math.max(0,a[i].hp+delta)+(actual>0?levelGain:0);
      checks++;if(expected!==actual)mismatches++;
    }
  };
  team('party',before.party,after.party);
  if(before.battle&&after.battle)team('enemy',before.battle.foes,after.battle.foes);
  return {checks,mismatches,cues};
}

export function createExperienceProbe(){
  let rounds=0,pressured=0,critical=0,enemyDamage=0,recovery=0,checks=0,mismatches=0;
  let encounters=0,normalRounds=0,bossRounds=0,normalEncounters=0,bossEncounters=0;
  const highlights=[];
  return {
    record(before,after,action={}){
      if(!before.battle&&after.battle){encounters++;if(after.battle.boss)bossEncounters++;else normalEncounters++;}
      const resolved=before.battle?.phase==='planning'&&
        (after.battle?.phase==='report'||after.battle?.phase==='won'||after.event==='defeat');
      const fieldRecovery=before.mode==='explore'&&after.mode==='explore'&&before.revision!==after.revision;
      if(!resolved&&!fieldRecovery)return;
      const audit=auditReceipts(before,after);checks+=audit.checks;mismatches+=audit.mismatches;
      recovery+=audit.cues.filter(c=>c.team==='party'&&c.kind==='heal').reduce((n,c)=>n+c.amount,0);
      if(resolved){
        highlights.push({round:before.battle.round,boss:before.battle.boss,orders:before.battle.orders,lastAction:action.choiceId,
          hpBefore:before.party.map(h=>h.hp),hpAfter:after.party.map(h=>h.hp),
          cues:audit.cues,result:after.event,recentLog:after.log?.slice(-4)});
        if(highlights.length>24)highlights.shift();
        rounds++;if(before.battle.boss)bossRounds++;else normalRounds++;
        const damage=audit.cues.filter(c=>c.team==='party'&&c.kind!=='heal').reduce((n,c)=>n+c.amount,0);
        enemyDamage+=damage;if(damage>0)pressured++;
        if(after.event==='defeat'||after.party.some(h=>h.hp>0&&h.hp/h.maxHp<=.3))critical++;
      }
    },
    metrics(){return {
      resolvedRounds:rounds,encounters,pressureRoundRate:rounds?pressured/rounds:0,
      criticalRoundRate:rounds?critical/rounds:0,recoveryShare:enemyDamage?recovery/enemyDamage:0,
      normalEncounterRounds:normalEncounters?normalRounds/normalEncounters:0,
      bossEncounterRounds:bossEncounters?bossRounds/bossEncounters:0,
      feedbackMismatchRate:checks?mismatches/checks:0,feedbackChecks:checks,
    };},
    evidence(){return {kind:'mechanical-trace',rendered:false,highlights:structuredClone(highlights)};},
  };
}
