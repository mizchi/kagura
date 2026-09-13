/** Known raw HID layouts only. Browser-provided standard mappings take priority.
 * The Mac PS5 layout follows Chromium's MapperDualSense / DpadFromAxis:
 * https://github.com/chromium/chromium/blob/main/device/gamepad/gamepad_standard_mappings_mac.mm
 * https://github.com/chromium/chromium/blob/main/device/gamepad/gamepad_standard_mappings.cc
 */
const victrixPs5Mac = 'victrix-pro-bfg-ps5-mac';
const buttonOrder = [1, 2, 0, 3, 4, 5, 6, 7, 8, 9, 10, 11, null, null, null, null, 12, 13];
const hatButtons = [[12], [12, 15], [15], [13, 15], [13], [13, 14], [14], [12, 14]];

const axis = value => Number.isFinite(value) ? Math.max(-1, Math.min(1, value)) : 0;
const button = source => ({
  pressed: !!source?.pressed,
  value: Number.isFinite(source?.value) ? Math.max(0, Math.min(1, source.value)) : 0,
});

/**
 * @param {import('./kagura-gamepad.js').PadSnapshot} pad
 * @returns {(import('./kagura-gamepad.js').PadSnapshot & {profile?:string}) | null}
 * Unknown layouts return null; raw objects and their arrays are never mutated.
 */
export function normalizeGamepad(pad) {
  if (pad.mapping === 'standard') return pad;
  if (pad.mapping !== '' ||
      !/\bVendor:\s*0e6f\s+Product:\s*0218\b/i.test(pad.id) ||
      pad.axes.length !== 10 || pad.buttons.length < 14) return null;

  const buttons = buttonOrder.map(index => button(index === null ? null : pad.buttons[index]));
  for (const [axisIndex, buttonIndex] of [[3, 6], [4, 7]]) {
    const value = Number.isFinite(pad.axes[axisIndex]) ? (axis(pad.axes[axisIndex]) + 1) / 2 : 0;
    buttons[buttonIndex] = {pressed: buttons[buttonIndex].pressed || buttons[buttonIndex].value >= .55 || value >= .55, value};
  }

  // HID hats encode eight directions as -1..1 and neutral as >1 (often 9/7).
  // Do not clamp the hat: 1 is up-left, while 9/7 means nothing is pressed.
  const hat = pad.axes[9];
  if (Number.isFinite(hat) && hat >= -1 && hat <= 1) {
    const position = (hat + 1) * 3.5;
    const direction = Math.round(position);
    // A startup value of zero is unspecified, not a diagonal press.
    if (Math.abs(position - direction) < .1) {
      for (const index of hatButtons[direction]) buttons[index] = {pressed: true, value: 1};
    }
  }
  return {
    index: pad.index, id: pad.id, connected: pad.connected,
    mapping: 'standard', profile: victrixPs5Mac,
    axes: [0, 1, 2, 5].map(index => axis(pad.axes[index])), buttons,
  };
}
