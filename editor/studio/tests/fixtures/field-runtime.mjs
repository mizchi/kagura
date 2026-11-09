import { createRuntimeFieldSession } from "../../runtime/field-session.mjs";

export function fieldRuntime() {
  let revision = 0,
    paused = false,
    x = 3;
  return createRuntimeFieldSession({
    apiVersion: 1,
    game: "fixture",
    read: () => ({
      revision,
      paused,
      scope: "training",
      subjects: [
        {
          id: "player",
          name: "Player",
          fields: [
            {
              id: "x",
              label: "X",
              value: x,
              unit: "m",
              kind: "number",
              access: "runtime",
            },
          ],
        },
      ],
    }),
    pause(value) {
      paused = value;
      revision++;
    },
    edit(edit) {
      x = edit.value;
      revision++;
    },
  });
}
