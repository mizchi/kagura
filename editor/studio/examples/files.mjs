/** Keep copied Moon metadata out of Studio's package discovery. Logical project paths stay unchanged. */
export function packagedPath(path) {
  return path
    .split('/')
    .map((part) =>
      part.startsWith('_') || /^moon\.(?:pkg|mod)(?:\.json)?$|^moon\.work$/.test(part)
        ? '_' + part
        : part,
    )
    .join('/');
}
