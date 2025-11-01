#!/bin/bash

set -e

# ── Trap for cleanup ───────────────────────────────────
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# ── Config ─────────────────────────────────────────────
ROM_BRANCH="lineage-22.2"
DEVICE="zahedan"
MANIFEST_URL="https://github.com/LineageOS/android.git"
LOCAL_MANIFEST_URL="https://github.com/sajjad85gh/local_manifests.git"

FIRMWARE_ZIP_URL="http://bashupload.app/hzalc3.zip"

GITHUB_USERNAME="sajjad85gh"
GITHUB_REPO="proprietary_vendor_daria_zahedan"
GITHUB_BRANCH="fifteen-qpr2-testing"
GITHUB_TOKEN="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"

# ── Clean previous repo/device/vendor/kernel
rm -rf .repo/local_manifests || true
rm -rf {device,kernel}/daria || true
rm -rf {device,hardware}/mediatek || true

# ── Init repo
repo init -u ${MANIFEST_URL} -b ${ROM_BRANCH} --git-lfs --no-clone-bundle

# ── Clone local_manifests
git clone ${LOCAL_MANIFEST_URL} -b main .repo/local_manifests

# ── Sync
if [ ! -x "/opt/crave/resync.sh" ]; then
  echo "Error: /opt/crave/resync.sh not found or not executable!"
  exit 1
fi
/opt/crave/resync.sh

# ── Apply patch
cd build/soong
wget -O 0001-soong-HACK-disable-soong_filesystem_creator.patch \
  https://raw.githubusercontent.com/sajjad85gh/build-custom-rom/main/0001-soong-HACK-disable-soong_filesystem_creator.patch

if ! git am 0001-soong-HACK-disable-soong_filesystem_creator.patch; then
  echo "Patch failed! Maybe already applied?"
  git am --abort || true
  exit 1
fi
cd -

# ── Download firmware zip
echo "Downloading firmware zip..."
if ! wget --timeout=30 --tries=3 -O "${TMPDIR}/firmware.zip" "${FIRMWARE_ZIP_URL}"; then
  echo "Failed to download firmware!"
  exit 1
fi

# ── Extract firmware
echo "Extracting firmware..."
if ! unzip -o "${TMPDIR}/firmware.zip" -d "${TMPDIR}/firmware"; then
  echo "Failed to extract firmware!"
  exit 1
fi

# ── Replace vendor radio directories
rm -rf vendor/daria/zahedan/radio/zahedan vendor/daria/zahedan/radio/algiz
mkdir -p vendor/daria/zahedan/radio/{zahedan,algiz}

[ -d "${TMPDIR}/firmware/zahedan" ] && cp -rf "${TMPDIR}/firmware/zahedan/"* vendor/daria/zahedan/radio/zahedan/ || echo "Warning: zahedan firmware not found"
[ -d "${TMPDIR}/firmware/algiz" ] && cp -rf "${TMPDIR}/firmware/algiz/"* vendor/daria/zahedan/radio/algiz/ || echo "Warning: algiz firmware not found"

# ── Commit and push changes
cd vendor/daria/zahedan

git remote set-url origin "https://${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/${GITHUB_REPO}.git" 2>/dev/null || \
  git remote add origin "https://${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/${GITHUB_REPO}.git"

git add radio/ || true

if git diff --staged --quiet; then
  echo "No changes to commit in vendor radio"
else
  git commit -m "zahedan: Import firmware from AP3A.241105008.V6.7.2.0.BOND"
  echo "Pushing changes to GitHub..."
  if ! git push origin "${GITHUB_BRANCH}"; then
    echo "Push failed. Maybe already up to date or network issue."
  fi
fi
cd -

# ── Export build identity
export BUILD_USERNAME=Sajjad
export BUILD_HOSTNAME=crave

# ── Build
. build/envsetup.sh
breakfast ${DEVICE} userdebug
make installclean
mka bacon

echo "Build finished successfully!"
