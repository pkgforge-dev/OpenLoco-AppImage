#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=https://raw.githubusercontent.com/OpenLoco/OpenLoco/refs/heads/master/src/Resources/src/logo/icon_x256.png
export DESKTOP=https://raw.githubusercontent.com/OpenLoco/OpenLoco/refs/heads/master/distribution/linux/openloco.desktop
export DEPLOY_OPENGL=1

# Deploy dependencies
quick-sharun /usr/bin/OpenLoco

# Turn AppDir into AppImage
quick-sharun --make-appimage
