import { expect, test } from "@playwright/test";

type ImageFetchInfo = {
  url: string;
  status: number;
  ok: boolean;
  contentType: string | null;
};

type FetchImageResult = {
  status: string;
  frames: number;
  hasWebGPU: boolean;
  imageFetches: ImageFetchInfo[];
  error?: string;
};

const waitForResult = async (page: import("@playwright/test").Page) => {
  await page.waitForFunction(
    () => Boolean((window as { __fetchImageResult?: FetchImageResult }).__fetchImageResult),
    null,
    { timeout: 10_000 },
  );
  return await page.evaluate(() => {
    return (window as { __fetchImageResult?: FetchImageResult }).__fetchImageResult!;
  });
};

test("fetch_image loads image via HTTP and starts engine", async ({ page }) => {
  await page.goto("/e2e/fixtures/fetch_image.html");
  const result = await waitForResult(page);

  expect(result.status).toBe("ok");
  expect(result.frames).toBeGreaterThan(0);

  // Verify image was fetched successfully
  expect(result.imageFetches.length).toBeGreaterThan(0);
  const imgFetch = result.imageFetches[0];
  expect(imgFetch.url).toContain("sample.png");
  expect(imgFetch.ok).toBe(true);
  expect(imgFetch.status).toBe(200);
  expect(imgFetch.contentType).toBe("image/png");
});

test("fetch_image network request delivers valid PNG bytes", async ({ page }) => {
  // Use Playwright request interception to capture raw response
  let responseBody: Buffer | null = null;
  page.on("response", async (resp) => {
    if (resp.url().includes("sample.png")) {
      responseBody = await resp.body();
    }
  });

  await page.goto("/e2e/fixtures/fetch_image.html");
  const result = await waitForResult(page);
  expect(result.status).toBe("ok");

  // Verify response body is a valid PNG (magic bytes: 89 50 4E 47)
  expect(responseBody).not.toBeNull();
  const png = responseBody!;
  expect(png.length).toBeGreaterThan(8);
  expect(png[0]).toBe(0x89);
  expect(png[1]).toBe(0x50); // P
  expect(png[2]).toBe(0x4e); // N
  expect(png[3]).toBe(0x47); // G
});

test("fetch_image canvas has non-zero pixels when WebGPU available", async ({ page }) => {
  await page.goto("/e2e/fixtures/fetch_image.html");
  const result = await waitForResult(page);

  if (!result.hasWebGPU) {
    test.skip(true, "WebGPU not available in this environment");
    return;
  }

  // Wait for enough frames for WebGPU device init + texture upload + render
  await page.waitForFunction(
    () => {
      const r = (window as { __fetchImageResult?: FetchImageResult }).__fetchImageResult;
      return r && r.frames >= 10;
    },
    null,
    { timeout: 10_000 },
  );

  // Check if WebGPU device actually initialized (navigator.gpu may exist but device may fail)
  const hasDevice = await page.evaluate(() => {
    const rt = (globalThis as { __kaguraWebRuntime?: { webgpu?: { device?: unknown } } }).__kaguraWebRuntime;
    return !!rt?.webgpu?.device;
  });
  if (!hasDevice) {
    test.skip(true, "WebGPU device not available (adapter/device init failed)");
    return;
  }

  // Read pixels from the canvas to verify non-zero content
  const hasContent = await page.evaluate(() => {
    const canvas = document.querySelector("#app") as HTMLCanvasElement | null;
    if (!canvas) return false;

    const offscreen = document.createElement("canvas");
    offscreen.width = canvas.width;
    offscreen.height = canvas.height;
    const ctx2d = offscreen.getContext("2d");
    if (!ctx2d) return false;

    ctx2d.drawImage(canvas, 0, 0);
    const imageData = ctx2d.getImageData(0, 0, offscreen.width, offscreen.height);
    const pixels = imageData.data;

    for (let i = 0; i < pixels.length; i += 4) {
      if (pixels[i] > 0 || pixels[i + 1] > 0 || pixels[i + 2] > 0) {
        return true;
      }
    }
    return false;
  });

  expect(hasContent).toBe(true);
});
