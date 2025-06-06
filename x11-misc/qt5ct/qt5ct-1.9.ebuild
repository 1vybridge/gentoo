# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake optfeature qmake-utils

DESCRIPTION="Qt5 configuration tool, similar to qtconfig for Qt4"
HOMEPAGE="https://sourceforge.net/projects/qt5ct/"
SRC_URI="https://download.sourceforge.net/qt5ct/${P}.tar.bz2"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="amd64 ~arm ~ppc64 x86"

RDEPEND="
	dev-qt/qtconcurrent:5
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtgui:5=[dbus]
	dev-qt/qtwidgets:5
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-qt/linguist-tools:5
"

PATCHES=( "${FILESDIR}/${P}-no-qtpaths.patch" )

src_configure() {
	local mycmakeargs=(
		-DPLUGINDIR=$(qt5_get_plugindir)
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	newenvd - 98qt5ct <<< 'QT_QPA_PLATFORMTHEME=qt5ct'
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		ewarn "qt5ct configuration won't be applied to the currently running sessions."
		ewarn "Please relogin."
	fi
	optfeature "SVG icon themes" "dev-qt/qtsvg:5"
}
