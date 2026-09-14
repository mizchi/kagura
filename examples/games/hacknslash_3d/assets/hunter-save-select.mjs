// Save metadata comes from the game; this view never reads or mutates storage.
export function renderSaveSelect(hud,{escape}){
  if(hud.save_delete_slot>=0){
    const s=hud.save_slots.find(s=>s.slot===hud.save_delete_slot);
    return `<p class="eyebrow">SAVE ${String(s.slot+1).padStart(2,'0')}</p><h2>セーブ ${s.slot+1} を削除しますか？</h2>
      <div class="save-delete-summary"><strong>${s.status==='ready'?escape(s.build_name??'キャラクター'):'読み込めないセーブデータ'}</strong><p>${s.status==='ready'?`Lv. ${s.level} · ${escape(s.region)} · 討伐点 ${s.score}`:'この枠に残っているデータを削除します。'}</p></div>
      <p class="panel-description">この枠の装備・成長・探索状況を削除します。<br>削除したデータは元に戻せません。</p>
      <div class="save-delete-actions"><button data-key="27" data-focus="delete-cancel" data-autofocus>キャンセル</button><button data-key="13" data-focus="delete-confirm" class="save-delete-confirm">削除する</button></div>
      <p class="save-notice" role="status">${escape(hud.save_notice)}</p>`;
  }
  return `<p class="eyebrow">ASHEN REALMS · 装備とスキルで、戦い方をつくる。</p><h2>セーブデータ選択</h2>
    <p class="panel-description">育てたキャラクターで冒険を続けるか、空き枠で新しく始めます。</p>
    <div class="save-slots">${hud.save_slots.map(s=>{
      const ready=s.status==='ready',invalid=s.status==='invalid';
      return `<div class="save-slot-row"><button data-key="13" data-selection="${s.slot}" data-save-slot="${s.slot}" data-focus="save-${s.slot}" ${hud.cursor===s.slot&&!invalid?'data-autofocus':''} class="save-slot ${hud.cursor===s.slot?'selected':''}" ${invalid?'disabled':''}>
        <span class="save-number">${String(s.slot+1).padStart(2,'0')}</span><span class="save-info"><strong>${ready?escape(s.build_name??'キャラクター'):invalid?'読み込めません':'新しく始める'}</strong>
        <small>${ready?`Lv. ${s.level} · ${escape(s.region)} · 討伐点 ${s.score}`:invalid?'データを保持しています':'新規セーブ · 初期ビルドを選択'}</small></span><span class="save-action">${ready?'続ける':invalid?'':'＋'}</span></button>
        ${ready||invalid?`<button class="save-delete" data-key="46" data-selection="${s.slot}" data-focus="delete-${s.slot}" ${invalid&&hud.cursor===s.slot?'data-autofocus':''} aria-label="セーブ ${s.slot+1} を削除">削除</button>`:''}</div>`;
    }).join('')}</div>
    <p class="save-notice" role="status">${escape(hud.save_notice)}</p>
    <small>装備・成長・探索状況は自動保存。<br>倒れたら、最後に触れたウェイポイントから再開します。</small>`;
}
