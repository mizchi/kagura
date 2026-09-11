import { compileProfile, profileCommands } from '../../../../editor/studio/scene/profile.mjs';
export const profile = {
  game: 'arena3d',
  title: 'Arena 3D',
  spawnHeight: 0.5,
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
      position: [0, 0.5, 5],
      scale: [1, 1, 1],
      fixedScale: true,
      color: 4508774,
    },
    item: {
      asset: 'primitive.sphere',
      position: [2, 0.3, 1],
      scale: [1, 1, 1],
      fixedScale: true,
      color: 16763955,
    },
    enemy: {
      asset: 'primitive.box',
      position: [-5, 0.5, -5],
      scale: [1, 1, 1],
      fixedScale: true,
      color: 15615027,
    },
    portal: {
      asset: 'primitive.box',
      position: [0, 0.5, 2],
      scale: [1, 1, 1],
      fixedScale: true,
      color: 5618687,
    },
  },
};
export const compileScene = (doc) => compileProfile(doc, profile);
export const sceneCommands = (tool, args, snapshot) =>
  profileCommands(tool, args, snapshot, profile);
