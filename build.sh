#!/bin/bash
rm -rf .repo/local_manifests
repo init -u https://github.com/Ingres-Centre/lineage_23.0.git -b lineage-23.0 --git-lfs --no-clone-bundle && \
/opt/crave/resync.sh && \
cd build/soong && \
wget -O 0001-soong-HACK-disable-soong_filesystem_creator.patch https://raw.githubusercontent.com/sajjad85gh/build-custom-rom/main/0001-soong-HACK-disable-soong_filesystem_creator.patch && \
git am 0001-soong-HACK-disable-soong_filesystem_creator.patch && \
cd - && \
rm -rf {device,vendor,kernel}/daria; \
rm -rf {device,hardware}/mediatek; \
git clone https://github.com/LineageOS/android_device_mediatek_sepolicy_vndr -b lineage-23.0 device/mediatek/sepolicy_vndr && \
git clone https://github.com/daria-community/vendor_daria_zahedan -b upstream/lineage-22.2 vendor/daria/zahedan && \
git clone https://github.com/daria-community/device_daria_zahedan -b itisFarzin/testing/lineage-23.0 device/daria/zahedan && \
git clone https://github.com/LineageOS/android_hardware_mediatek -b lineage-22.2 hardware/mediatek && \
git clone https://github.com/daria-community/kernel_volla_mt6877 -b itisFarzin/tmp/lineage-23.0 kernel/daria/mt6877 && \
. build/envsetup.sh && \
lunch lineage_zahedan-bp2a-userdebug && \
mka bacon
