// The game supplies names, equipment and skills from the actual starting builds.
export function renderStartingBuilds(hud, {icon, escape}) {
  return `<p class="eyebrow">CHOOSE YOUR BUILD</p><h2>初期ビルドを選択</h2>
    <p class="panel-description">セーブ ${hud.active_save_slot + 1} · 最初の装備とスキルを選びます。<br>冒険で装備を集め、スキルツリーとスロット設定で自分のビルドに育てましょう。あとから別のビルドの技も習得できます。</p>
    <div class="starting-builds">${hud.builds.map(build => `<button data-key="13" data-selection="${build.index}" data-build="${escape(build.id)}" class="starting-build ${hud.cursor === build.index ? 'selected' : ''}">
      <span class="starting-build-heading">${icon(build.glyph)}<strong>${escape(build.name)}</strong><span aria-hidden="true">→</span></span>
      <span class="starting-build-description">${escape(build.description)}</span>
      <span class="starting-build-gear"><b>初期装備</b>${escape(build.weapon)} · ${build.equipment.map(escape).join(' / ')}</span>
      <span class="starting-build-skills"><b>スキル 1〜4</b>${build.skills.map(escape).join(' / ')}</span>
    </button>`).join('')}</div>
    <button class="save-back" data-key="27">← セーブデータ選択に戻る</button>`;
}
