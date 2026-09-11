/** Game-owned constraints shared by the 2D editor and its headless tools. */
export const profile = {
  game: 'flappy_bird',
  fields: {
    bird: ['x', 'y', 'width', 'height', 'color', 'name'],
    ground: ['y', 'height', 'color', 'name'],
  },
  validate(data) {
    if (data.width !== 320 || data.height !== 240 || data.objects.length !== 2)
      throw Error('Flappy Bird uses a 320 × 240 screen with one bird and one ground');
    const bird = data.objects.find((o) => o.id === 'bird' && o.kind === 'bird');
    const ground = data.objects.find((o) => o.id === 'ground' && o.kind === 'ground');
    if (
      !bird ||
      !ground ||
      ground.x !== 0 ||
      ground.width !== data.width ||
      ground.y < 160 ||
      ground.y > 239 ||
      ground.y + ground.height !== data.height
    )
      throw Error('Ground must span the bottom of the screen (Y 160–239)');
    if (
      bird.width > 64 ||
      bird.height > 64 ||
      bird.x < 0 ||
      bird.y < 0 ||
      bird.x + bird.width > data.width ||
      bird.y + bird.height > ground.y
    )
      throw Error('Bird must fit above the ground (size ≤ 64 px)');
  },
  edit(object, changes, data) {
    if (object.kind !== 'ground') return changes;
    if (
      changes.y !== undefined &&
      changes.height !== undefined &&
      changes.y + changes.height !== data.height
    )
      throw Error('Ground height conflicts with Y');
    if (changes.y !== undefined) return { ...changes, height: data.height - changes.y };
    if (changes.height !== undefined) return { ...changes, y: data.height - changes.height };
    return changes;
  },
};
