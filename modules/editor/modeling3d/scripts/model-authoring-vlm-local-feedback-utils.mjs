function normalizeIssueKind(issue) {
  return issue?.issue_kind ?? issue?.action_kind ?? null;
}

function findFollowup(review, sourceId, issueKind) {
  return (review?.manual_followups ?? []).find(
    (item) =>
      item?.source_id === sourceId &&
      (item?.issue_kind ?? null) === issueKind,
  ) ?? null;
}

function findVisualFinding(review, sourceId) {
  return (review?.visual_findings ?? []).find(
    (item) => item?.source_id === sourceId,
  ) ?? null;
}

function findTask(review, sourceId) {
  return (review?.source_task_queue ?? []).find(
    (item) => item?.source_id === sourceId,
  ) ?? null;
}

function currentSculptLayer(bundle, sourceId) {
  return (bundle?.current_document?.sculpt_layers ?? []).find(
    (layer) => layer?.id === sourceId,
  ) ?? null;
}

function stampModeMoonBitName(input) {
  switch ((input ?? "").toLowerCase()) {
    case "add":
      return "Add";
    case "subtract":
      return "Subtract";
    default:
      return "Add";
  }
}

function vec3MoonBit(input) {
  const [x = 0, y = 0, z = 0] = Array.isArray(input) ? input : [];
  return `@math3d.Vec3::new(${x}, ${y}, ${z})`;
}

export function buildStampReviewMarkdown({ targetFile, patchPayload, review }) {
  const lines = [
    "# Kagura Sculpt Stamp Review",
    "",
    `Target file: \`${targetFile ?? review?.target_file ?? "(unknown)"}\``,
    "",
  ];
  const stampIssues = (patchPayload?.manual_issue_details ?? []).filter(
    (issue) => normalizeIssueKind(issue) === "review_stamp_count",
  );
  if (stampIssues.length === 0) {
    lines.push("No sculpt stamp review issues.");
    lines.push("");
    return `${lines.join("\n")}\n`;
  }

  for (const issue of stampIssues) {
    const followup = findFollowup(review, issue.source_id, "review_stamp_count");
    const finding = findVisualFinding(review, issue.source_id);
    const task = findTask(review, issue.source_id);
    lines.push(`## ${issue.source_id}`);
    lines.push("");
    if (typeof issue.current_stamp_count === "number") {
      lines.push(`- Current stamps: \`${issue.current_stamp_count}\``);
    }
    if (typeof issue.imported_stamp_count === "number") {
      lines.push(`- Imported stamps: \`${issue.imported_stamp_count}\``);
    }
    if (typeof issue.review_hint === "string" && issue.review_hint.length > 0) {
      lines.push(`- Hint: ${issue.review_hint}`);
    }
    if (typeof followup?.next_step === "string" && followup.next_step.length > 0) {
      lines.push(`- Next step: ${followup.next_step}`);
    }
    if (typeof finding?.observation === "string" && finding.observation.length > 0) {
      lines.push(`- Visual finding: ${finding.observation}`);
    }
    if (typeof task?.summary_line === "string" && task.summary_line.length > 0) {
      lines.push(`- Task queue: ${task.summary_line}`);
    }
    const suggested = typeof issue.suggested_moonbit === "string"
      ? issue.suggested_moonbit.trim()
      : "";
    if (suggested.length > 0) {
      lines.push("");
      lines.push("```moonbit");
      lines.push(suggested);
      lines.push("```");
    }
    lines.push("");
  }

  return `${lines.join("\n")}\n`;
}

export function buildStampSyncScaffold({ targetFile, bundle }) {
  const lines = [
    "fn apply_imported_stamp_sync(doc : ModelDocument) -> ModelDocument {",
    "  let sculpt_layers = doc.sculpt_layers.copy()",
    "",
  ];
  const stampIssues = (bundle?.patch_payload?.manual_issue_details ?? []).filter(
    (issue) => normalizeIssueKind(issue) === "review_stamp_count",
  );
  if (stampIssues.length === 0) {
    lines.push("  doc");
    lines.push("}");
    lines.push("");
    lines.push("// No sculpt stamp sync issues.");
    return `${lines.join("\n")}\n`;
  }

  for (const issue of stampIssues) {
    const layer = currentSculptLayer(bundle, issue.source_id);
    const currentCount = typeof issue.current_stamp_count === "number"
      ? issue.current_stamp_count
      : layer?.stamps?.length ?? 0;
    const importedCount = typeof issue.imported_stamp_count === "number"
      ? issue.imported_stamp_count
      : currentCount;
    const delta = importedCount - currentCount;
    lines.push(`  // ${issue.source_id}: current ${currentCount}, imported ${importedCount}`);
    lines.push(`  // Target file: ${targetFile ?? bundle?.target_file ?? "(unknown)"}`);
    if (delta > 0) {
      lines.push(`  // TODO append ${delta} stamp(s) after inspecting Blender sculpt history.`);
    } else if (delta < 0) {
      lines.push(`  // TODO remove or mute ${Math.abs(delta)} stamp(s) after inspecting Blender sculpt history.`);
    } else {
      lines.push("  // TODO reconcile stamp metadata without changing stamp count.");
    }
    if (typeof issue.review_hint === "string" && issue.review_hint.length > 0) {
      lines.push(`  // Hint: ${issue.review_hint}`);
    }
    lines.push("  // Current stamps:");
    for (const stamp of layer?.stamps ?? []) {
      lines.push(
        `  // - ${stamp.id}: ${stampModeMoonBitName(stamp.mode)} center=${vec3MoonBit(stamp.center)} radius=${stamp.radius}`,
      );
    }
    lines.push(`  // let stamps = sculpt_layers[${bundle.current_document.sculpt_layers.findIndex((item) => item?.id === issue.source_id)}].stamps.copy()`);
    if (delta > 0) {
      const startIndex = currentCount;
      for (let i = 0; i < delta; i += 1) {
        lines.push("  // stamps.push({");
        lines.push(`  //   id: "${issue.source_id}_todo_${startIndex + i}",`);
        lines.push("  //   mode: Add,");
        lines.push("  //   center: @math3d.Vec3::new(0.0, 0.0, 0.0),");
        lines.push("  //   radius: 0.1,");
        lines.push("  // })");
      }
    } else if (delta < 0) {
      lines.push("  // TODO choose which existing stamp(s) to remove or mute.");
    }
    lines.push(`  // sculpt_layers[${bundle.current_document.sculpt_layers.findIndex((item) => item?.id === issue.source_id)}] = { ..sculpt_layers[${bundle.current_document.sculpt_layers.findIndex((item) => item?.id === issue.source_id)}], stamps }`);
    lines.push("");
  }

  lines.push("  { ..doc, sculpt_layers }");
  lines.push("}");
  return `${lines.join("\n")}\n`;
}
