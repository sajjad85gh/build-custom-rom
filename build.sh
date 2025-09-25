#!/bin/bash

# ── Config ─────────────────────────────────────────────
ROM_NAME="lineage"
ROM_BRANCH="bka"
DEVICE="Pacman-bp2a"
MANIFEST_URL="https://github.com/Evolution-X/manifest.git"
LOCAL_MANIFEST_URL="https://github.com/sajjad85gh/local_manifests.git"

# ── Init repo
rm -rf .repo/local_manifests
repo init -u ${MANIFEST_URL} -b ${ROM_BRANCH} --git-lfs --no-clone-bundle

# ── Clone local_manifests
git clone ${LOCAL_MANIFEST_URL} -b main .repo/local_manifests

# ── Sync
/opt/crave/resync.sh

# ── Build
. build/envsetup.sh
lunch ${ROM_NAME}_${DEVICE}-eng
make installclean
m evolution
