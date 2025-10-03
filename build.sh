#!/bin/bash

# ── Config ─────────────────────────────────────────────
ROM_BRANCH="15.0"
DEVICE="zahedan"
MANIFEST_URL="https://github.com/ProjectMatrixx/android.git"
# LOCAL_MANIFEST_URL="https://github.com/sajjad85gh/local_manifests.git"

# ── Init repo
rm -rf .repo/local_manifests
rm -rf {device,vendor,kernel}/daria
rm -rf {device,hardware}/mediatek
repo init -u ${MANIFEST_URL} -b ${ROM_BRANCH} --git-lfs --no-clone-bundle

# ── Clone local_manifests
# git clone ${LOCAL_MANIFEST_URL} -b main .repo/local_manifests
git clone https://github.com/daria-community/device_daria_zahedan -b Itis_Sajjad/temp/Matrixx-15-qpr2 device/daria/zahedan
git clone https://github.com/daria-community/kernel_volla_mt6877 -b itisFarzin/testing/lineage-23.0 kernel/daria/mt6877
git clone https://github.com/LineageOS/android_device_mediatek_sepolicy_vndr -b lineage-22.2 device/mediatek/sepolicy_vndr
git clone https://github.com/LineageOS/android_hardware_mediatek -b lineage-22.2 hardware/mediatek
git clone https://github.com/sajjad85gh/proprietary_vendor_daria_zahedan -b fifteen-qpr2 vendor/daria/zahedan

# ── Clone LMODynamicWallpaper
git clone https://github.com/LMODroid/platform_packages_apps_LMODynamicWallpaper -b fifteen-qpr2 packages/apps/LMODynamicWallpaper
  
# ── Sync
/opt/crave/resync.sh

# ── Apply patch
cd build/soong
wget -O 0001-soong-HACK-disable-soong_filesystem_creator.patch \
  https://raw.githubusercontent.com/sajjad85gh/build-custom-rom/main/0001-soong-HACK-disable-soong_filesystem_creator.patch
git am 0001-soong-HACK-disable-soong_filesystem_creator.patch
cd -
# ── export
export BUILD_USERNAME=Itis_Sajjad
export BUILD_HOSTNAME=crave

# ── Build
. build/envsetup.sh 
breakfast zahedan userdebug
make installclean
mka bacon
