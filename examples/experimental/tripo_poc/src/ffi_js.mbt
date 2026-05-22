///|
/// HTTP POST request via curl. Returns response body as string.
extern "js" fn js_http_post(
  url : String,
  headers_json : String,
  body : String,
) -> String =
  #|(url, headersJson, body) => {
  #|  const { spawnSync } = require('child_process');
  #|  const h = JSON.parse(headersJson);
  #|  const args = ['-sS', '-X', 'POST', url];
  #|  for (const [k, v] of Object.entries(h)) { args.push('-H', `${k}: ${v}`); }
  #|  if (body) { args.push('-d', body); }
  #|  const r = spawnSync('curl', args, { encoding: 'utf-8', maxBuffer: 50*1024*1024 });
  #|  if (r.status !== 0) return 'ERROR: ' + (r.stderr || '');
  #|  return r.stdout || '';
  #|}

///|
/// HTTP GET request via curl. Returns response body as string.
extern "js" fn js_http_get(url : String, headers_json : String) -> String =
  #|(url, headersJson) => {
  #|  const { spawnSync } = require('child_process');
  #|  const h = JSON.parse(headersJson);
  #|  const args = ['-sS', url];
  #|  for (const [k, v] of Object.entries(h)) { args.push('-H', `${k}: ${v}`); }
  #|  const r = spawnSync('curl', args, { encoding: 'utf-8', maxBuffer: 50*1024*1024 });
  #|  if (r.status !== 0) return 'ERROR: ' + (r.stderr || '');
  #|  return r.stdout || '';
  #|}

///|
/// Download file via curl to a local path. Returns "OK" or "ERROR: ...".
extern "js" fn js_download_file(
  url : String,
  headers_json : String,
  path : String,
) -> String =
  #|(url, headersJson, path) => {
  #|  const { spawnSync } = require('child_process');
  #|  const h = JSON.parse(headersJson);
  #|  const args = ['-sS', '-L', '-o', path, url];
  #|  for (const [k, v] of Object.entries(h)) { args.push('-H', `${k}: ${v}`); }
  #|  const r = spawnSync('curl', args, { encoding: 'utf-8', maxBuffer: 50*1024*1024 });
  #|  if (r.status !== 0) return 'ERROR: ' + (r.stderr || '');
  #|  return 'OK';
  #|}

///|
/// Sleep for the specified number of seconds.
extern "js" fn js_sleep(seconds : Int) -> Unit =
  #|(seconds) => {
  #|  const { spawnSync } = require('child_process');
  #|  spawnSync('sleep', [String(seconds)]);
  #|}

///|
/// Get environment variable value.
extern "js" fn js_get_env(name : String) -> String =
  #|(name) => { return process.env[name] || ''; }
