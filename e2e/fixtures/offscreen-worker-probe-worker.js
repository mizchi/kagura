// Stands in for a blocking wasm guest: parks on a shared counter and renders
// on every wake, using only synchronous calls.
//
// The point is what happens to this thread's own event loop while it is parked.
// It registers a worker-side `requestAnimationFrame` first; if the loop were
// free that would fire ~60x/sec. It never does, which is why the frame clock
// has to come from another thread.

self.onmessage = async (event) => {
  const message = event.data;
  if (message?.type !== "init") return;

  const control = new Int32Array(message.control);
  const canvas2d = message.canvas2d;
  const canvasGpu = message.canvasGpu;
  const durationMs = message.durationMs ?? 600;

  const caps = {
    hasWorkerRaf: typeof self.requestAnimationFrame === "function",
    hasWebGPU: typeof navigator !== "undefined" && navigator.gpu != null,
    isOffscreen: typeof OffscreenCanvas !== "undefined" && canvas2d instanceof OffscreenCanvas,
  };

  let workerRafFired = 0;
  if (caps.hasWorkerRaf) {
    const tick = () => {
      workerRafFired += 1;
      self.requestAnimationFrame(tick);
    };
    self.requestAnimationFrame(tick);
  }

  const ctx2d = canvas2d.getContext("2d");

  // WebGPU acquisition is Promise-based, so it has to finish before this thread
  // starts blocking: once parked in Atomics.wait no microtask can run. Frame
  // rendering afterwards is entirely synchronous, which is what makes it
  // reachable from a blocked thread at all.
  let gpu = null;
  if (caps.hasWebGPU) {
    try {
      const adapter = await navigator.gpu.requestAdapter();
      if (adapter != null) {
        const device = await adapter.requestDevice();
        const context = canvasGpu.getContext("webgpu");
        context.configure({
          device,
          format: navigator.gpu.getPreferredCanvasFormat(),
          alphaMode: "opaque",
        });
        gpu = { device, context };
      }
      caps.gpuAdapter = adapter != null;
    } catch (error) {
      caps.gpuError = String(error?.message ?? error);
    }
  }

  // Snapshot the worker-rAF count as we enter the blocking loop. Anything it
  // fired earlier happened during the awaited WebGPU setup, when this thread
  // was still yielding; the claim under test is only about the blocked window.
  const rafBeforeBlock = workerRafFired;

  let draws2d = 0;
  let drawsGpu = 0;
  let gpuError = null;
  const drawTimes = [];
  const startedAt = Date.now();
  while (Date.now() - startedAt < durationMs) {
    // Wait on the value we just read, so a frame landing between the load and
    // the wait returns immediately instead of being missed.
    const seen = Atomics.load(control, 0);
    Atomics.wait(control, 0, seen, 200);

    drawTimes.push(performance.now());
    ctx2d.fillStyle = "#20c060";
    ctx2d.fillRect(0, 0, canvas2d.width, canvas2d.height);
    draws2d += 1;

    if (gpu != null && gpuError == null) {
      try {
        const view = gpu.context.getCurrentTexture().createView();
        const encoder = gpu.device.createCommandEncoder();
        encoder
          .beginRenderPass({
            colorAttachments: [
              {
                view,
                loadOp: "clear",
                storeOp: "store",
                clearValue: { r: 0.13, g: 0.75, b: 0.38, a: 1 },
              },
            ],
          })
          .end();
        gpu.device.queue.submit([encoder.finish()]);
        drawsGpu += 1;
      } catch (error) {
        gpuError = String(error?.message ?? error);
      }
    }

    Atomics.store(control, 1, draws2d);
  }

  // Read our own bitmap back rather than trusting a screenshot: the repo's VRT
  // already gates on an in-page readback for the same reason (headless Linux
  // canvas screenshots come back transparent).
  const data = ctx2d.getImageData(0, 0, canvas2d.width, canvas2d.height).data;
  let nonTransparent = 0;
  let greenish = 0;
  for (let i = 0; i < data.length; i += 4) {
    if (data[i + 3] > 0) nonTransparent += 1;
    if (data[i + 1] > data[i] && data[i + 1] > data[i + 2]) greenish += 1;
  }
  const pixels = data.length / 4;

  // Same summary shape the page computes for the main thread, so the two frame
  // rates are directly comparable.
  const intervals = [];
  for (let i = 1; i < drawTimes.length; i++) intervals.push(drawTimes[i] - drawTimes[i - 1]);
  intervals.sort((a, b) => a - b);
  const spanMs = drawTimes.length > 1 ? drawTimes.at(-1) - drawTimes[0] : 0;
  const at = (p) => intervals[Math.min(intervals.length - 1, Math.floor(intervals.length * p))];
  const worker = {
    frames: drawTimes.length,
    elapsedMs: Math.round(spanMs),
    fps: intervals.length > 0 ? +(intervals.length / (spanMs / 1000)).toFixed(1) : 0,
    p50IntervalMs: intervals.length > 0 ? +at(0.5).toFixed(2) : 0,
    p95IntervalMs: intervals.length > 0 ? +at(0.95).toFixed(2) : 0,
  };

  self.postMessage({
    type: "done",
    caps,
    workerRafFired,
    rafBeforeBlock,
    rafDuringBlock: workerRafFired - rafBeforeBlock,
    blockedMs: Date.now() - startedAt,
    draws2d,
    drawsGpu,
    gpuError,
    worker,
    readback: {
      nonTransparentRatio: nonTransparent / pixels,
      greenRatio: greenish / pixels,
    },
  });
};
