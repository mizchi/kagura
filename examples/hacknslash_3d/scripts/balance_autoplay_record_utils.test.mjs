import test from "node:test";
import assert from "node:assert/strict";

import {
  buildDuckdbAppendSql,
  buildDuckdbPath,
  buildHypothesisParquetPath,
  buildDuckdbSummarySql,
  buildParquetPath,
  sqlPath,
  timestampToExperimentId,
} from "./balance_autoplay_record_utils.mjs";

test("timestampToExperimentId removes separators", () => {
  assert.equal(
    timestampToExperimentId("2026-03-13T10:11:12.345Z"),
    "20260313T101112345Z",
  );
});

test("path builders use stable filenames", () => {
  assert.equal(
    buildParquetPath("/tmp/autoplay", "exp-001"),
    "/tmp/autoplay/exp-001.parquet",
  );
  assert.equal(
    buildDuckdbPath("/tmp/autoplay"),
    "/tmp/autoplay/autoplay_experiments.duckdb",
  );
  assert.equal(
    buildHypothesisParquetPath("/tmp/autoplay", "exp-001", "speedrun"),
    "/tmp/autoplay/exp-001-speedrun.parquet",
  );
});

test("duckdb sql escapes parquet paths and experiment ids", () => {
  const appendSql = buildDuckdbAppendSql("autoplay_experiments", "/tmp/it's.parquet");
  assert.match(appendSql, /it''s\.parquet/);
  assert.match(appendSql, /ADD COLUMN IF NOT EXISTS hypothesis_name VARCHAR/);
  assert.match(appendSql, /INSERT INTO autoplay_experiments BY NAME/);
  const summarySql = buildDuckdbSummarySql("autoplay_experiments", "exp'001");
  assert.match(summarySql, /exp''001/);
  assert.match(summarySql, /hypothesis_name/);
  assert.match(summarySql, /CAST\(loss AS DOUBLE\) AS loss/);
  assert.match(summarySql, /CAST\(equip_upgrades AS DOUBLE\) AS equip_upgrades/);
  assert.match(summarySql, /CAST\(learned_skill_count AS DOUBLE\) AS learned_skill_count/);
  assert.match(summarySql, /CAST\(player_speed AS DOUBLE\) AS player_speed/);
  assert.equal(sqlPath("a'b"), "a''b");
});
