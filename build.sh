#!/bin/bash

# ── Config ─────────────────────────────────────────────
ROM_NAME="lineage"
ROM_BRANCH="16.0"
DEVICE="Pacman-bp2a"
MANIFEST_URL="https://github.com/crdroidandroid/android.git"
LOCAL_MANIFEST_URL="https://github.com/sajjad85gh/local_manifests.git"

# ── Init repo
rm -rf .repo/local_manifests
repo init -u ${MANIFEST_URL} -b ${ROM_BRANCH} --git-lfs --no-clone-bundle

# ── Clone local_manifests
git clone ${LOCAL_MANIFEST_URL} -b main .repo/local_manifests

# ── Sync
/opt/crave/resync.sh

# ── Apply patch
# Aperture
cd packages/apps/Aperture
git fetch https://github.com/Nothing-2A/android_packages_apps_Aperture 36c9507ecf2a1a798d2e7931d9019bacc3cc6052
git cherry-pick 36c9507ecf2a1a798d2e7931d9019bacc3cc6052 || true

# Lineage compat hardware
cd hardware/lineage/compat
git fetch https://review.lineageos.org/LineageOS/android_hardware_lineage_compat refs/changes/04/447604/1
git cherry-pick FETCH_HEAD || true

# UDFPS dimming
cd frameworks/base
git fetch https://github.com/Nothing-2A/android_frameworks_base 79b3ae0b06ffdbadde3d2106a2bbf895b074ffb2
git cherry-pick 79b3ae0b06ffdbadde3d2106a2bbf895b074ffb2 || true

# ── export
export BUILD_USERNAME=itis_sajjad
export BUILD_HOSTNAME=crave

# ── Build
. build/envsetup.sh
lunch ${ROM_NAME}_${DEVICE}-eng
make installclean
mka bacon
