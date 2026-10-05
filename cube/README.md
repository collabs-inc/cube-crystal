# Crystal for Cube

Install `https://github.com/collabs-inc/cube-crystal` from Cube Apps. This fork pins
Crystal v0.3.5 (`1e18e0bc981225f75b5226f82a300fa741970c6f`) and retains the original
MIT source and notices. The official x64 Debian release is verified using the
committed SHA-256, then extracted privately without a full app build or system install.
The actual Linux executable is `opt/Crystal/Crystal` (capital C).

The release's SQLite addon requires glibc 2.38. On older hosts, the installer
rebuilds only the exact `better-sqlite3` 11.10.0 addon against Electron 37.6.0
headers using one compiler job. npm source and build-tool dependencies are locked
with integrity hashes in `native/package-lock.json`; Electron header checksums
are verified by node-gyp. This compatibility path needs g++, make and python3.
It does not change the upstream JavaScript, SQLite API version, or system libc.

Crystal displays an upstream notice that it is becoming Nimbalyst. Choose
**Continue with Crystal** to use this pinned release. This integration does not
migrate data to a different service or app.

Database/configuration/worktree settings live in `~/.local/share/cube-crystal`;
other Electron storage lives in its `profile` subdirectory and private desktop
state in `bridge`. The release cache is `~/.cache/cube-crystal`. XDG paths are
honored; `CUBE_CRYSTAL_DATA_DIR` overrides the persistent root. Data survives
checkout replacement. HOME and installed Claude Code/Codex/Git authentication
locations stay unchanged. The integration never copies credential files.

First launch seeds analytics disabled with an empty telemetry key; existing
configuration is never overwritten. Extracted updater metadata is removed so
Cube owns runtime updates. Native Chromium sandboxing remains enabled.

The [shared desktop bridge](desktop/README.md) displays the native UI through
Cube's authenticated gate, with responsive scaling, keyboard/pointer input and
visible external-link forwarding. Its README records desktop limitations.

Validation: `node --test cube/desktop/*.test.mjs`, `node --check cube/start.mjs`,
`sh -n cube/install.sh`. Cloud verification uses the exact released Linux binary.
