# Copyright 2019-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

EGIT_REPO_URI="https://github.com/mangostwo/database.git"

DESCRIPTION="Database for Mangos Two Server"
HOMEPAGE="https://www.getmangos.eu/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""


src_install() {

   insinto /opt/mangostwo/database
   doins -r ${S}/*
}
