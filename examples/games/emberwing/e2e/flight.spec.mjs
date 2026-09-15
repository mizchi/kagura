import { test, expect } from "@playwright/test";

const snapshot = (page) => page.evaluate(() => globalThis.emberwing?.snapshot());
async function boot(page) {
  const errors = [];
  page.on("pageerror", (error) => errors.push(error.message));
  page.on("console", (message) => {
    if (message.type() === "error" && !message.location().url.endsWith("/favicon.ico")) errors.push(message.text());
  });
  await page.goto("/");
  await expect(page.locator("#start")).toBeVisible();
  await expect.poll(async () => (await snapshot(page))?.mode).toBe("title");
  await expect(page.locator("#game-surface")).toHaveCSS("position", "fixed");
  await page.locator("#start").click();
  await expect.poll(async () => (await snapshot(page)).mode).toBe("playing");
  return errors;
}
async function aim(page, target) {
  const viewport = page.viewportSize();
  await page.mouse.move((target.x+1)*viewport.width/2,(1-target.y)*viewport.height/2);
}

test("hold sweeps multiple locks; release fires homing balls and cooks falling dishes", async ({ page }) => {
  const errors = await boot(page);
  const first = (await snapshot(page)).targets[0];
  await aim(page,first); await page.mouse.down();
  // Sweep through the flock using real pointer input.
  for (const index of [0,1,3,5]) {
    const target = (await snapshot(page)).targets[index];
    await aim(page,target); await page.waitForTimeout(170);
  }
  await expect.poll(async () => (await snapshot(page)).locks).toBeGreaterThanOrEqual(3);
  expect((await snapshot(page)).fireballs).toBe(0);
  await page.mouse.up();
  await expect.poll(async () => (await snapshot(page)).fireballs).toBeGreaterThanOrEqual(3);
  await expect.poll(async () => (await snapshot(page)).kills).toBeGreaterThanOrEqual(3);
  const cooked = await snapshot(page);
  expect(cooked.bowls).toBeGreaterThanOrEqual(3);
  expect(cooked.score).toBe(cooked.kills*100);
  expect(cooked.draw_calls).toBeLessThanOrEqual(16);
  await page.screenshot({path:"output/emberwing/volley.png"});
  await page.keyboard.press("Escape");
  await expect.poll(async () => (await snapshot(page)).mode).toBe("paused");
  const time = (await snapshot(page)).time;
  await page.waitForTimeout(350);
  expect((await snapshot(page)).time).toBe(time);
  await page.locator("#continue").click();
  await expect.poll(async () => (await snapshot(page)).mode).toBe("playing");
  expect(errors).toEqual([]);
});

test("right mouse breath hits the aimed enemy; overheating and restart recover", async ({ page }) => {
  const errors = await boot(page);
  const id = (await snapshot(page)).targets[0].id;
  await aim(page,(await snapshot(page)).targets[0]);
  await page.mouse.down({button:"right"});
  for (let i=0;i<12;i++) {
    const target=(await snapshot(page)).targets.find((t)=>t.id===id);
    if (!target) break;
    await aim(page,target); await page.waitForTimeout(80);
  }
  await expect.poll(async () => (await snapshot(page)).kills).toBeGreaterThan(0);
  await expect.poll(async () => (await snapshot(page)).overheated,{timeout:6500}).toBe(true);
  expect((await snapshot(page)).breathing).toBe(false);
  await page.mouse.up({button:"right"});
  await expect.poll(async () => (await snapshot(page)).overheated,{timeout:5000}).toBe(false);
  await page.keyboard.press("Escape"); await page.locator("#return").click();
  await expect(page.locator("#start")).toBeVisible();
  await page.locator("#start").click();
  await expect.poll(async () => (await snapshot(page)).score).toBe(0);
  expect((await snapshot(page)).hp).toBe(6);
  expect((await snapshot(page)).breathing).toBe(false);
  expect(errors).toEqual([]);
});

test("portrait layout fits the play surface and physical keys work independently of layout", async ({ page }) => {
  await page.setViewportSize({width:390,height:844});
  const errors = await boot(page);
  expect(await page.evaluate(() => document.documentElement.scrollHeight)).toBe(844);
  expect(await page.evaluate(() => document.documentElement.scrollWidth)).toBe(390);
  const bounds = await page.locator("#app").boundingBox();
  expect(bounds).toEqual({x:0,y:0,width:390,height:844});
  expect((await page.locator("header").boundingBox()).y).toBe(18);
  // Dvorak logical 'e' at the physical D position must stay a movement key.
  await page.evaluate(() => window.dispatchEvent(new KeyboardEvent("keydown",{code:"KeyD",key:"e",bubbles:true})));
  await page.waitForTimeout(150);
  await page.evaluate(() => window.dispatchEvent(new KeyboardEvent("keyup",{code:"KeyD",key:"e",bubbles:true})));
  expect((await snapshot(page)).mode).toBe("playing");
  expect((await snapshot(page)).player_x).toBeGreaterThan(0.2);
  await page.screenshot({path:"output/emberwing/portrait.png"});
  expect(errors).toEqual([]);
});

test.describe("touch flight", () => {
  test.use({viewport:{width:390,height:844},hasTouch:true,isMobile:true});
  test("the aim finger can lift without releasing the separate lock button", async ({page}) => {
    const errors=await boot(page);
    await expect(page.locator("#touch-lock")).toBeVisible();
    const cdp=await page.context().newCDPSession(page);
    const b=await page.locator("#touch-lock").boundingBox();
    const target=(await snapshot(page)).targets[0];
    const lock={id:1,x:b.x+b.width/2,y:b.y+b.height/2};
    const finger={id:2,x:(target.x+1)*195,y:(1-target.y)*422};
    await cdp.send("Input.dispatchTouchEvent",{type:"touchStart",touchPoints:[lock]});
    await cdp.send("Input.dispatchTouchEvent",{type:"touchStart",touchPoints:[lock,finger]});
    await expect.poll(async()=>(await snapshot(page)).locks).toBeGreaterThan(0);
    await cdp.send("Input.dispatchTouchEvent",{type:"touchEnd",touchPoints:[finger]});
    await page.waitForTimeout(120);
    expect((await snapshot(page)).aiming).toBe(true);
    expect((await snapshot(page)).fireballs).toBe(0);
    await cdp.send("Input.dispatchTouchEvent",{type:"touchEnd",touchPoints:[]});
    await expect.poll(async()=>(await snapshot(page)).fireballs).toBeGreaterThan(0);
    expect(errors).toEqual([]);
  });
});
