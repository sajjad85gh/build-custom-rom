#!/bin/bash
repo init -u https://github.com/crdroidandroid/android.git -b 16.0 --git-lfs --no-clone-bundle && \
/opt/crave/resync.sh && \
rm -rf {device,vendor,kernel}/daria; \
rm -rf device/mediatek/sepolicy_vndr hardware/mediatek; \
git clone https://github.com/LineageOS/android_device_mediatek_sepolicy_vndr -b lineage-23.0 device/mediatek/sepolicy_vndr && \
git clone https://github.com/sajjad85gh/vendor_daria_zahedan -b sixteen-qpr0 vendor/daria/zahedan && \
git clone https://github.com/sajjad85gh/device_daria_zahedan -b cr16.0 device/daria/zahedan && \
git clone https://github.com/LineageOS/android_hardware_mediatek -b lineage-22.2 hardware/mediatek && \
git clone https://github.com/sajjad85gh/kernel-volla-mt6877 kernel/daria/mt6877 && \
. build/envsetup.sh && \
breakfast zahedan user && \
make installclean && \
mka bacon
