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

# Clean modified repos before resync so /opt/crave/resync.sh never fails on dirty trees
for dir in build/soong frameworks/base; do
    if [ -d "$dir" ]; then
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
git log -n 5 --oneline | grep -q "disable soong_filesystem_creator" || git am 0001-soong-HACK-disable-soong_filesystem_creator.patch
rm -f 0001-soong-HACK-disable-soong_filesystem_creator.patch
cd -

# 2. SQLiteTokenizer fix 
cd frameworks/base
git am --abort 2>/dev/null || true
git cherry-pick --abort 2>/dev/null || true
git reset --hard HEAD
git clean -fd
if ! git log -n 5 --oneline | grep -q "SQLiteTokenizer"; then
    if curl -sfL https://github.com/LineageOS/android_frameworks_base/commit/873ce42cb45221b358c17aeebff6163fe8948e66.patch -o 873ce42.patch && grep -q "SQLiteTokenizer" 873ce42.patch; then
        git am 873ce42.patch
    else
        git fetch --depth 2 https://github.com/LineageOS/android_frameworks_base 873ce42cb45221b358c17aeebff6163fe8948e66
        git cherry-pick --no-commit 873ce42cb45221b358c17aeebff6163fe8948e66
        git commit -m "SQLiteTokenizer: Fix handling of empty tokens"
    fi
    rm -f 873ce42.patch
fi
cd -

# ── Include KernelSU-Next
# cd kernel/daria/mt6877
# curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -
# cd -

# ── Export
export BUILD_USERNAME=Sajjad
export BUILD_HOSTNAME=crave

# ── Build
. build/envsetup.sh
brunch ${DEVICE}
