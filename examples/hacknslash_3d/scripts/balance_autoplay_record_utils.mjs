import { join } from "node:path";

export function sqlPath(path) {
  return path.replaceAll("'", "''");
}

export function timestampToExperimentId(timestamp) {
  return timestamp.replaceAll(":", "").replaceAll("-", "").replaceAll(".", "");
}

export function buildParquetPath(outDir, experimentId) {
  return join(outDir, `${experimentId}.parquet`);
}

export function buildDuckdbPath(outDir) {
  return join(outDir, "autoplay_experiments.duckdb");
}

export function buildDuckdbAppendSql(tableName, parquetPath) {
  const sqlParquetPath = sqlPath(parquetPath);
  return [
    `CREATE TABLE IF NOT EXISTS ${tableName} AS`,
    `SELECT * FROM read_parquet('${sqlParquetPath}') LIMIT 0;`,
    `INSERT INTO ${tableName}`,
    `SELECT * FROM read_parquet('${sqlParquetPath}');`,
  ].join("\n");
}

export function buildDuckdbSummarySql(tableName, experimentId) {
  return [
    "SELECT experiment_id, run_kind, generation,",
    "       CAST(loss AS DOUBLE) AS loss,",
    "       CAST(floors_cleared AS DOUBLE) AS floors_cleared,",
    "       CAST(total_damage AS DOUBLE) AS total_damage,",
    "       CAST(player_speed AS DOUBLE) AS player_speed,",
    "       CAST(spell_damage_mult AS DOUBLE) AS spell_damage_mult,",
    "       CAST(enemy_bolt_damage AS DOUBLE) AS enemy_bolt_damage,",
    "       CAST(ranged_shot_cooldown AS DOUBLE) AS ranged_shot_cooldown",
    `FROM ${tableName}`,
    `WHERE experiment_id = '${sqlPath(experimentId)}'`,
    "ORDER BY run_kind;",
  ].join("\n");
}
