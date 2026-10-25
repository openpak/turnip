# Notes: turnip

## Design

It is Mesa main at a pinned commit plus the fixes from community Turnip forks that are not
upstream yet. Download the zip from Releases and install it in Harbor (GPU driver manager),
globally or per game.

## What is in it

| Patch | From | Affects |
|---|---|---|
| `a8xx-cube-coord-sanitize.patch` | StevenMXZ | A8xx only (cube map hang quirk) |
| `a8xx-kgsl-ib-vbo-alias.patch` | StevenMXZ | A8xx only (IB free hang) |
| `8g2_ui_glitch.patch` | StevenMXZ | Adreno X1-85 UBWC hint |

Checked and left out:

- KGSL sync-merge and zero-timeout-poll fixes: already in Mesa main.
- Mesa MR 39751 (KGSL timelines): draft, needs a KGSL kernel with timeline ioctls (not 4.19).
- Forced sysmem rendering, D32S8 early-Z revert: behaviour hacks, not fixes.
- whitebelyash `turnip/gen8` stack: A8xx bring-up, does not apply to Mesa main.
- MrPurple and GameHub Rutabaga builds: binary only, no source to merge.

On A6xx (e.g. Adreno 650, ROG Phone 3) the build is effectively plain Mesa main.

## Licence and provenance

Build scripts and patches: GPL-3.0 (patches and NDK fixes come from
[StevenMXZ/freedreno_turnip-CI](https://github.com/StevenMXZ/freedreno_turnip-CI)).
The driver itself is Mesa (MIT).
