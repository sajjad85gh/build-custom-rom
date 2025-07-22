#!/bin/bash
"repo init -u https://github.com/RisingOS-Revived/android -b fifteen --git-lfs -g default,-mips,-darwin,-notdefault && \
/opt/crave/resync.sh && \
rm -rf {device,vendor,kernel}/daria; \
rm -rf device/mediatek/sepolicy_vndr hardware/mediatek; \
git clone https://github.com/LineageOS/android_device_mediatek_sepolicy_vndr.git device/mediatek/sepolicy_vndr -b lineage-22.1 && \
git clone https://github.com/itisFarzin-Phone/vendor_daria_zahedan -b fourteen vendor/daria/zahedan && \
git clone https://github.com/sajjad85gh/device_daria_zahedan -b rising device/daria/zahedan && \
git clone https://github.com/LineageOS/android_hardware_mediatek -b lineage-22.1 hardware/mediatek && \
git clone https://github.com/DariaRnD/kernel_daria_mt6877 kernel/daria/mt6877 && \
. build/envsetup.sh && \
brunch zahedan"
