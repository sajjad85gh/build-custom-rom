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

# Reset patched framework repos so /opt/crave/resync.sh starts from a clean state
for dir in build/soong frameworks/base; do
  if [ -d "$dir/.git" ]; then
    git -C "$dir" am --abort 2>/dev/null || true
    git -C "$dir" cherry-pick --abort 2>/dev/null || true
    git -C "$dir" reset --hard HEAD 2>/dev/null || true
    git -C "$dir" clean -fd 2>/dev/null || true
  fi
done

# ── Init repo
repo init -u ${MANIFEST_URL} -b ${ROM_BRANCH} --git-lfs --no-clone-bundle
git clone ${LOCAL_MANIFEST_URL} -b main .repo/local_manifests

# ── Sync
/opt/crave/resync.sh

# ── Apply patches
# 1. Disable soong_filesystem_creator
cd build/soong
git am --abort 2>/dev/null || true
wget -qO 0001-soong-HACK-disable-soong_filesystem_creator.patch \
  https://raw.githubusercontent.com/sajjad85gh/build-custom-rom/main/0001-soong-HACK-disable-soong_filesystem_creator.patch
git am 0001-soong-HACK-disable-soong_filesystem_creator.patch || git am --abort
rm -f 0001-soong-HACK-disable-soong_filesystem_creator.patch
cd -

# 2. SQLiteTokenizer fix + UDFPS Dim/HBM fix in frameworks/base
cd frameworks/base
git am --abort 2>/dev/null || true
git cherry-pick --abort 2>/dev/null || true
wget -qO 873ce42cb45221b358c17aeebff6163fe8948e66.patch \
  https://github.com/LineageOS/android_frameworks_base/commit/873ce42cb45221b358c17aeebff6163fe8948e66.patch
git am 873ce42cb45221b358c17aeebff6163fe8948e66.patch || git am --abort
rm -f 873ce42cb45221b358c17aeebff6163fe8948e66.patch

wget -qO 0001-SystemUI-UDFPS-apply-framework-dim-only-while-finger.patch \
  https://raw.githubusercontent.com/sajjad85gh/build-custom-rom/main/0001-SystemUI-UDFPS-apply-framework-dim-only-while-finger.patch
git am 0001-SystemUI-UDFPS-apply-framework-dim-only-while-finger.patch || git am --abort
rm -f 0001-SystemUI-UDFPS-apply-framework-dim-only-while-finger.patch
cd -

# ── Build
. build/envsetup.sh
lunch lineage_${DEVICE}-bp1a-userdebug
mka bacon