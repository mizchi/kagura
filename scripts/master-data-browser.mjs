// Wait for the actual table editor before deterministic visual gates inspect it.
import { chromium } from "@playwright/test";
const launch = chromium.launch.bind(chromium),
  wrapped = new WeakSet();
function ready(page) {
  if (wrapped.has(page)) return page;
  wrapped.add(page);
  const goto = page.goto.bind(page);
  page.goto = async (...args) => {
    const result = await goto(...args);
    await page.waitForSelector("dialog.master-data-dialog[open]");
    await page.evaluate(() => document.fonts.ready);
    return result;
  };
  return page;
}
chromium.launch = async (...args) => {
  const browser = await launch(...args),
    open = browser.newPage.bind(browser),
    context = browser.newContext.bind(browser);
  browser.newPage = async (...args) => ready(await open(...args));
  browser.newContext = async (...args) => {
    const c = await context(...args),
      page = c.newPage.bind(c);
    c.newPage = async (...args) => ready(await page(...args));
    return c;
  };
  return browser;
};
