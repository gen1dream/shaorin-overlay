# Copyright 2019-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic systemd cmake

DESCRIPTION="Server for World of Warcraft - Wrath of The Lich king"
HOMEPAGE="https://www.getmangos.eu/"

if [[ ${PV} =~ "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/mangostwo/server.git"
	EGIT_SUBMODULES=( "*" )
else
	# As of 30.10.2021 @ 3920930b5af58fe6eba2be6df1ce07a99c8fcb41
	MANGOSDEPS_COMMIT="1cb807f642629bb371297ec3bf0399c2eb0ba3c5"
	REALMD_COMMIT="3bbaa6010d509602e15367dafc4678d1a8c2b520"
	SD3_COMMIT="158dd8a90f88b04a934fbe91e53d3bd274a8dff3"
	EXTRACTOR_COMMIT="f6d96d5da55a22b2da2a5dfb2f66830d572289d3"
	EASY_BUILD_COMMIT="60cb2dda5346e31d94ed87c1b7b55912fbf54ea0"
	ELUNA_COMMIT="2962d4fea3708cf22964d1cc750290b8980b313f"
	SRC_URI="
		https://github.com/mangostwo/server/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/mangos/mangosDeps/archive/${MANGOSDEPS_COMMIT}.tar.gz -> mangosDeps-${MANGOSDEPS_COMMIT}.tar.gz
		https://github.com/mangos/realmd/archive/${realmd_COMMIT}.tar.gz -> realmd-${realmd_COMMIT}.tar.gz
		https://github.com/mangos/ScriptDev3/archive/${SD3_COMMIT}.tar.gz -> ScriptDev3-${SD3_COMMIT}.tar.gz
		https://github.com/mangos/Extractor_projects/archive/${EXTRACTOR_COMMIT}.tar.gz -> Extractor_projects-${EXTRACTOR_COMMIT}.tar.gz
		https://github.com/mangos/EasyBuild/archive/${EASY_BUILD_COMMIT}.tar.gz -> EasyBuild-${EASY_BUILD_COMMIT}.tar.gz
		https://github.com/ElunaLuaEngine/Eluna/archive/${ELUNA_COMMIT}.tar.gz -> Eluna-${ELUNA_COMMIT}.tar.gz
		"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-2"
SLOT="0"

IUSE="+acct bots +clang +database doc +eluna +login +pch +tools +sd3 soap +stormlib system-libs"

DEPEND="
	app-arch/bzip2
	dev-libs/openssl
	sys-libs/zlib
	|| (
		dev-db/mariadb:*
		dev-db/mysql:*
	)
	acct? (
		acct-group/mangos
		acct-user/mangos
	)
	system-libs? (
		stormlib? (
			app-arch/stormlib
		)
		soap? (
			net-libs/gsoap
		)
		dev-games/recastnavigation[64ref(-)]
	)
"
BDEPEND="
	clang? (
		sys-devel/clang
	)
	doc? (
		app-doc/doxygen
	)
"
RDEPEND="
	${RDEPEND}
	database? (
		app-emulation/mangostwodatabase
	)
"

src_prepare() {
	if ! [[ ${PV} =~ "9999" ]]; then
		pushd ${WORKDIR} > /dev/null
		mv mangosDeps-${MANGOSDEPS_COMMIT} ${S}/dep || die
		mv realmd-${REALMD_COMMIT} ${S}/src/realmd || die
		mv ScriptDev3-${SD3_COMMIT} ${S}/src/modules/SD3 || die
		mv Extractor_projects-${EXTRACTOR_COMMIT} ${S}/src/tools/Extractor_projects || die
		mv EasyBuild-${EASYBUILD_COMMIT} ${S}/win || die
		mv Eluna-${ELUNA_COMMIT} ${S}/src/module/Eluna || die
		popd > /dev/null
	fi

	# Integrate documentation into cmake proper
	cat <<- EOF >> CMakeLists.txt
	option(DOC	"Build documentation with Doxygen" OFF)
	if(DOC)
	add_subdirectory(doc)
	endif()
	EOF
	sed -i 's/\(find_package(Doxygen\)/\1 REQUIRED/' doc/CMakeLists.txt || die

	# Use system libraries
	if use system-libs; then

		# Stormlib
		cp ${FILESDIR}/FindStormLib.cmake cmake || die
		sed -i '/if(USE_STORMLIB)/,/else()/ s/add_subdirectory(\(StormLib\))/find_package(\1 REQUIRED)/' dep/CMakeLists.txt || die
		sed -i '/add_subdirectory(tomlib)/d' dep/CMakeLists.txt || die
		sed -i 's/stormlib/${StormLib_LIBRARIES}/' dep/loadlib/CMakeLists.txt || die

		# gsoap: Uses a random example header
		#cp ${FILESDIR}/Findgsoap.cmake cmake || die
		#sed -i '/if(SOAP)/,/endif()/ s/add_subdirectory(\(gsoap\))/find_package(\1 REQUIRED)/' dep/CMakeLists.txt || die

		#TODO: more can be done here

		# recastnavigation
		cp ${FILESDIR}/FindRecastNavigation.cmake cmake || die
		sed -i '/if(BUILD_MANGOSD OR BUILD_TOOLS)/,/endif()/ s/add_subdirectory(recastnavigation)/find_package(RecastNavigation REQUIRED)/' dep/CMakeLists.txt || die
		sed -i '/target_include_directories(mmap-extractor/,/)/ {
		/Movemap-Generator/a\
        ${RECASTNAVIGATION_INCLUDE_DIRS}
		}'  src/tools/Extractor_projects/CMakeLists.txt || die
		sed -i 's/\(RecastNavigation::Detour\)/INTERFACE \1/' src/game/CMakeLists.txt || die
		sed -i 's/\(RecastNavigation::Recast\)/INTERFACE \1/' src/tools/Extractor_projects/CMakeLists.txt || die
		#sed -i '/#include <DetourNavMeshBuilder.h>/a #include <DetourNavMesh.h>' src/tools/Extractor_projects/Movemap-Generator/MapBuilder.cpp || die
	else
		sed -i 's/LIBRARY DESTINATION lib/LIBRARY DESTINATION lib64/' dep/StormLib/CMakeLists.txt || die
	fi
	sed -i '/find_package(ZLIB/,/find_package(BZip2/ s/QUIET/REQUIRED/' CMakeLists.txt || die
	sed -i -e '/if (NOT TARGET "ZLIB::ZLIB")/,/endif()/ d' -e '/if (NOT TARGET "BZip2::BZip2")/,/endif()/ d' dep/CMakeLists.txt || die

	if use acct; then
		# Setup configs
		sed -i 's/\(LogsDir\s*= \)""/\1"\/var\/log\/mangos\"/' src/mangosd/mangosd.conf.dist.in || die
		sed -i 's/\(PidFile\s*= \)""/\1"\/run\/mangosd.pid\"/' src/mangosd/mangosd.conf.dist.in || die

		sed -i 's/^\(LogsDir\s*= \)""/\1"\/var\/log\/mangos\"/' src/realmd/realmd.conf.dist.in || die
		sed -i 's/\(PidFile\s*= \)""/\1"\/run\/realmd.pid\"/' src/realmd/realmd.conf.dist.in || die
	fi

	cmake_src_prepare
}

src_configure() {
	if use clang; then
		einfo "Overriding CC and CXX with Clang"
		CC="${CHOST}-clang"
		CXX="${CHOST}-clang++"
		strip-unsupported-flags
	fi

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
			-DDOC=$(usex doc)
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	dosym "../../opt/mangostwo/bin/mangosd" "${EPREFIX}/usr/bin/mangosd-two"
	newinitd ${FILESDIR}/mangosd.initd mangosd
	newconfd ${FILESDIR}/mangosd.confd mangosd
	systemd_dounit ${FILESDIR}/mangosd.service
	mv ${D}/opt/mangostwo/etc/mangosd.conf.dist ${D}/opt/mangostwo/etc/mangosd.conf || die

	if use login; then
		dosym "../..//opt/mangostwo/bin/realmd" "${EPREFIX}/usr/bin/realmd-two"
		newinitd ${FILESDIR}/realmd.initd realmd
		newconfd ${FILESDIR}/realmd.confd realmd
		systemd_dounit ${FILESDIR}/realmd.service
		mv ${D}/opt/mangostwo/etc/realmd.conf.dist ${D}/opt/mangostwo/etc/realmd.conf || die
	fi

	if use acct; then
		diropts -m0750 -o mangos -g mangos
		keepdir /var/lib/mangos /var/log/mangos
	fi
}
