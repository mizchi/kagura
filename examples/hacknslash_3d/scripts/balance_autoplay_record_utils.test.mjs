import test from "node:test";
import assert from "node:assert/strict";

import {
  buildDuckdbAppendSql,
  buildDuckdbPath,
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
});

test("duckdb sql escapes parquet paths and experiment ids", () => {
  const appendSql = buildDuckdbAppendSql("autoplay_experiments", "/tmp/it's.parquet");
  assert.match(appendSql, /it''s\.parquet/);
  const summarySql = buildDuckdbSummarySql("autoplay_experiments", "exp'001");
  assert.match(summarySql, /exp''001/);
  assert.match(summarySql, /CAST\(loss AS DOUBLE\) AS loss/);
  assert.match(summarySql, /CAST\(player_speed AS DOUBLE\) AS player_speed/);
  assert.equal(sqlPath("a'b"), "a''b");
});
