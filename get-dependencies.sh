#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    cmake    \
    fmt      \
    onetbb   \
    openal   \
    sdl3     \
    yaml-cpp

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano libdecor-mini

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
    TAG=$(git ls-remote --tags --refs --sort='v:refname' "$REPO" "refs/tags/v*" | tail -n1 | cut -d/ -f3)
    VERSION="${TAG#v}"
    git clone --branch "$TAG" --single-branch "$REPO" ./OpenLoco
fi
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
cd ./OpenLoco
cmake -G "Unix Makefiles" -B build -S ./ -DCMAKE_BUILD_TYPE=Release -DOPENLOCO_BUILD_TESTS=NO
cmake --build build -j$(nproc)
mv -v build/data build/OpenLoco ../AppDir/bin
