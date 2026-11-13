// Browser fixture for the FATHOM gates: GPU initialization and the lazy host
// must finish before a gate inventories controls or samples a first frame.
import {chromium} from '@playwright/test';
const launch=chromium.launch.bind(chromium);
const wrapped=new WeakSet();
function waitForGame(page){
  if(wrapped.has(page))return page;
  wrapped.add(page);
  const goto=page.goto.bind(page);
  page.goto=async(...args)=>{
    const result=await goto(...args);
    await page.waitForFunction(()=>typeof globalThis.fathom?.read==='function'&&globalThis.__kaguraGfx?.lastRenderCpuMs?.()>0);
    await page.evaluate(async()=>{
      await document.fonts.ready;
      const artwork=document.querySelector('.adventurer-art');
      const image=new Image();
      await new Promise((resolve,reject)=>{image.onload=resolve;image.onerror=()=>reject(Error('FATHOM party atlas did not load'));image.src=getComputedStyle(artwork).backgroundImage.slice(4,-1).replace(/^["']|["']$/g,'');});
      await new Promise(resolve=>requestAnimationFrame(()=>requestAnimationFrame(resolve)));
    });
    return result;
  };
  return page;
}
chromium.launch=async(options={})=>{
  const browser=await launch({...options,args:['--enable-unsafe-webgpu','--use-angle=swiftshader','--enable-unsafe-swiftshader',...(options.args??[])]});
  const newContext=browser.newContext.bind(browser),newPage=browser.newPage.bind(browser);
  browser.newContext=async(...args)=>{const context=await newContext(...args),open=context.newPage.bind(context);context.newPage=async(...options)=>waitForGame(await open(...options));return context;};
  browser.newPage=async(...args)=>waitForGame(await newPage(...args));
  return browser;
};
