#!/bin/sh
set -eu
umask 077
sh "$(dirname "$0")/desktop/install.sh"
version=0.3.5
digest=e8c5321e50e4f46751861291f17105e4781cc787c905601f7ce462f1edb19c9a
case "$(uname -s)-$(uname -m)" in
  Linux-x86_64) target=linux-x64 ;;
  *) echo 'Crystal for Cube requires Linux x64.' >&2; exit 1 ;;
esac
cache="${XDG_CACHE_HOME:-$HOME/.cache}/cube-crystal"
runtime="$cache/$version-$target"
if [ -x "$runtime/opt/Crystal/Crystal" ] && [ -f "$runtime/.cube-sha256" ] && [ "$(cat "$runtime/.cube-sha256")" = "$digest" ]; then
  rm -f "$runtime/opt/Crystal/resources/app-update.yml"
  echo "Crystal $version is installed."
  exit 0
fi
command -v dpkg-deb >/dev/null 2>&1 || { echo 'dpkg-deb is required to extract the upstream package.' >&2; exit 1; }
mkdir -p "$cache"
stage=$(mktemp -d "$cache/.install-XXXXXX")
trap 'rm -rf "$stage"' EXIT HUP INT TERM
curl --fail --location --retry 3 --silent --show-error \
  "https://github.com/stravu/crystal/releases/download/v$version/Crystal-$version-linux-amd64.deb" \
  --output "$stage/runtime.deb"
actual=$(sha256sum "$stage/runtime.deb" | cut -d ' ' -f 1)
[ "$actual" = "$digest" ] || { echo 'Crystal archive checksum mismatch.' >&2; exit 1; }
mkdir "$stage/runtime"
dpkg-deb --extract "$stage/runtime.deb" "$stage/runtime"
rm -f "$stage/runtime/opt/Crystal/resources/app-update.yml"
[ -x "$stage/runtime/opt/Crystal/Crystal" ] || { echo 'Upstream Crystal executable was not found.' >&2; exit 1; }
printf '%s\n' "$digest" > "$stage/runtime/.cube-sha256"
rm -rf "$runtime"
mv "$stage/runtime" "$runtime"
echo "Installed Crystal $version ($target)."
