import { createCheckPlan, runCheckPlan } from "./moon-check-plan.mjs";
try {
  const [group, target = "js", shard = "1/1", ...extra] = process.argv.slice(2);
  if (
    extra.length ||
    !["js", "native", "wasm", "wasm-gc", "llvm"].includes(target)
  )
    throw Error(
      "Usage: check-moon-modules.mjs workspace|examples|standalone|external [target] [shard]",
    );
  runCheckPlan(createCheckPlan(group, { target, shard }));
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}
