// UI readiness precedes the first requestAnimationFrame, especially headless.
// GPU readback/shader tests require a fully submitted frame, not just loaded assets.
export async function waitForRenderer(page) {
  await page.waitForFunction(()=>{
    const gpu=globalThis.__kaguraWebRuntime?.webgpu;
    return gpu?._lastSubmittedDrawCount>0 && gpu._renderTargets?.has(900) && gpu._renderTargets?.has(901);
  });
}
