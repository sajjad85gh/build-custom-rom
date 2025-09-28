#!/bin/bash

rm -rf {device,vendor,kernel,hardware}/nothing
rm -rf {device,hardware}/mediatek
# ── Config
ROM_BRANCH="16.0"
DEVICE="Pacman"
MANIFEST_URL="https://github.com/crdroidandroid/android.git"
LOCAL_MANIFEST_URL="https://github.com/sajjad85gh/local_manifests.git"

# ── Init repo
rm -rf .repo/local_manifests
repo init -u ${MANIFEST_URL} -b ${ROM_BRANCH} --git-lfs --no-clone-bundle

# ── Clone local_manifests
git clone ${LOCAL_MANIFEST_URL} -b main .repo/local_manifests

# ── Sync
/opt/crave/resync.sh
rm -rf hardware/lineage/interfaces/sensors
# ── Apply patch: Aperture
if [ -d "packages/apps/Aperture" ]; then
    echo "[*] Applying patch Aperture..."
    pushd packages/apps/Aperture >/dev/null
    git fetch https://github.com/Nothing-2A/android_packages_apps_Aperture 36c9507ecf2a1a798d2e7931d9019bacc3cc6052
    git cherry-pick -X theirs 36c9507ecf2a1a798d2e7931d9019bacc3cc6052 || git reset --hard FETCH_HEAD
    popd >/dev/null
else
    echo "⚠️ Skipped Aperture patch: path not found"
fi

# # ── Apply patch: Lineage compat hardware
# if [ -d "hardware/lineage/compat" ]; then
#     echo "[*] Applying patch Lineage compat hardware..."
#     pushd hardware/lineage/compat >/dev/null
#     git fetch https://review.lineageos.org/LineageOS/android_hardware_lineage_compat refs/changes/04/447604/1
#     git cherry-pick -X theirs FETCH_HEAD || git reset --hard FETCH_HEAD

#     # ── Auto fix for AudioTrack.cpp issue
#     COMPAT_FILE="libaudioclient/AudioTrack.cpp"
#     if [ -f "$COMPAT_FILE" ]; then
#         echo "[*] Fixing legacy_callback_t in $COMPAT_FILE..."
#         sed -i 's/AudioTrack::legacy_callback_t/legacy_callback_t/g' "$COMPAT_FILE"
#     fi

#     popd >/dev/null
# else
#     echo "⚠️ Skipped Lineage compat patch: path not found"
# fi

# ── Apply patch: UDFPS dimming
if [ -d "frameworks/base" ]; then
    echo "[*] Applying patch UDFPS dimming..."
    pushd frameworks/base >/dev/null
    git fetch https://github.com/Nothing-2A/android_frameworks_base 79b3ae0b06ffdbadde3d2106a2bbf895b074ffb2
    git cherry-pick -X theirs 79b3ae0b06ffdbadde3d2106a2bbf895b074ffb2 || git reset --hard FETCH_HEAD
    popd >/dev/null
else
    echo "⚠️ Skipped UDFPS dimming patch: path not found"
fi

# ── export
export BUILD_USERNAME=itis_sajjad
export BUILD_HOSTNAME=crave

# ── Build crDroid
source build/envsetup.sh
make installclean
brunch ${DEVICE} user
