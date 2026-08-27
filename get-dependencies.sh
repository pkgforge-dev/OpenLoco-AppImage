#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    cmake    \
    fmt      \
    gtest \
    onetbb \
    openal   \
    sdl3     \
    yaml-cpp

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano libdecor-mini

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here
#if [ "${DEVEL_RELEASE-}" = 1 ]; then
#	package=openloco-git
#else
#	package=openloco
#fi
#make-aur-package "$package"
#pacman -Q "$package" | awk '{print $2; exit}' > ~/version

#mkdir -p ./AppDir/bin
#mv -v /usr/share/openloco/data ./AppDir/bin

echo "Building OpenLoco..."
echo "---------------------------------------------------------------"
REPO="https://github.com/OpenLoco/OpenLoco"
if [ "${DEVEL_RELEASE-}" = 1 ]; then
    echo "Making nightly build of OpenLoco..."
    echo "---------------------------------------------------------------"
    VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
    git clone "$REPO" ./OpenLoco
else
    echo "Making stable build of OpenLoco..."
    echo "---------------------------------------------------------------"
    VERSION=$(git ls-remote --tags --refs --sort='v:refname' "$REPO" "refs/tags/ra*" | tail -n1 | cut -d/ -f3)
    git clone --branch "$VERSION" --single-branch "$REPO" ./OpenLoco
fi
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
