import {test} from 'node:test';
import assert from 'node:assert/strict';
import {gamepadConnectionStatus,gamepadGuide} from '../assets/hunter-gamepad-ui.mjs';

test('connection help distinguishes missing devices, browser focus, API failure and neutral gating',()=>{
  const waiting={connected:false,supported:false,ready:false};
  assert.match(gamepadConnectionStatus(waiting,'ready'),/未検出/);
  assert.match(gamepadConnectionStatus(waiting,'unfocused'),/クリック/);
  assert.match(gamepadConnectionStatus(waiting,'unavailable'),/非対応/);
  assert.match(gamepadConnectionStatus(waiting,'denied'),/許可/);
  assert.match(gamepadConnectionStatus(waiting,'error'),/失敗/);
  assert.match(gamepadConnectionStatus({...waiting,connected:true},'ready'),/標準配置/);
  assert.match(gamepadConnectionStatus({...waiting,connected:true,supported:true},'ready'),/離して/);
  assert.match(gamepadConnectionStatus({connected:true,supported:true,ready:true},'ready'),/接続/);
});

test('the connection guide is accessible before any gamepad has been detected',()=>{
  assert.doesNotMatch(gamepadGuide,/<details[^>]*\bhidden\b/);
  assert.match(gamepadGuide,/gamepad-connection/);
});
