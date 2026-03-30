#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	cmake 	 \
	fmt		 \
	libdecor \
	openal 	 \
	sdl2 	 \
	yaml-cpp

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

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

if [ "${DEVEL_RELEASE-}" = 1 ]; then
cat <<'EOM' > "PKGBUILD"
pkgname=openloco-git
pkgver=25.11.r108.gad4f7c42a
pkgrel=1
pkgdesc="An open source re-implementation of Chris Sawyer's Locomotion"
arch=(x86_64 aarch64)
url="https://github.com/OpenLoco/OpenLoco"
license=(MIT)
depends=(sdl3 libpng openal)
makedepends=(cmake yaml-cpp git gtest fmt)
provides=(openloco)
conflicts=(openloco)
options=(lto !debug)
source=("git+https://github.com/OpenLoco/OpenLoco.git")
sha256sums=('SKIP')
pkgver() {
  cd OpenLoco
  git describe --long --tags | sed 's/^v//;s/\([^-]*-g\)/r\1/;s/-/./g'
}
build() {
	local _flags=(
    -DFETCHCONTENT_QUIET:BOOL=OFF \
    -DOPENLOCO_BUILD_TESTS=OFF \
    -DCMAKE_CXX_FLAGS="-Wno-error" \
	)
  cd "${srcdir}/OpenLoco"
  rm -rf build
  cmake -G "Unix Makefiles" -B build -S . -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_INSTALL_DATAROOTDIR=/usr/share \
    -DCMAKE_INSTALL_DATADIR=/usr/share/data \
    -DUSE_SYSTEM_FMT=ON \
    -DCMAKE_SIZEOF_VOID_P=8 \
    -DCMAKE_INSTALL_LIBDIR=lib \
    "${_flags[@]}"
  cmake --build build
}
package() {
  install -Dm644 "${srcdir}/OpenLoco/src/Resources/src/logo/icon_x16.png" "$pkgdir/usr/share/icons/hicolor/16x16/apps/openloco.png"
  install -Dm644 "${srcdir}/OpenLoco/src/Resources/src/logo/icon_x32.png" "$pkgdir/usr/share/icons/hicolor/32x32/apps/openloco.png"
  install -Dm644 "${srcdir}/OpenLoco/src/Resources/src/logo/icon_x64.png" "$pkgdir/usr/share/icons/hicolor/64x64/apps/openloco.png"
  install -Dm644 "${srcdir}/OpenLoco/src/Resources/src/logo/icon_x128.png" "$pkgdir/usr/share/icons/hicolor/128x128/apps/openloco.png"
  install -Dm644 "${srcdir}/OpenLoco/src/Resources/src/logo/icon_x256.png" "$pkgdir/usr/share/icons/hicolor/256x256/apps/openloco.png"
  install -Dm644 "${srcdir}/OpenLoco/src/Resources/src/logo/icon_x512.png" "$pkgdir/usr/share/icons/hicolor/512x512/apps/openloco.png"
  install -Dm644 "${srcdir}/OpenLoco/src/Resources/src/logo/icon_steam.svg" "$pkgdir/usr/share/icons/hicolor/scalable/apps/openloco.svg"
  cd "${srcdir}/OpenLoco"
  DESTDIR="${pkgdir}" cmake --install build
  install -D "${srcdir}/OpenLoco/LICENSE" -t "${pkgdir}/usr/share/licenses/${pkgname}"
  rm -rf "${pkgdir}/usr/lib/libfmt.a"
  rm -rf "${pkgdir}/usr/include/fmt"
  rm -rf "${pkgdir}/usr/lib/cmake/fmt"
  rm -rf "${pkgdir}/usr/lib/pkgconfig/fmt.pc"
  rm -rf "${pkgdir}/usr/share/include/sfl"
}
EOM
make-aur-package
pacman -Q "openloco-git" | awk '{print $2; exit}' > ~/version
else
cat <<'EOM' > "PKGBUILD"
pkgname=openloco
pkgver=25.12
pkgrel=1
pkgdesc="An open source re-implementation of Chris Sawyer's Locomotion"
arch=(x86_64 aarch64)
url="https://github.com/OpenLoco/OpenLoco"
license=(MIT)
depends=(sdl2 libpng openal)
makedepends=(cmake yaml-cpp gtest fmt git)
options=(lto !debug)
source=("${pkgname}-${pkgver}.tar.gz::https://github.com/OpenLoco/OpenLoco/archive/refs/tags/v${pkgver}.tar.gz")
sha256sums=('11e06a365c083940665cfeaa0c367686b9171733cd05bb7692222226b74a716e')
build() {
  local _flags=(
    -DFETCHCONTENT_QUIET:BOOL=OFF
    -DOPENLOCO_BUILD_TESTS=OFF
    -DCMAKE_CXX_FLAGS="-Wno-error"
  )
  cd "${srcdir}/OpenLoco-${pkgver}"
  rm -rf build
  cmake -G "Unix Makefiles" -B build -S . -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_INSTALL_DATAROOTDIR=/usr/share \
    -DCMAKE_INSTALL_DATADIR=/usr/share/data \
    -DUSE_SYSTEM_FMT=ON \
    -DCMAKE_SIZEOF_VOID_P=8 \
    -DCMAKE_INSTALL_LIBDIR=lib \
    "${_flags[@]}"
  cmake --build build
}
package() {
  install -Dm644 "${srcdir}/OpenLoco-${pkgver}/src/Resources/src/logo/icon_x16.png" "$pkgdir/usr/share/icons/hicolor/16x16/apps/openloco.png"
  install -Dm644 "${srcdir}/OpenLoco-${pkgver}/src/Resources/src/logo/icon_x32.png" "$pkgdir/usr/share/icons/hicolor/32x32/apps/openloco.png"
  install -Dm644 "${srcdir}/OpenLoco-${pkgver}/src/Resources/src/logo/icon_x64.png" "$pkgdir/usr/share/icons/hicolor/64x64/apps/openloco.png"
  install -Dm644 "${srcdir}/OpenLoco-${pkgver}/src/Resources/src/logo/icon_x128.png" "$pkgdir/usr/share/icons/hicolor/128x128/apps/openloco.png"
  install -Dm644 "${srcdir}/OpenLoco-${pkgver}/src/Resources/src/logo/icon_x256.png" "$pkgdir/usr/share/icons/hicolor/256x256/apps/openloco.png"
  install -Dm644 "${srcdir}/OpenLoco-${pkgver}/src/Resources/src/logo/icon_x512.png" "$pkgdir/usr/share/icons/hicolor/512x512/apps/openloco.png"
  install -Dm644 "${srcdir}/OpenLoco-${pkgver}/src/Resources/src/logo/icon_steam.svg" "$pkgdir/usr/share/icons/hicolor/scalable/apps/openloco.svg"
  cd "${srcdir}/OpenLoco-${pkgver}"
  DESTDIR="${pkgdir}" cmake --install build
  install -D "${srcdir}/OpenLoco-${pkgver}/LICENSE" -t "${pkgdir}/usr/share/licenses/${pkgname}"
  rm -rf "${pkgdir}/usr/lib/libfmt.a"
  rm -rf "${pkgdir}/usr/include/fmt"
  rm -rf "${pkgdir}/usr/lib/cmake/fmt"
  rm -rf "${pkgdir}/usr/lib/pkgconfig/fmt.pc"
  rm -rf "${pkgdir}/usr/share/include/sfl"
}
EOM
make-aur-package
pacman -Q "openloco" | awk '{print $2; exit}' > ~/version
fi
