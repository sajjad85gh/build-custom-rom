#!/bin/bash
rm -rf .repo/local_manifests
repo init -u https://github.com/LineageOS/android.git -b lineage-22.2 --git-lfs --no-clone-bundle && \
/opt/crave/resync.sh && \
rm -rf {device,vendor,kernel,android/hardware}/nothing; \
rm -rf {device,hardware}/mediatek; \
git clone https://github.com/LineageOS/android_device_mediatek_sepolicy_vndr -b lineage-22.2 device/mediatek/sepolicy_vndr && \
git clone https://gitlab.com/nothing-2a/proprietary_vendor_nothing_Pacman -b lineage-22.2 vendor/nothing/Pacman && \
git clone https://github.com/Nothing-2A/android_device_nothing_Aerodactyl -b lineage-22.2 device/nothing/Aerodactyl && \
git clone https://github.com/LineageOS/android_hardware_mediatek -b lineage-22.2 hardware/mediatek && \
git clone https://github.com/Nothing-2A/android_device_nothing_Aerodactyl-kernel -b lineage-22.2 kernel/nothing/mt6886 && \
git clone https://github.com/Nothing-2A/android_hardware_nothing -b lineage22.2 hardware/nothing && \
. build/envsetup.sh && \
lunch lineage_Pacman-bp1a-userdebug && \
mka bacon
