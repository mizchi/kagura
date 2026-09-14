/** Apply the JsonObjectPublisher protocol, retaining unchanged field identity. */
export function applyObjectPatch(previous, patch) {
  const value={...(patch.full ? null : previous),...patch.set};
  for (const key of patch.remove) delete value[key];
  return value;
}

/** Each render section owns a gate; include every input used by that section. */
export function createDependencyGate() {
  let previous=null;
  return dependencies => {
    if (previous && dependencies.length===previous.length && dependencies.every((value,i)=>Object.is(value,previous[i]))) return false;
    previous=dependencies;
    return true;
  };
}
