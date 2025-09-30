#!/bin/bash

# ── Config ─────────────────────────────────────────────
ROM_BRANCH="15.0"
DEVICE="zahedan"
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
cd build/soong
wget -O 0001-soong-HACK-disable-soong_filesystem_creator.patch \
  https://raw.githubusercontent.com/sajjad85gh/build-custom-rom/main/0001-soong-HACK-disable-soong_filesystem_creator.patch
git am 0001-soong-HACK-disable-soong_filesystem_creator.patch
cd -

# ── Build
. build/envsetup.sh
make installclean
brunch ${DEVICE}
