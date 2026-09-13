#!/bin/bash
set -e

# ── Config ─────────────────────────────────────────────
ROM_BRANCH="lineage-23.2"
DEVICE="crownlte"
BUILD_TYPE="userdebug"
GMS_VARIANT="core"
MANIFEST_URL="https://github.com/AxionAOSP/android.git"
LOCAL_MANIFEST_URL="https://github.com/ExyHyperBrick/local_manifests.git"
LOCAL_MANIFEST_BRANCH="lineage-23.2-ims"
PATCHES_URL="https://github.com/ExyHyperBrick/local_manifests/raw/${LOCAL_MANIFEST_BRANCH}/PATCHES.zip"
DEVICE_MK="device/samsung/${DEVICE}/lineage_${DEVICE}.mk"

# ── Init repo
rm -rf .repo/local_manifests
repo init -u ${MANIFEST_URL} -b ${ROM_BRANCH} --git-lfs --no-clone-bundle

# ── Clone local_manifests
git clone ${LOCAL_MANIFEST_URL} -b ${LOCAL_MANIFEST_BRANCH} .repo/local_manifests

# ── Sync
/opt/crave/resync.sh

# ── Init PhhIms submodule
cd packages/apps/PhhIms
git submodule update --init --recursive
cd -

# ── Apply patches (PATCHES.zip)
rm -rf ~/PATCHES
wget -O /tmp/PATCHES.zip "${PATCHES_URL}"
mkdir -p ~/PATCHES
unzip -o /tmp/PATCHES.zip -d ~/PATCHES
~/PATCHES/apply_patches.sh *

# ── AxionOS device-tree tweak
if [ -f "${DEVICE_MK}" ]; then
    grep -q "TARGET_DISABLE_EPPE" "${DEVICE_MK}" || \
        sed -i '/vendor\/lineage\/config\/common_full_phone.mk/i TARGET_DISABLE_EPPE := true' "${DEVICE_MK}"
else
    echo "WARNING: ${DEVICE_MK} not found — add 'TARGET_DISABLE_EPPE := true' to the device makefile manually before building."
fi

# ── Build environment
. build/envsetup.sh
gk -s
axion ${DEVICE} ${BUILD_TYPE} ${GMS_VARIANT}
ax -br -j$(nproc --all)
