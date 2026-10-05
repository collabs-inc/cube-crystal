#!/bin/sh
set -eu
umask 077
runtime=$1
script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
executable="$runtime/opt/Crystal/Crystal"
binding="$runtime/opt/Crystal/resources/app.asar.unpacked/node_modules/better-sqlite3/build/Release/better_sqlite3.node"
check_binding() {
  env -u NODE_OPTIONS ELECTRON_RUN_AS_NODE=1 "$executable" -e 'require(process.argv[1])' "$binding" >/dev/null 2>&1
}
if check_binding; then exit 0; fi
echo 'Rebuilding the pinned Crystal SQLite addon for this Linux libc (one compiler job).'
command -v g++ >/dev/null 2>&1 && command -v make >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1 || {
  echo 'Crystal SQLite compatibility needs g++, make and python3.' >&2; exit 1;
}
cache="${XDG_CACHE_HOME:-$HOME/.cache}/cube-crystal"
mkdir -p "$cache"
stage=$(mktemp -d "$cache/.native-XXXXXX")
trap 'rm -rf "$stage"' EXIT HUP INT TERM
mkdir "$stage/build"
cp "$script_dir/package.json" "$script_dir/package-lock.json" "$stage/build/"
npm ci --prefix "$stage/build" --ignore-scripts --no-audit --no-fund --cache "$cache/npm"
(
  cd "$stage/build/node_modules/better-sqlite3"
  node ../node-gyp/bin/node-gyp.js rebuild --release --target=37.6.0 --arch=x64 \
    --dist-url=https://electronjs.org/headers --jobs=1 --devdir "$cache/electron-headers"
)
cp "$stage/build/node_modules/better-sqlite3/build/Release/better_sqlite3.node" "$binding.cube-new"
mv "$binding.cube-new" "$binding"
check_binding || { echo 'Crystal SQLite addon is still incompatible with the host.' >&2; exit 1; }
printf '%s\n' 'better-sqlite3 11.10.0 rebuilt from the npm integrity-locked source for Electron 37.6.0 and host libc.' > "$runtime/.cube-native-compatibility"
