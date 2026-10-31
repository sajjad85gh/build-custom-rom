#!/bin/bash

# ── Config
ROM_BRANCH="15.0"
DEVICE="zahedan"
MANIFEST_URL="https://github.com/crdroidandroid/android.git"
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
# Disable soong_filesystem_creator
cd build/soong
wget -O 0001-soong-HACK-disable-soong_filesystem_creator.patch \
  https://raw.githubusercontent.com/sajjad85gh/build-custom-rom/main/0001-soong-HACK-disable-soong_filesystem_creator.patch
git am 0001-soong-HACK-disable-soong_filesystem_creator.patch
cd -

# UDFPS Dimming & SQLiteTokenizer fix
cd frameworks/native
git fetch https://github.com/daria-community/android_frameworks_native d4dc70e3189b0b848feac95ef02b1ced2ccf28f4
git cherry-pick d4dc70e3189b0b848feac95ef02b1ced2ccf28f4
cd -

cd frameworks/base
git fetch https://github.com/daria-community/android_frameworks_base 55c5cc00e0c5b223469e4a7b8615de7fdc83c31c
git cherry-pick 55c5cc00e0c5b223469e4a7b8615de7fdc83c31c
git fetch https://github.com/LineageOS/android_frameworks_base 873ce42cb45221b358c17aeebff6163fe8948e66
git cherry-pick 873ce42cb45221b358c17aeebff6163fe8948e66
cd -

# ── Include KernelSU-Next
# cd kernel/daria/mt6877
# curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -
# cd -

# ── export
export BUILD_USERNAME=Sajjad
export BUILD_HOSTNAME=crave

# ── build
. build/envsetup.sh
brunch ${DEVICE}
