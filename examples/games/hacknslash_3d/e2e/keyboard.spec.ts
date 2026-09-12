import { test, expect } from '@playwright/test';

test.beforeEach(async ({ page }) => {
  await page.goto('/?mute=1');
  await page.waitForFunction(() => globalThis.__hacknslash3dRuntime?.mode === 'title');
  await page.evaluate(() => {
    globalThis.__keyEvents = [];
    window.addEventListener('keydown', event => globalThis.__keyEvents.push(event), true);
  });
});

test('engine normalizes physical codes independently of Dvorak characters and keyCode', async ({ page }) => {
  await page.locator('canvas').focus();
  const cases: [string,string,number,number][] = [
    ['KeyW',',',188,87], ['KeyA','a',65,65], ['KeyS','o',79,83], ['KeyD','e',69,68],
    ['KeyF','u',85,70], ['KeyQ',"'",222,81], ['KeyE','.',190,69], ['KeyR','p',80,82],
    ['KeyJ','h',72,74], ['KeyO','r',82,79], ['Comma','w',87,188], ['KeyZ',';',186,90],
    ['F12','F12',0,123], ['Numpad7','7',55,103], ['ArrowLeft','ArrowLeft',0,37],
    ['BracketLeft','/',191,219], ['Unidentified','w',87,0],
  ];
  for (const [code,key,keyCode,expected] of cases) {
    const result = await page.evaluate(({code,key,keyCode}) => {
      const target=document.activeElement;
      for (const repeat of [false,true]) target.dispatchEvent(new KeyboardEvent('keydown', {
        code,key,keyCode,repeat,bubbles:true,cancelable:true,
      }));
      const pressed=[...globalThis.__kaguraWebRuntime.pressedKeys];
      // Layout/Shift/IME changes between down and up must not leave keys stuck.
      target.dispatchEvent(new KeyboardEvent('keyup', {code,key:'Unidentified',keyCode:229,bubbles:true}));
      return {pressed,released:[...globalThis.__kaguraWebRuntime.pressedKeys]};
    }, {code,key,keyCode});
    expect(result, code).toEqual({pressed:expected ? [expected] : [],released:[]});
  }
});

test('Dvorak physical movement and camera keys never trigger each other', async ({ page, context }) => {
  await page.goto('/?snapshot=playing&frames=0&mute=1&seed=42');
  await page.waitForFunction(() => globalThis.__ashenHunt?.bones === 14);
  await page.locator('canvas').focus();
  const session=await context.newCDPSession(page);
  const actor=()=>page.evaluate(() => globalThis.__ashenHunt);
  const start=await actor();
  await session.send('Input.dispatchKeyEvent',{type:'keyDown',code:'KeyD',key:'e',windowsVirtualKeyCode:69});
  await expect.poll(async()=>{const s=await actor();return Math.hypot(s.x-start.x,s.y-start.y);}).toBeGreaterThan(5);
  await session.send('Input.dispatchKeyEvent',{type:'keyUp',code:'KeyD',key:'e',windowsVirtualKeyCode:69});
  expect((await actor()).yaw).toBe(start.yaw);
  const stopped=await actor();
  await session.send('Input.dispatchKeyEvent',{type:'keyDown',code:'KeyE',key:'.',windowsVirtualKeyCode:190});
  await expect.poll(async()=>(await actor()).yaw).toBeGreaterThan(stopped.yaw+.05);
  await session.send('Input.dispatchKeyEvent',{type:'keyUp',code:'KeyE',key:'.',windowsVirtualKeyCode:190});
  const turned=await actor();
  expect([turned.x,turned.y]).toEqual([stopped.x,stopped.y]);
  // Dvorak "u" is physical F: it is not a movement or camera binding.
  await session.send('Input.dispatchKeyEvent',{type:'keyDown',code:'KeyF',key:'u',windowsVirtualKeyCode:85});
  await page.waitForTimeout(80);
  await session.send('Input.dispatchKeyEvent',{type:'keyUp',code:'KeyF',key:'u',windowsVirtualKeyCode:85});
  const idle=await actor();
  expect([idle.x,idle.y,idle.yaw]).toEqual([turned.x,turned.y,turned.yaw]);
});

test('game keys consume native text input, including repeats and HUD focus', async ({ page }) => {
  for (const target of ['canvas', 'body', '#hunter-panel button']) {
    await page.locator(target).first().evaluate(element => {
      element.setAttribute('tabindex', '0');
      element.focus();
    });
    const keys = ['w', 'a', 's', 'd', 'q', 'e', 'r', 'j', 'm', 'ArrowUp', 'ArrowDown'];
    // The engine also consumes printable keys not bound by the game's HUD.
    if (target === 'canvas') keys.push('z');
    for (const key of keys) {
      await page.keyboard.down(key);
      await page.keyboard.down(key);
      const events = await page.evaluate(() => globalThis.__keyEvents.slice(-2).map(event => ({
        prevented: event.defaultPrevented, repeat: event.repeat,
      })));
      await page.keyboard.up(key);
      expect(events, `${target}: ${key}`).toEqual([
        {prevented: true, repeat: false}, {prevented: true, repeat: true},
      ]);
    }
  }
});

test('text fields, browser shortcuts and Tab retain their native behavior', async ({ page }) => {
  await page.locator('canvas').focus();
  for (const modifier of ['Control', 'Meta', 'Alt']) {
    // Synthetic events check cancellation without opening actual browser UI.
    const result = await page.evaluate(modifier => {
      const event = new KeyboardEvent('keydown', {
        key: 'p', code: 'KeyP', keyCode: 80, bubbles: true, cancelable: true,
        ctrlKey: modifier === 'Control', metaKey: modifier === 'Meta', altKey: modifier === 'Alt',
      });
      document.activeElement.dispatchEvent(event);
      return {prevented: event.defaultPrevented, pressed: [...globalThis.__kaguraWebRuntime.pressedKeys]};
    }, modifier);
    expect(result).toEqual({prevented: false, pressed: []});
  }
  await page.keyboard.press('Tab');
  expect(await page.evaluate(() => globalThis.__keyEvents.at(-1).defaultPrevented)).toBe(false);
  await page.evaluate(() => {
    const input = document.createElement('input');
    input.id = 'typing-fixture';
    document.body.appendChild(input);
    input.focus();
  });
  await page.keyboard.type('wasdpik');
  await expect(page.locator('#typing-fixture')).toHaveValue('wasdpik');
  expect(await page.evaluate(() => globalThis.__keyEvents.slice(-7).every(event => !event.defaultPrevented))).toBe(true);
  expect(await page.evaluate(() => globalThis.__ashenControls.consumeKey())).toBe(0);
  await page.keyboard.down('w');
  expect(await page.evaluate(() => globalThis.__kaguraWebRuntime.pressedKeys)).toEqual([]);
  await page.keyboard.up('w');
  await page.locator('#hunter-panel button').focus();
  await page.keyboard.press('Enter');
  await page.waitForFunction(() => globalThis.__hacknslash3dRuntime?.mode === 'character_select');
});
