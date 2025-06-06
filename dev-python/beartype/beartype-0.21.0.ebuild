# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..13} )

inherit distutils-r1 pypi

DESCRIPTION="Unbearably fast runtime type checking in pure Python"
HOMEPAGE="
	https://pypi.org/project/beartype/
	https://github.com/beartype/beartype/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm64 ~riscv"

BDEPEND="
	test? (
		dev-python/click[${PYTHON_USEDEP}]
		dev-python/mypy[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/sqlalchemy[${PYTHON_USEDEP}]
		dev-python/xarray[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest

python_test() {
	local EPYTEST_DESELECT=(
		# fragile performance test
		beartype_test/a00_unit/a70_decor/test_decorwrapper.py::test_wrapper_fail_obj_large
		# test for building docs, apparently broken too
		beartype_test/a90_func/z90_lib/a00_sphinx
	)

	local -x PYTEST_DISABLE_PLUGIN_AUTOLOAD=1
	epytest
}
