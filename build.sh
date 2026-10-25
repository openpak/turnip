#!/usr/bin/env bash
# OpenPak Turnip: Mesa main + the fork fixes that are not upstream yet, packaged for adrenotools.
# Usage: ./build.sh [mesa-commit]   (default: the pinned MESA_COMMIT below)
# MESA_REMOTE overrides the Mesa git URL (e.g. a local clone).
# Needs: git, python3, ninja, bison, flex, glslangValidator, zip, Android NDK r28+ (ANDROID_NDK).
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
MESA_COMMIT="${1:-02f13375231bf0a9ed20b09cb21171351053be52}"
MESA_REMOTE="${MESA_REMOTE:-https://gitlab.freedesktop.org/mesa/mesa.git}"
ANDROID_NDK="${ANDROID_NDK:-$HOME/Android/Sdk/ndk/28.2.13676358}"
NDK="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin"
work="$here/work" out="$here/out"
export TMPDIR="$work/tmp"
mkdir -p "$TMPDIR"

[ -x "$work/venv/bin/meson" ] || { python3 -m venv "$work/venv"; "$work/venv/bin/pip" -q install meson mako pyyaml packaging; }
export PATH="$work/venv/bin:$PATH"

if [ ! -d "$work/mesa/.git" ]; then
	git init -q "$work/mesa"
	git -C "$work/mesa" remote add origin "$MESA_REMOTE"
fi
cd "$work/mesa"
git fetch -q --depth=1 origin "$MESA_COMMIT"
git checkout -q --force --detach FETCH_HEAD
git clean -qfdx

for p in "$here"/patches/*.patch; do
	echo "apply $(basename "$p")"; git apply "$p"
done

# NDK fixes (from StevenMXZ/freedreno_turnip-CI)
sed -i 's/typedef const native_handle_t\* buffer_handle_t;/typedef void* buffer_handle_t;/g' include/android_stub/cutils/native_handle.h
sed -i 's/, hnd->handle/, (void *)hnd->handle/g' src/util/u_gralloc/u_gralloc_fallback.c
sed -i -E 's/([a-z_]+)->handle->/((const native_handle_t *)\1->handle)->/g' src/vulkan/runtime/vk_android.c
sed -i "/-Werror=gnu-empty-initializer/d" meson.build

cat > "$TMPDIR/cross.txt" <<EOF
[binaries]
ar = '$NDK/llvm-ar'
c = ['$NDK/aarch64-linux-android35-clang']
cpp = ['$NDK/aarch64-linux-android35-clang++', '-fno-exceptions', '-fno-unwind-tables', '-fno-asynchronous-unwind-tables', '--start-no-unused-arguments', '-static-libstdc++', '--end-no-unused-arguments']
c_ld = '$NDK/ld.lld'
cpp_ld = '$NDK/ld.lld'
strip = '$NDK/llvm-strip'
pkg-config = ['env', 'PKG_CONFIG_LIBDIR=$NDK/pkg-config', '/usr/bin/pkg-config']
[host_machine]
system = 'android'
cpu_family = 'aarch64'
cpu = 'armv8'
endian = 'little'
EOF

export CFLAGS="-Wno-error -Wno-deprecated-declarations -Wno-incompatible-pointer-types-discards-qualifiers -Wno-incompatible-pointer-types"
export CXXFLAGS="$CFLAGS"
rm -rf build "$out"
meson setup build --cross-file "$TMPDIR/cross.txt" --prefix "$out" \
	-Dbuildtype=release -Dstrip=true -Dplatforms=android -Dvideo-codecs= \
	-Dplatform-sdk-version=35 -Dandroid-stub=true -Dgallium-drivers= \
	-Dvulkan-drivers=freedreno -Dvulkan-beta=true -Dfreedreno-kmds=kgsl \
	-Degl=disabled -Dandroid-libbacktrace=disabled
ninja -C build install

rev="$(git rev-parse --short=10 HEAD)"
cd "$out/lib"
cat > meta.json <<EOF
{
  "schemaVersion": 1,
  "name": "OpenPak Turnip $rev",
  "description": "Mesa main $rev + fork fixes (StevenMXZ/whitebelyash) not yet upstream",
  "author": "tobagin",
  "packageVersion": "1",
  "vendor": "Mesa",
  "driverVersion": "Mesa-$rev",
  "minApi": 28,
  "libraryName": "libvulkan_freedreno.so"
}
EOF
zip -9 -q "$here/OpenPak-Turnip-$rev.zip" libvulkan_freedreno.so meta.json
rm -rf "$TMPDIR"
echo "built $here/OpenPak-Turnip-$rev.zip"
