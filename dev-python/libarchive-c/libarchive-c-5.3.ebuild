# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

MY_P=python-libarchive-c-${PV}
DESCRIPTION="A Python interface to libarchive"
HOMEPAGE="
	https://github.com/Changaco/python-libarchive-c/
	https://pypi.org/project/libarchive-c/
"
SRC_URI="
	https://github.com/Changaco/python-libarchive-c/archive/${PV}.tar.gz
		-> ${MY_P}.gh.tar.gz
"
S=${WORKDIR}/${MY_P}

LICENSE="CC0-1.0"
SLOT="0"
KEYWORDS="amd64 ~arm arm64 ~ppc64 x86"

RDEPEND="
	app-arch/libarchive
"

distutils_enable_tests pytest

python_test() {
	local -x PYTEST_DISABLE_PLUGIN_AUTOLOAD=1
	epytest -o tmp_path_retention_policy=all
}
