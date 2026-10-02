///|
/// Browser visual review uses the same fixtures as CPU captures.
extern "js" fn preview_request_name() -> String =
  #| () => globalThis.location ? new URLSearchParams(globalThis.location.search).get('preview') ?? '' : ''
