// Profile real rendering and real mouse input; never advances simulation out of band.
import { chromium } from "@playwright/test";
const metal = process.env.EMBERWING_GPU === "metal";
const browser = await chromium.launch({
  ...(metal ? {channel:"chrome"} : {}), headless:true,
  args: metal ? ["--enable-unsafe-webgpu","--enable-gpu","--use-angle=metal"]
    : ["--enable-unsafe-webgpu","--use-angle=swiftshader","--enable-unsafe-swiftshader"],
});
try {
  const page = await browser.newPage({viewport:{width:1440,height:900},deviceScaleFactor:1});
  const url=process.env.EMBERWING_URL || "http://localhost:5194/";
  await page.goto(url);
  await page.locator("#start").click();
  await page.waitForTimeout(1000);
  await page.evaluate(() => {
    const frame = globalThis.__emberwingFrame;
    let previous = performance.now();
    globalThis.emberwingSamples = [];
    globalThis.__emberwingFrame = (s) => {
      frame(s); const now = performance.now();
      if (s.mode === "playing") globalThis.emberwingSamples.push({frame_ms:now-previous,render_cpu_ms:s.cpu_ms,draws:s.draw_calls,triangles:s.triangles,enemies:s.targets.filter(t=>!t.boss).length+(s.boss_active?1:0),balls:s.fireballs,bowls:s.bowls,shots:s.shots,rocks:s.rocks,beams:s.beams});
      previous = now;
    };
  });
  const duration = Number(process.env.EMBERWING_BENCH_SECONDS || 24);
  const started = Date.now(), end = started+duration*1000;
  let shot = 0, dodge;
  while (Date.now()<end) {
    const state = await page.evaluate(() => globalThis.emberwing.snapshot());
    if (state.mode !== "playing") break;
    const nextDodge=["w","d","s","a"][Math.floor((Date.now()-started)/750)%4];
    if (nextDodge!==dodge) {
      if (dodge) await page.keyboard.up(dodge);
      dodge=nextDodge; await page.keyboard.down(dodge);
    }
    const targets = state.targets.filter(t=>Math.abs(t.x)<0.85&&Math.abs(t.y)<0.65&&t.depth>8);
    if (targets.length) {
      await page.mouse.down();
      for (const target of targets.slice(0,4)) {
        await page.mouse.move((target.x+1)*720,(1-target.y)*450);
        await page.waitForTimeout(140);
      }
      await page.mouse.up();
      if (shot++%3===0) { await page.mouse.down({button:"right"}); await page.waitForTimeout(220); await page.mouse.up({button:"right"}); }
    }
    await page.waitForTimeout(150);
  }
  const result = await page.evaluate(() => ({samples:globalThis.emberwingSamples,state:globalThis.emberwing.snapshot()}));
  if (!result.samples.length) throw new Error("No playing frames were captured");
  const percentile = (key,p) => { const v=result.samples.map(s=>s[key]).sort((a,b)=>a-b);return Number(v[Math.floor((v.length-1)*p)].toFixed(3)); };
  const report = {
    browser:browser.version(),backend:metal?"Metal":"SwiftShader",viewport:"1440×900 @1x",
    encounter:new URL(url).searchParams.get("encounter") || "flight",
    frames:result.samples.length,requested_seconds:duration,measured_seconds:Number((result.samples.reduce((sum,s)=>sum+s.frame_ms,0)/1000).toFixed(2)),
    frame_ms:{p50:percentile("frame_ms",.5),p95:percentile("frame_ms",.95)},
    render_cpu_ms:{p50:percentile("render_cpu_ms",.5),p95:percentile("render_cpu_ms",.95)},
    peak_draw_calls:percentile("draws",1),peak_triangles:percentile("triangles",1),
    peak_enemies:percentile("enemies",1),peak_fireballs:percentile("balls",1),peak_bowls:percentile("bowls",1),
    peak_enemy_shots:percentile("shots",1),peak_rocks:percentile("rocks",1),peak_beams:percentile("beams",1),
    mode:result.state.mode,hp:result.state.hp,boss_hp:result.state.boss_hp,kills:result.state.kills,score:result.state.score,
    note:"CPU is draw-command construction + GPU submission; frame interval includes display pacing, not isolated GPU time.",
  };
  console.log(JSON.stringify(report,null,2));
} finally { await browser.close(); }
