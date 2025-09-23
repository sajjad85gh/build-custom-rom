#!/bin/bash
rm -rf .repo/local_manifests
repo init -u https://github.com/Evolution-X/manifest -b vic --git-lfs --no-clone-bundle && \
/opt/crave/resync.sh && \
cd build/soong && \
wget -O 0001-soong-HACK-disable-soong_filesystem_creator.patch https://raw.githubusercontent.com/sajjad85gh/build-custom-rom/main/0001-soong-HACK-disable-soong_filesystem_creator.patch && \
git am 0001-soong-HACK-disable-soong_filesystem_creator.patch && \
cd - && \
rm -rf {device,vendor,kernel}/daria; \
rm -rf {device,hardware}/mediatek; \
git clone https://github.com/LineageOS/android_device_mediatek_sepolicy_vndr -b lineage-22.2 device/mediatek/sepolicy_vndr && \
git clone https://github.com/daria-community/vendor_daria_zahedan -b upstream/lineage-22.2 vendor/daria/zahedan && \
git clone https://github.com/daria-community/device_daria_zahedan -b upstream/lineage-22.2 device/daria/zahedan-unified && \
git clone https://github.com/LineageOS/android_hardware_mediatek -b lineage-22.2 hardware/mediatek && \
git clone https://github.com/daria-community/kernel_volla_mt6877 -b itisFarzin/testing/lineage-23.0 kernel/daria/mt6877 && \
export BUILD_USERNAME=itis_sajjad && \ 
export BUILD_HOSTNAME=crave && \
source build/envsetup.sh && \
lunch lineage_zahedan-bp1a-eng && \
make installclean && \
m evolution
