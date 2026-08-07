///|
pub enum AsyncImageStatus {
  Pending
  Loading
  Succeeded
  Failed
} derive(Debug)

///|
pub impl Show for AsyncImageStatus with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub fn AsyncImageStatus::to_int(self : AsyncImageStatus) -> Int {
  match self {
    AsyncImageStatus::Pending => 0
    AsyncImageStatus::Loading => 1
    AsyncImageStatus::Succeeded => 2
    AsyncImageStatus::Failed => 3
  }
}

///|
pub struct AsyncImageRequest {
  id : Int
  key : @atlas.AssetKey
  url : String
  mut status : AsyncImageStatus
  mut image_spec : @atlas.ImageSpec?
} derive(Debug)

///|
pub impl Show for AsyncImageRequest with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub struct AsyncImageProgress {
  total : Int
  pending : Int
  loading : Int
  succeeded : Int
  failed : Int
} derive(Debug)

///|
pub impl Show for AsyncImageProgress with fn output(self, logger) {
  logger.write_object(Repr(self))
}

///|
pub struct AsyncImageLoader {
  mut next_id : Int
  requests : Map[Int, AsyncImageRequest]
  mut pending_ids : Array[Int]
  mut completed_ids : Array[Int]
  fetch_image_fn : (String, (@atlas.ImageSpec?) -> Unit) -> Unit
}

///|
pub fn AsyncImageLoader::new(
  fetch_image_fn? : (String, (@atlas.ImageSpec?) -> Unit) -> Unit = @atlas.fetch_image,
) -> AsyncImageLoader {
  {
    next_id: 1,
    requests: Map([]),
    pending_ids: [],
    completed_ids: [],
    fetch_image_fn,
  }
}

///|
pub fn AsyncImageLoader::enqueue(
  self : AsyncImageLoader,
  key : @atlas.AssetKey,
  url : String,
) -> Int {
  let id = self.next_id
  self.next_id = self.next_id + 1
  self.requests.set(id, {
    id,
    key,
    url,
    status: AsyncImageStatus::Pending,
    image_spec: None,
  })
  self.pending_ids.push(id)
  id
}

///|
pub fn AsyncImageLoader::start_pending(self : AsyncImageLoader) -> Int {
  let pending = self.pending_ids
  self.pending_ids = []
  let mut started = 0
  for id in pending {
    match self.requests.get(id) {
      Some(req) =>
        match req.status {
          AsyncImageStatus::Pending => {
            req.status = AsyncImageStatus::Loading
            started = started + 1
            let url = req.url
            (self.fetch_image_fn)(url, fn(spec_opt) {
              match self.requests.get(id) {
                Some(done_req) => {
                  done_req.image_spec = spec_opt
                  done_req.status = match spec_opt {
                    Some(_) => AsyncImageStatus::Succeeded
                    None => AsyncImageStatus::Failed
                  }
                  self.completed_ids.push(id)
                }
                None => ()
              }
            })
          }
          _ => ()
        }
      None => ()
    }
  }
  started
}

///|
pub fn AsyncImageLoader::request(
  self : AsyncImageLoader,
  id : Int,
) -> AsyncImageRequest? {
  self.requests.get(id)
}

///|
pub fn AsyncImageLoader::drain_completed(self : AsyncImageLoader) -> Array[Int] {
  let done = self.completed_ids
  self.completed_ids = []
  done
}

///|
pub fn AsyncImageLoader::progress(
  self : AsyncImageLoader,
) -> AsyncImageProgress {
  let mut pending = 0
  let mut loading = 0
  let mut succeeded = 0
  let mut failed = 0
  self.requests.each(fn(_id, req) {
    match req.status {
      AsyncImageStatus::Pending => pending = pending + 1
      AsyncImageStatus::Loading => loading = loading + 1
      AsyncImageStatus::Succeeded => succeeded = succeeded + 1
      AsyncImageStatus::Failed => failed = failed + 1
    }
  })
  {
    total: pending + loading + succeeded + failed,
    pending,
    loading,
    succeeded,
    failed,
  }
}

///|
pub fn AsyncImageLoader::commit_image(
  self : AsyncImageLoader,
  id : Int,
  repo : @atlas.SimpleImageRepository,
) -> @gfx.ImageHandle? {
  match self.requests.get(id) {
    Some(req) =>
      match (req.status, req.image_spec) {
        (AsyncImageStatus::Succeeded, Some(spec)) =>
          match repo.get_image(req.key) {
            Some(handle) =>
              match @atlas.update_image_spec(repo, req.key, spec) {
                Some(updated) => Some(updated)
                None => Some(handle)
              }
            None => Some(repo.create_image(req.key, spec)) catch { _ => None }
          }
        _ => None
      }
    None => None
  }
}

///|
pub extend AsyncImageStatus with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend AsyncImageStatus with Show::{to_string, output}

///|
pub extend AsyncImageRequest with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend AsyncImageRequest with Show::{to_string, output}

///|
pub extend AsyncImageProgress with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend AsyncImageProgress with Show::{to_string, output}
