# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="MANGOS server user"
ACCT_USER_ID=-1
ACCT_USER_GROUPS=( mangos )
ACCT_USER_HOME=/var/lib/mangos
ACCT_USER_OWNER=mangos:mangos
ACC_USER_HOME_PERM=750

KEYWORDS="~amd64"

acct-user_add_deps
