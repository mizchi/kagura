/** Playback state only; rendering and editor documents are independent. Time is seconds. */
export function createMotionPlayer(asset) {
  let clip = asset.clips[0],
    time = 0,
    playing = false,
    speed = 1,
    loop = true;
  const finite = (n) => {
    if (typeof n !== "number" || !Number.isFinite(n))
      throw Error("Expected finite time");
  };
  const snapshot = () => ({
    clip: clip.id,
    time,
    duration: clip.duration,
    fps: clip.fps,
    frame: Math.round(time * clip.fps),
    playing,
    speed,
    loop,
  });
  return Object.freeze({
    snapshot,
    selectClip(id) {
      const next = asset.clips.find((c) => c.id === id);
      if (!next) throw Error("Unknown motion clip");
      clip = next;
      time = 0;
      playing = false;
    },
    play() {
      if (time >= clip.duration) time = 0;
      playing = true;
    },
    pause() {
      playing = false;
    },
    seek(value) {
      finite(value);
      time = Math.max(0, Math.min(clip.duration, value));
      playing = false;
    },
    step(direction) {
      if (![-1, 1].includes(direction)) throw Error("Step must be -1 or 1");
      time = Math.max(
        0,
        Math.min(
          clip.duration,
          (Math.round(time * clip.fps) + direction) / clip.fps,
        ),
      );
      playing = false;
    },
    setSpeed(value) {
      finite(value);
      if (value < 0.1 || value > 4) throw Error("Speed must be 0.1..4");
      speed = value;
    },
    setLoop(value) {
      if (typeof value !== "boolean") throw Error("Loop must be boolean");
      loop = value;
    },
    tick(delta) {
      finite(delta);
      if (delta < 0) throw Error("Negative time delta");
      if (!playing) return;
      time += delta * speed;
      if (time >= clip.duration) {
        if (loop) time %= clip.duration;
        else {
          time = clip.duration;
          playing = false;
        }
      }
    },
  });
}
