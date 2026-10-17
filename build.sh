#!/bin/bash

set -o pipefail

rm -rf .repo/local_manifests
rm -rf {device,vendor,kernel,hardware}/nothing
rm -rf {device,hardware}/mediatek

# ── Config
ROM_BRANCH="Cinderella"
DEVICE="Pacman"
RELEASE="cp2a"
MANIFEST_URL="https://github.com/Miku-UI/manifesto.git"
LOCAL_MANIFEST_URL="https://github.com/sajjad85gh/local_manifests.git"

diag() { echo; echo "################ DIAG: $* ################"; }

# ── Init repo
repo init -u ${MANIFEST_URL} -b ${ROM_BRANCH} --git-lfs --no-clone-bundle

# ── Clone local_manifests
git clone ${LOCAL_MANIFEST_URL} -b main .repo/local_manifests

# ── Sync
/opt/crave/resync.sh

PATCHES=(
  "frameworks/native|7b7807349f7b66c61444e32e4a26b025932117d8|https://github.com/Nothing-2A/android_frameworks_native"
  "frameworks/base|71955520858075bfeb8b52009151ba20401f27e3|https://github.com/Nothing-2A/android_frameworks_base"
)
[ -d packages/apps/Aperture ] && PATCHES+=("packages/apps/Aperture|a4c34aa57ed56de60f29349a1e6d20cf8160ca15|https://github.com/Nothing-2A/android_packages_apps_Aperture")

for entry in "${PATCHES[@]}"; do
  IFS="|" read -r REPO_PATH COMMIT_SHA REMOTE_URL <<< "$entry"
  echo -e "\n[*] $COMMIT_SHA -> $REPO_PATH"
  [ -d "$REPO_PATH" ] || { echo "[!] $REPO_PATH doesn't exist"; exit 1; }
  PATCH_FILE=$(mktemp)
  curl -fsSL "$REMOTE_URL/commit/$COMMIT_SHA.patch" -o "$PATCH_FILE" || { echo "[!] download failed"; exit 1; }
  pushd "$REPO_PATH" > /dev/null
  if git apply --check -R "$PATCH_FILE" 2>/dev/null; then echo "[✔] was applied"
  elif git am -3 "$PATCH_FILE"; then echo "[✔] applied now"
  else git am --abort || true; echo "[!!!] CONFLICT: $COMMIT_SHA"; fi
  popd > /dev/null
done

# ── DIAGNOSTICS
diag "START"

diag "manifest revisions of key projects"
repo manifest 2>/dev/null | grep -E 'path="(device/nothing|vendor/nothing|kernel/nothing|hardware/nothing|hardware/mediatek|device/mediatek|vendor/miku)' | cut -c1-250

diag "vendor/miku layout"
ls vendor/miku vendor/miku/build vendor/miku/build/product vendor/miku/config 2>&1 | head -80

diag "miku_product.mk content"
cat -n vendor/miku/build/product/miku_product.mk 2>&1 | head -150

diag "existence check"
for p in vendor/miku/build/product/miku_product.mk vendor/miku/config/BoardConfigMiku.mk \
         vendor/miku/config/versioning.mk vendor/miku/config/overlay.mk \
         hardware/lineage hardware/lineage/compat hardware/lineage/interfaces lineage-sdk vendor/lineage \
         packages/apps/Aperture packages/apps/ParanoidGlyph packages/apps/GlyphAdapter; do
  [ -e "$p" ] && echo "[exists ] $p" || echo "[MISSING] $p"
done

diag "who includes Miku board/product configs"
grep -rn "BoardConfigMiku.mk\|versioning.mk\|overlay.mk\|miku_product.mk" build vendor/miku --include=*.mk --include=*.bp 2>/dev/null | cut -c1-220 | head -30

diag "device tree product files and inherits"
ls device/nothing/Aerodactyl/*.mk
cat -n device/nothing/Aerodactyl/miku_Pacman.mk 2>&1 | head -60
grep -n "inherit-product" device/nothing/Aerodactyl/device-common.mk | cut -c1-200

diag "remaining Lineage references in device tree"
grep -rnI "lineage" device/nothing/Aerodactyl --include=*.mk --include=*.bp 2>/dev/null | grep -v "org.lineageos" | cut -c1-200 | head -60

diag "git log of key repos"
for d in device/nothing/Aerodactyl hardware/nothing vendor/nothing/Pacman kernel/nothing/mt6886 vendor/miku; do
  echo "--- $d"; git -C $d log --oneline -3 2>&1 | cut -c1-150
done

diag "release configs and clang prebuilts"
ls build/release/release_configs/ 2>&1 | head -40
ls prebuilts/clang/host/linux-x86/ 2>&1 | grep -E "^clang-r" | tail -5

diag "END"

# ── export
export BUILD_USERNAME=itis_sajjad
export BUILD_HOSTNAME=crave

# ── Build Miku UI
. build/envsetup.sh

if [ -z "$RELEASE" ]; then
  RELEASE=$(ls build/release/release_configs/ 2>/dev/null | sed 's/\.textproto$//' | grep -E '^[a-z]{2}[0-9][a-z]$' | sort | tail -1)
  echo "[*] auto-selected RELEASE=${RELEASE}"
fi

lunch miku_${DEVICE}-${RELEASE}-userdebug || {
  diag "LUNCH FAILED (RELEASE=${RELEASE})"
  ls build/release/release_configs/ | head -40
  exit 1
}

diag "build vars"
for v in PLATFORM_VERSION PLATFORM_SDK_VERSION TARGET_PRODUCT TARGET_DEVICE TARGET_BUILD_VARIANT TARGET_BOARD_PLATFORM TARGET_KERNEL_VERSION; do
  echo "$v=$(get_build_var $v 2>/dev/null)"
done

make installclean

make diva 2>&1 | tee /tmp/make_diva.log
BUILD_RC=${PIPESTATUS[0]}

if [ $BUILD_RC -ne 0 ]; then
  diag "BUILD FAILED rc=${BUILD_RC} - first error"
  N=$(LC_ALL=C grep -n -m1 "FAILED:" /tmp/make_diva.log | cut -d: -f1)
  if [ -n "$N" ]; then
    sed -n "${N},$((N+80))p" /tmp/make_diva.log | cut -c1-500
  else
    tail -n 80 /tmp/make_diva.log | cut -c1-500
  fi
  exit $BUILD_RC
fi
