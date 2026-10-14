#!/bin/bash

set -o pipefail

rm -rf .repo/local_manifests
rm -rf {device,vendor,kernel,hardware}/nothing
rm -rf {device,hardware}/mediatek

# ── Config
ROM_BRANCH="Cinderella"
DEVICE="Pacman"
MANIFEST_URL="https://github.com/Miku-UI/manifesto.git"
LOCAL_MANIFEST_URL="https://github.com/sajjad85gh/local_manifests.git"

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
  [ -d "$REPO_PATH" ] || { echo "[!] $REPO_PATH doesn`t exist"; exit 1; }
  PATCH_FILE=$(mktemp)
  curl -fsSL "$REMOTE_URL/commit/$COMMIT_SHA.patch" -o "$PATCH_FILE" || { echo "[!] download falied"; exit 1; }
  pushd "$REPO_PATH" > /dev/null
  if git apply --check -R "$PATCH_FILE" 2>/dev/null; then echo "[✔] was applied"
  elif git am -3 "$PATCH_FILE"; then echo "[✔] apllied now"
  else git am --abort || true; echo "[!!!] CONFLICT: $COMMIT_SHA"; fi
  popd > /dev/null
done

# ── export
export BUILD_USERNAME=itis_sajjad
export BUILD_HOSTNAME=crave

# ── Build crDroid
. build/envsetup.sh
make installclean
lunch miku_${DEVICE}-CP4A-userdebug
make diva
