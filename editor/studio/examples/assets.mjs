/** Only remap URLs under the runtime directory; never intercept another origin. */
export function assetURL(input, base, assets) {
  const root = new URL('.', base),
    url = new URL(input, base);
  if (url.origin !== root.origin || !url.pathname.startsWith(root.pathname)) return null;
  const path = decodeURIComponent(url.pathname.slice(root.pathname.length));
  return Object.hasOwn(assets, path) ? assets[path] : null;
}
