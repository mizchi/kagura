import {test, expect} from '@playwright/test';

const upload = (dialog, value) => dialog.getByLabel('シーン遷移定義JSON').setInputFiles({
  name:'flow.json',mimeType:'application/json',buffer:Buffer.from(JSON.stringify(value)),
});
test('scene flows visualize declared edges and locate structural problems', async ({page}) => {
  await page.goto('/e2e/fixtures/scene-flow.html');
  const dialog = page.getByRole('dialog',{name:'シーン遷移',exact:true});
  await expect(dialog.getByRole('img',{name:'シーンの状態遷移図'})).toBeVisible();
  await expect(dialog.getByRole('status')).toContainText('問題なし');
  await expect(dialog.getByRole('table',{name:'遷移一覧'})).toContainText('finish');
  await page.screenshot({path:'output/scene-flow/diagram.png'});
  const definition = {
    entry:'title',scenes:['title','play','result','unused'],terminal:['result'],
    transitions:[
      {from:'title',event:'start',to:'play'},
      {from:'play',event:'finish',to:'missing'},
      {from:'unused',event:'go',to:'play'},
    ],
  };
  await upload(dialog,definition);
  await expect(dialog.getByRole('status')).toContainText('エラー');
  await expect(dialog.getByRole('list',{name:'検証結果'})).toContainText('到達不能');
  await expect(dialog.getByRole('list',{name:'検証結果'})).toContainText('未定義の遷移先');
  await dialog.getByRole('button',{name:/unused.*到達不能/}).click();
  await expect(dialog.getByRole('status')).toContainText('選択: unused');
  await upload(dialog,{oops:true});
  await expect(dialog.getByRole('alert')).toContainText('読込エラー');
  await expect(dialog.getByRole('table',{name:'遷移一覧'})).toContainText('missing');
  const download = page.waitForEvent('download');
  await dialog.getByRole('button',{name:'Mermaidを書出'}).click();
  expect((await download).suggestedFilename()).toBe('scene-flow.mmd');
  await page.screenshot({path:'output/scene-flow/problems.png'});
});
test('phone flow keeps its graph locally scrollable and supports keyboard dismissal', async ({page}) => {
  await page.setViewportSize({width:390,height:844});
  await page.goto('/e2e/fixtures/scene-flow.html');
  const dialog = page.getByRole('dialog',{name:'シーン遷移',exact:true});
  await expect(dialog).toBeVisible();
  expect(await page.evaluate(() => document.documentElement.scrollWidth)).toBe(390);
  await page.screenshot({path:'output/scene-flow/phone.png'});
  await page.keyboard.press('Escape');
  await expect(dialog).not.toBeVisible();
});
test('Studio exposes the flow viewer from the toolbar', async ({page}) => {
  await page.goto('/');
  await page.getByRole('button',{name:'シーン遷移',exact:true}).click();
  await expect(page.getByRole('dialog',{name:'シーン遷移',exact:true})).toBeVisible();
});

test('Studio reads Arena portals from the current project and restores background controls', async ({page}) => {
  await page.goto('/');
  await page.getByLabel('Examples',{exact:true}).selectOption('arena3d');
  await expect(page.getByRole('status')).toContainText('Opened project');
  await page.getByRole('button',{name:'シーン遷移',exact:true}).click();
  const dialog = page.getByRole('dialog',{name:'シーン遷移',exact:true});
  await dialog.getByRole('button',{name:'プロジェクトから読込'}).click();
  await expect(dialog.getByRole('status')).toContainText('2シーン / 1遷移 · 問題なし');
  await expect(dialog.getByRole('table',{name:'遷移一覧'})).toContainText('portal:portal');
  await page.screenshot({path:'output/scene-flow/arena.png'});
  await dialog.getByRole('button',{name:'閉じる',exact:true}).click();
  await page.getByLabel('Project scene',{exact:true}).selectOption('second');
  await expect(page.getByRole('status')).toContainText('Opened scene · second');
});

test('viewer keyboard shortcuts do not change the scene in the background', async ({page}) => {
  await page.goto('/');
  await page.waitForFunction(() => typeof globalThis.kagura?.snapshot === 'function');
  const before = await page.evaluate(() => {
    const s = kagura.snapshot();
    kagura.dispatch({expectedRevision:s.revision,commands:[{
      op:'node.rename',id:s.document.nodes[0].id,name:'Preserved scene',
    }]});
    return kagura.snapshot();
  });
  await page.getByRole('button',{name:'シーン遷移',exact:true}).click();
  await page.keyboard.press('Control+z');
  expect(await page.evaluate(() => kagura.snapshot())).toEqual(before);
});

for (const [game,scenes,transitions] of [['card_game',4,8],['belt_action',5,8],['dungeon_rpg',6,12]])
  test(game+' loads its executable screen flow directly from the project', async ({page}) => {
    await page.goto('/');
    await page.getByLabel('Examples',{exact:true}).selectOption(game);
    await expect(page.getByRole('status')).toContainText('Opened project');
    await page.getByRole('button',{name:'シーン遷移',exact:true}).click();
    const dialog=page.getByRole('dialog',{name:'シーン遷移',exact:true});
    await dialog.getByRole('button',{name:'プロジェクトから読込'}).click();
    await expect(dialog.getByRole('status')).toContainText(`${scenes}シーン / ${transitions}遷移 · 問題なし`);
    await expect(dialog.getByRole('table',{name:'遷移一覧'}).locator('tbody tr')).toHaveCount(transitions);
    const overlaps=await dialog.locator('.scene-flow-edge-label').evaluateAll(elements => {
      const rects=elements.map(e=>({text:e.textContent,rect:e.getBoundingClientRect()})), pairs=[];
      for(let i=0;i<rects.length;i++) for(let j=0;j<i;j++) {
        const a=rects[i].rect,b=rects[j].rect;
        if (Math.min(a.right,b.right)>Math.max(a.left,b.left) && Math.min(a.bottom,b.bottom)>Math.max(a.top,b.top))
          pairs.push([rects[i].text,rects[j].text]);
      }
      return pairs;
    });
    expect(overlaps).toEqual([]);
    await page.screenshot({path:`output/scene-flow/${game}.png`});
    await dialog.getByRole('table',{name:'遷移一覧'}).scrollIntoViewIfNeeded();
    await page.screenshot({path:`output/scene-flow/${game}-transitions.png`});
  });

test('a phone can inspect a larger example flow and reach its final transition', async ({page}) => {
  await page.setViewportSize({width:390,height:844});
  await page.goto('/e2e/fixtures/scene-flow.html?game=dungeon_rpg');
  const dialog=page.getByRole('dialog',{name:'シーン遷移',exact:true});
  await expect(dialog.getByRole('status')).toContainText('6シーン / 12遷移 · 問題なし');
  expect(await page.evaluate(()=>document.documentElement.scrollWidth)).toBe(390);
  await page.screenshot({path:'output/scene-flow/dungeon-phone.png'});
  const event=dialog.getByRole('table',{name:'遷移一覧'}).locator('tbody tr').last().locator('td').nth(2);
  await event.scrollIntoViewIfNeeded();
  await expect(event).toBeInViewport({ratio:0.8});
  await page.screenshot({path:'output/scene-flow/dungeon-phone-transitions.png'});
});
