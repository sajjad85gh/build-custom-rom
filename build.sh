#!/bin/bash
rm -rf .repo/local_manifests
rm -rf {device,vendor,kernel,hardware}/nothing
rm -rf {device,hardware}/mediatek
# ── Config
ROM_BRANCH="15.0"
DEVICE="Pacman"
MANIFEST_URL="https://github.com/ProjectMatrixx/android.git"
LOCAL_MANIFEST_URL="https://github.com/sajjad85gh/local_manifests.git"

# ── Init repo
repo init -u ${MANIFEST_URL} -b ${ROM_BRANCH} --git-lfs --no-clone-bundle

# ── Clone local_manifests
git clone ${LOCAL_MANIFEST_URL} -b main .repo/local_manifests

# ── Sync
/opt/crave/resync.sh
rm -rf hardware/lineage/interfaces/sensors

# List of patches: "<repo_path>|<commit_sha>|<remote_url>"
PATCHES=(
  "packages/apps/Aperture|36c9507ecf2a1a798d2e7931d9019bacc3cc6052|https://github.com/Nothing-2A/android_packages_apps_Aperture"
  "hardware/lineage/compat|60729c841a8b447896aa8108d2c0cfc0a5327041|https://github.com/LineageOS/android_hardware_lineage_compat"
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
source build/envsetup.sh
make installclean
brunch ${DEVICE} userdebug
