#!/bin/bash
repo init --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 15-QPR0 -g default,-mips,-darwin,-notdefault && \
/opt/crave/resync.sh && \
rm -rf {device,vendor,kernel}/daria; \
rm -rf device/mediatek/sepolicy_vndr hardware/mediatek; \
git clone https://github.com/LMODroid/platform_device_mediatek_sepolicy_vndr -b fifteen-qpr0 && \
git clone https://github.com/itisFarzin-Phone/vendor_daria_zahedan -b fourteen vendor/daria/zahedan && \
git clone https://github.com/sajjad85gh/device_daria_zahedan -b infinity15 device/daria/zahedan && \
git clone https://github.com/LineageOS/android_hardware_mediatek -b lineage-22.0 hardware/mediatek && \
git clone https://github.com/DariaRnD/kernel_daria_mt6877 kernel/daria/mt6877 && \
. build/envsetup.sh && \
brunch zahedan
