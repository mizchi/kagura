/** Check compiler output before any minifier can erase the names used by this gate. */
export const inspectionMarkers = [
  /__kaguraScene/,
  /kaguraDebugAdapter/,
  /kaguraSceneRuntime/,
  /DebugState/,
  /SubjectBinding/,
  /Unknown inspection field/,
  /Inspection field is not writable/,
  /scene7resolve/,
];
export function assertInspectionArtifact(source, mode) {
  const found = inspectionMarkers.filter((pattern) => pattern.test(source));
  if (mode === 'debug') {
    if (found.length !== inspectionMarkers.length)
      throw Error(
        'Debug artifact lacks expected inspection markers: ' +
          inspectionMarkers.filter((p) => !p.test(source)),
      );
  } else if (mode === 'release') {
    if (found.length) throw Error('Inspection leaked into release artifact: ' + found.join(', '));
  } else throw Error('Invalid inspection artifact mode');
}
