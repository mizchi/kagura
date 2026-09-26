///|
/// Why a meshoptimizer stream could not be decoded. The C decoder rejects
/// the same streams, returning -1 for a bad header or version, -2 for
/// data that runs out (it also reports an invalid channel mode as -2, which
/// is `InvalidHeader` here) and -3 for unread trailing data.
pub(all) suberror MeshoptError {
  InvalidArgument(String)
  InvalidHeader(String)
  UnexpectedEnd(String)
  TrailingData(String)
}

///|
pub impl Show for MeshoptError with fn output(self, logger) {
  let (kind, detail) = match self {
    InvalidArgument(s) => ("invalid argument", s)
    InvalidHeader(s) => ("invalid header", s)
    UnexpectedEnd(s) => ("unexpected end", s)
    TrailingData(s) => ("trailing data", s)
  }
  logger.write_string("meshopt: \{kind}: \{detail}")
}

///|
pub extend MeshoptError with Show::{to_string, output}
