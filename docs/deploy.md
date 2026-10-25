# Deploy: turnip

## Install

Download the zip from Releases and install it in Harbor (GPU driver manager),
globally or per game.

## Build

```sh
./build.sh            # pinned Mesa commit
./build.sh <commit>   # another Mesa commit
```

Needs git, python3, ninja, bison, flex, glslangValidator, zip and the Android NDK r28+
(`ANDROID_NDK`, default `~/Android/Sdk/ndk/28.2.13676358`). Output: `OpenPak-Turnip-<rev>.zip`.

## Environment

Read from `build.sh`:

| Variable | Default | Meaning |
| --- | --- | --- |
| `$1` (commit) | `02f13375231bf0a9ed20b09cb21171351053be52` | Mesa commit to build |
| `MESA_REMOTE` | `https://gitlab.freedesktop.org/mesa/mesa.git` | Mesa git URL (e.g. a local clone) |
| `ANDROID_NDK` | `$HOME/Android/Sdk/ndk/28.2.13676358` | Android NDK root |
| `JOBS` | `4` | ninja parallel jobs |

## Output

The zip holds `libvulkan_freedreno.so` and `meta.json` (`schemaVersion` 1, `minApi` 28,
`libraryName` `libvulkan_freedreno.so`). The build works in `work/` and writes `out/`; both are
git-ignored.
