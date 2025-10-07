#!/bin/bash
rm -rf .repo/local_manifests
rm -rf {device,vendor,kernel,hardware}/nothing
rm -rf {device,hardware}/mediatek
# ── Config
ROM_BRANCH="15.0"
DEVICE="zahedan"
MANIFEST_URL="https://github.com/ProjectMatrixx/android.git"
LOCAL_MANIFEST_URL="https://github.com/sajjad85gh/local_manifests.git"

# ── Init repo
repo init -u ${MANIFEST_URL} -b ${ROM_BRANCH} --git-lfs --no-clone-bundle

# ── Clone local_manifests
git clone ${LOCAL_MANIFEST_URL} -b main .repo/local_manifests

# ── Sync
/opt/crave/resync.sh

cd build/soong
wget -O 0001-soong-HACK-disable-soong_filesystem_creator.patch https://raw.githubusercontent.com/sajjad85gh/build-custom-rom/main/0001-soong-HACK-disable-soong_filesystem_creator.patch && \
git am 0001-soong-HACK-disable-soong_filesystem_creator.patch
cd -

# ── export
export BUILD_USERNAME=ItisSajjad
export BUILD_HOSTNAME=crave

# ── Build crDroid
source build/envsetup.sh
make installclean
brunch ${DEVICE} userdebug
