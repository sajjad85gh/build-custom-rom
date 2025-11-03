#!/bin/bash

# ── Config ─────────────────────────────────────────────
ROM_BRANCH="lineage-22.2"
DEVICE="zahedan"
MANIFEST_URL="https://github.com/LineageOS/android.git"
LOCAL_MANIFEST_URL="https://github.com/sajjad85gh/local_manifests.git"

# ── Clean
rm -rf .repo/local_manifests
rm -rf {device,vendor,kernel}/daria
rm -rf {device,hardware}/mediatek

# ── Init repo
repo init -u ${MANIFEST_URL} -b ${ROM_BRANCH} --git-lfs --no-clone-bundle
git clone ${LOCAL_MANIFEST_URL} -b main .repo/local_manifests

# ── Sync
/opt/crave/resync.sh

# ── Apply patch
cd build/soong
wget -O 0001-soong-HACK-disable-soong_filesystem_creator.patch \
  https://raw.githubusercontent.com/sajjad85gh/build-custom-rom/main/0001-soong-HACK-disable-soong_filesystem_creator.patch
git am 0001-soong-HACK-disable-soong_filesystem_creator.patch
cd -

# ── Include KernelSU-Next
# cd kernel/daria/mt6877
# curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -
# cd -

# ── export
export BUILD_USERNAME=Sajjad
export BUILD_HOSTNAME=crave

# ── build
breakfast ${DEVICE} userdebug
make installclean
mka bacon
