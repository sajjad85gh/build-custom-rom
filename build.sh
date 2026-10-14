#!/bin/bash
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

# List of patches: "<repo_path>|<commit_sha>|<remote_url>"
PATCHES=(
  "packages/apps/Aperture|I1e027dcacc48f139c067e4e3ae1d5750d29e65a5|https://github.com/Nothing-2A/android_packages_apps_Aperture"
  "android/frameworks/native|I66cb2d7d2ca3d08f768c6a66521a60eaa66015aa|https://github.com/Nothing-2A/android_frameworks_native"
  "android/frameworks/base|I907d9075c79ab4af5b82d3781291d97c1eab17b1|https://github.com/Nothing-2A/android_frameworks_base"
)

echo "[*] Applying all patches automatically..."

for entry in "${PATCHES[@]}"; do
  IFS="|" read -r REPO_PATH COMMIT_SHA REMOTE_URL <<< "$entry"
  echo -e "\n[*] Applying patch $COMMIT_SHA in $REPO_PATH"

  # Clone repo if missing
  if [ ! -d "$REPO_PATH" ]; then
    echo "[*] Path $REPO_PATH not found, cloning..."
    git clone --depth=1 "$REMOTE_URL" "$REPO_PATH"
  fi

  pushd "$REPO_PATH" > /dev/null

  PATCH_URL="$REMOTE_URL/commit/$COMMIT_SHA.patch"

  # Skip if already applied
  if git log --oneline | grep -q "$COMMIT_SHA"; then
    echo "[✔️] Skipping $COMMIT_SHA (already applied)."
    popd > /dev/null
    continue
  fi

  echo "[*] Downloading patch from $PATCH_URL"
  if curl -fsSL "$PATCH_URL" | git am -3; then
    echo "[✔️] Applied $COMMIT_SHA successfully."
  else
    echo "[!] Conflict detected for $COMMIT_SHA, aborting safely..."
    git am --abort || true
  fi

  popd > /dev/null
done

echo -e "All patches processed!"

# ── export
export BUILD_USERNAME=itis_sajjad
export BUILD_HOSTNAME=crave

# ── Build crDroid
. build/envsetup.sh
make installclean
lunch miku_${DEVICE}-CP4A-userdebug
make diva
