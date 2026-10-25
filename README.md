# Turnip Driver Builds

OpenPak's Turnip Driver Builds.

| | |
| --- | --- |
| Console | Android |
| Kind | Driver builds |
| Download | [Releases](https://github.com/openpak/turnip/releases) (`vX.Y.Z` tags) |
| Based on | [Mesa](https://gitlab.freedesktop.org/mesa/mesa) (MIT) |
| Used by | Harbor (GPU driver manager) |
| Licence | GPL-3.0-only, see [LICENSE](LICENSE) |

## What it does

- Mesa Turnip (Vulkan for Qualcomm Adreno) packaged for Harbor's custom driver loader.
- Builds Mesa main at a pinned commit, plus fixes from community Turnip forks that are not upstream yet.
- Applies three patches on top of Mesa:

| Patch | From | Affects |
|---|---|---|
| `a8xx-cube-coord-sanitize.patch` | StevenMXZ | A8xx only (cube map hang quirk) |
| `a8xx-kgsl-ib-vbo-alias.patch` | StevenMXZ | A8xx only (IB free hang) |
| `8g2_ui_glitch.patch` | StevenMXZ | Adreno X1-85 UBWC hint |

## Build

```sh
./build.sh            # pinned Mesa commit
./build.sh <commit>   # another Mesa commit
```

Output is `OpenPak-Turnip-<rev>.zip`. Full requirements and environment: [deploy](docs/deploy.md).

## Docs

- [Protocol](docs/protocol.md)
- [Evidence](docs/evidence.md)
- [Deploy](docs/deploy.md)
- [Notes](docs/notes.md)

## Licence

Build scripts and patches: GPL-3.0-only, see [LICENSE](LICENSE). The driver itself is Mesa (MIT).
