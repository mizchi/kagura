import {inspectJSON, inspectDocumentsJSON} from '../../assets/web/kagura-scene-flow.generated.js';

function decode(inspect, value) {
  const result = JSON.parse(inspect(JSON.stringify(value)));
  if (!result.ok) throw Error(result.error);
  const {ok, ...inspection} = result;
  return inspection;
}
/** Codec only: all analysis and diagram escaping are implemented in MoonBit. */
export const inspectSceneFlow = value => decode(inspectJSON, value);
export const inspectSceneDocuments = value => decode(inspectDocumentsJSON, value);
