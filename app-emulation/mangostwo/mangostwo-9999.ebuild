# Copyright 2019-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit llvm cmake git-r3

EGIT_REPO_URI="https://github.com/mangostwo/server.git"

DESCRIPTION="Server for World of Warcraft - Wrath of The Lich king"
HOMEPAGE="https://www.getmangos.eu/"

LICENSE="GPL-2"
SLOT="0"

IUSE="bots +login +tools +stormlib +eluna +sd3 soap +pch +database +clang"

LLVM_MAX_SLOT=12

DEPEND="
	|| (
		dev-db/mariadb:*
		dev-db/mysql
	)
"
BDEPEND="
	clang? (
		sys-devel/clang
	)"
RDEPEND="
	dev-db/mariadb
	database? (
		app-emulation/mangostwodatabase
	)
"

llvm_check_deps() {
	has_version "sys-devel/clang:${LLVM_SLOT}"
}

src_prepare() {
	sed -i 's/LIBRARY DESTINATION lib/LIBRARY DESTINATION lib64/' dep/StormLib/CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	CC=${CHOST}-clang
	CXX=${CHOST}-clang++
	strip-unsupported-flags

	local mycmakeargs=(
			-DCMAKE_INSTALL_PREFIX=/opt/mangostwo/
			-DCONF_INSTALL_DIR=/opt/mangostwo/etc
			-DBUILD_REALMD=$(usex login)
			-DBUILD_TOOLS=$(usex tools)
			-DUSE_STORMLIB=$(usex stormlib)
			-DSCRIPT_LIB_ELUNA=$(usex eluna)
			-DSCRIPT_LIB_SD3=$(usex sd3)
			-DPLAYERBOTS=$(usex bots)
			-DSOAP=$(usex soap)
			-DPCH=$(usex pch)
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	dosym "${EPREFIX}/opt/mangostwo/bin/mangosd" "${EPREFIX}/usr/bin/rmangosd-two"
	dosym "${EPREFIX}/opt/mangostwo/bin/realmd" "${EPREFIX}/usr/bin/realmd-two"
}
