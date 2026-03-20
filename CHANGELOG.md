# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### Added

- Added high-level `@engine.run_game` and `@scene.run_game` helpers with `EngineGame` and `SceneGame` traits so simple examples can launch from state objects directly.

### Changed

- Renamed progression APIs to make intent explicit around XP accrual, level thresholds, weighted selection, loot rarity sampling, and loot stat scaling.
- Renamed `gameplay2d` pickup APIs to separate effect resolution from applying the resulting actor state changes.
- Renamed `interactable2d` APIs to use consistent parsing, blocking, interaction-frame, and anchor-selection terminology.
- Renamed `scene_manager` transition getters to describe transition progress and overlay alpha explicitly.
- Updated `examples/hacknslash_3d` and simple example entrypoints to follow the renamed APIs and high-level launch helpers.

### Internal

- Ignore `.DS_Store` in git.
