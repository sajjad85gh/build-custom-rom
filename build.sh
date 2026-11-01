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
rm -f out/target/product/zahedan/vendor/etc/vintf/manifest/android.hardware.vibrator.zahedan.xml
rm -f out/target/product/zahedan/vendor/etc/init/android.hardware.vibrator-service.zahedan.rc
rm -f out/target/product/zahedan/vendor/bin/hw/android.hardware.vibrator-service.zahedan

# ── Init repo
repo init -u ${MANIFEST_URL} -b ${ROM_BRANCH} --git-lfs --no-clone-bundle
git clone ${LOCAL_MANIFEST_URL} -b main .repo/local_manifests

# ── Sync
/opt/crave/resync.sh

# ── Apply patch
# Disable soong_filesystem_creator
cd build/soong
git am --abort 2>/dev/null || true
wget -qO 0001-soong-HACK-disable-soong_filesystem_creator.patch \
  https://raw.githubusercontent.com/sajjad85gh/build-custom-rom/main/0001-soong-HACK-disable-soong_filesystem_creator.patch
git am 0001-soong-HACK-disable-soong_filesystem_creator.patch || true
cd -

# SQLiteTokenizer fix
cd frameworks/base
git cherry-pick --abort 2>/dev/null || true
git fetch --depth 1 https://github.com/LineageOS/android_frameworks_base 873ce42cb45221b358c17aeebff6163fe8948e66
git cherry-pick --no-commit 873ce42cb45221b358c17aeebff6163fe8948e66
git commit -m "SQLiteTokenizer: Fix handling of empty tokens" || git checkout -- .
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
