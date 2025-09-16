#!/bin/bash
rm -rf .repo/local_manifests
repo init -u https://github.com/LineageOS/android.git -b lineage-22.2 --git-lfs --no-clone-bundle && \
/opt/crave/resync.sh && \
rm -rf {device,vendor,kernel}/daria; \
rm -rf device/mediatek/sepolicy_vndr hardware/mediatek; \
git clone https://github.com/LineageOS/android_device_mediatek_sepolicy_vndr -b lineage-22.2 device/mediatek/sepolicy_vndr && \
git clone https://github.com/daria-community/vendor_daria_zahedan -b lineage-22.2 vendor/daria/zahedan && \
git clone https://github.com/daria-community/device_daria_zahedan -b lineage-22.2 device/daria/zahedan-unified && \
git clone https://github.com/LineageOS/android_hardware_mediatek -b lineage-22.2 hardware/mediatek && \
git clone https://github.com/sajjad85gh/kernel-volla-mt6877 kernel/daria/mt6877 && \
. build/envsetup.sh && \
breakfast lineage zahedan userdebug && \
mka bakon
