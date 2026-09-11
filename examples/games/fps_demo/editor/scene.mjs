import { compileProfile, profileCommands } from '../../../../editor/studio/scene/profile.mjs';
export const profile = {
  game: 'fps_demo',
  title: 'FPS Demo',
  spawnHeight: 1.7,
  components: {
    floor: {
      asset: 'primitive.box',
      position: [0, -0.125, 0],
      scale: [18, 0.25, 18],
      color: 6649958,
    },
    wall: {
      asset: 'primitive.box',
      position: [4, 1, 0],
      scale: [1, 2, 5],
      color: 5464690,
    },
    spawn: {
      asset: 'primitive.sphere',
      position: [0, 1.7, 5],
      scale: [1, 1, 1],
      fixedScale: true,
      color: 4508774,
    },
    target: {
      asset: 'primitive.sphere',
      position: [2, 1, 1],
      scale: [1, 1, 1],
      fixedScale: true,
      color: 16763955,
    },
    box: {
      asset: 'primitive.box',
      position: [-4, 0.5, 0],
      scale: [2, 1, 2],
      color: 11176021,
    },
  },
};
export const compileScene = (doc) => compileProfile(doc, profile);
export const sceneCommands = (tool, args, snapshot) =>
  profileCommands(tool, args, snapshot, profile);
