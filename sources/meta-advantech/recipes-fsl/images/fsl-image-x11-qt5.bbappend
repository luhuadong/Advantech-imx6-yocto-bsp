require fsl-image-x11.inc

RDEPENDS_packagegroup-core-lsb-desktop = "\
    libxt \
    libxxf86vm \
    libdrm \
    libglu \
    libxi \
    libxtst \
    libx11-locale \
    xorg-minimal-fonts \
    gdk-pixbuf-loader-ico \
    gdk-pixbuf-loader-bmp \
    gdk-pixbuf-loader-ani \
    gdk-pixbuf-xlib \
    liberation-fonts \
    gtk+ \
    atk \
    libasound \
    ${@base_contains("DISTRO_FEATURES", "opengl", "libqtopengl4", "", d)} \
    ${@get_libqt3(d)} \
"

IMAGE_INSTALL_append = " \
	ruby \
	qt3d \
	qt3d-examples \
	qt3d-qmlplugins \
	qt3d-tools \
	qtbase-fonts \
	qtbase-plugins \
	qtbase-examples \
	qtbase-tools \
	qtconnectivity \
	qtconnectivity-qmlplugins \
	qtdeclarative \
	qtdeclarative-plugins \
	qtdeclarative-tools \
	qtdeclarative-examples \
	qtdeclarative-qmlplugins \
	qtimageformats \
	qtimageformats-plugins \
	qtlocation \
	qtlocation-plugins \
	qtlocation-qmlplugins \
	qtmultimedia \
	qtmultimedia-plugins \
	qtmultimedia-examples \
	qtmultimedia-qmlplugins \
	qtscript \
	qtsensors \
	qtserialport \
	qtsvg \
	qtsvg-plugins \
	qtsystems \
	qtsystems-tools \
	qtsystems-examples \
	qtsystems-qmlplugins \
	qtx11extras \
	qtxmlpatterns \
	qtwebkit \
	qtwebkit-examples-examples \
	qtwebkit-qmlplugins \
	qmlpresentationsystem-qmlplugins \
	qtpatientcare \
	qtsmarthome \
	qt5launchdemo \
	qt5everywheredemo \
	qt5nmapcarousedemo \
	qt5nmapper \
	quitindicators \
	quitbattery \
	qt5ledscreen \
	qt5-demo-extrafiles \
	"

TOOLCHAIN_HOST_TASK += "nativesdk-packagegroup-qt5-toolchain-host"
TOOLCHAIN_TARGET_TASK += "packagegroup-qt5-toolchain-target"

# This allow reuse of Qt paths
inherit qmake5_paths

toolchain_create_sdk_env_script_append () {
    echo 'export PATH=${SDKPATHNATIVE}${OE_QMAKE_PATH_HOST_BINS}:$PATH' >> $script
    echo 'export OE_QMAKE_CFLAGS="$CFLAGS"' >> $script
    echo 'export OE_QMAKE_CXXFLAGS="$CXXFLAGS"' >> $script
    echo 'export OE_QMAKE_LDFLAGS="$LDFLAGS"' >> $script
    echo 'export OE_QMAKE_CC=$CC' >> $script
    echo 'export OE_QMAKE_CXX=$CXX' >> $script
    echo 'export OE_QMAKE_LINK=$CXX' >> $script
    echo 'export OE_QMAKE_AR=$AR' >> $script
    echo 'export OE_QMAKE_LIBDIR_QT=${SDKTARGETSYSROOT}${OE_QMAKE_PATH_LIBS}' >> $script
    echo 'export OE_QMAKE_INCDIR_QT=${SDKTARGETSYSROOT}${OE_QMAKE_PATH_QT_HEADERS}' >> $script
    echo 'export OE_QMAKE_MOC=${SDKPATHNATIVE}${OE_QMAKE_PATH_HOST_BINS}/moc' >> $script
    echo 'export OE_QMAKE_UIC=${SDKPATHNATIVE}${OE_QMAKE_PATH_HOST_BINS}/uic' >> $script
    echo 'export OE_QMAKE_RCC=${SDKPATHNATIVE}${OE_QMAKE_PATH_HOST_BINS}/rcc' >> $script
    echo 'export OE_QMAKE_QDBUSCPP2XML=${SDKPATHNATIVE}${OE_QMAKE_PATH_HOST_BINS}/qdbuscpp2xml' >> $script
    echo 'export OE_QMAKE_QDBUSXML2CPP=${SDKPATHNATIVE}${OE_QMAKE_PATH_HOST_BINS}/qdbusxml2cpp' >> $script
    echo 'export OE_QMAKE_QT_CONFIG=${SDKTARGETSYSROOT}${OE_QMAKE_PATH_LIBS}/${QT_DIR_NAME}/mkspecs/qconfig.pri' >> $script
    echo 'export QMAKESPEC=${SDKTARGETSYSROOT}${OE_QMAKE_PATH_LIBS}/${QT_DIR_NAME}/mkspecs/linux-oe-g++' >> $script
    echo 'export QT_CONF_PATH=${SDKPATHNATIVE}${OE_QMAKE_PATH_HOST_BINS}/qt.conf' >> $script

    # make a symbolic link to mkspecs for compatibility with QTCreator
    (cd ${SDK_OUTPUT}/${SDKPATHNATIVE}; \
         ln -sf ${SDKTARGETSYSROOT}${libdir}/${QT_DIR_NAME}/mkspecs mkspecs;)

    # Generate a qt.conf file to be deployed with the SDK
    qtconf=${SDK_OUTPUT}/${SDKPATHNATIVE}${OE_QMAKE_PATH_HOST_BINS}/qt.conf
    touch $qtconf
    echo '[Paths]' >> $qtconf
    echo 'Prefix = ${SDKTARGETSYSROOT}' >> $qtconf
    echo 'Headers = ${SDKTARGETSYSROOT}${OE_QMAKE_PATH_QT_HEADERS}' >> $qtconf
    echo 'Libraries = ${SDKTARGETSYSROOT}${OE_QMAKE_PATH_LIBS}' >> $qtconf
    echo 'ArchData = ${SDKTARGETSYSROOT}${OE_QMAKE_PATH_QT_ARCHDATA}' >> $qtconf
    echo 'Data = ${SDKTARGETSYSROOT}${OE_QMAKE_PATH_QT_DATA}' >> $qtconf
    echo 'Binaries = ${SDKTARGETSYSROOT}${OE_QMAKE_PATH_QT_BINS}' >> $qtconf
    echo 'LibraryExecutables = ${SDKTARGETSYSROOT}${OE_QMAKE_PATH_LIBEXECS}' >> $qtconf
    echo 'Plugins = ${SDKTARGETSYSROOT}${OE_QMAKE_PATH_PLUGINS}' >> $qtconf
    echo 'Imports = ${SDKTARGETSYSROOT}${OE_QMAKE_PATH_IMPORTS}' >> $qtconf
    echo 'Qml2Imports = ${SDKTARGETSYSROOT}${OE_QMAKE_PATH_QML}' >> $qtconf
    echo 'Translations = ${SDKTARGETSYSROOT}${OE_QMAKE_PATH_QT_TRANSLATIONS}' >> $qtconf
    echo 'Documentation = ${SDKTARGETSYSROOT}${OE_QMAKE_PATH_QT_DOCS}' >> $qtconf
    echo 'Settings = ${SDKTARGETSYSROOT}${OE_QMAKE_PATH_QT_SETTINGS}' >> $qtconf
    echo 'Examples = ${SDKTARGETSYSROOT}${OE_QMAKE_PATH_QT_EXAMPLES}' >> $qtconf
    echo 'Tests = ${SDKTARGETSYSROOT}${OE_QMAKE_PATH_QT_TESTS}' >> $qtconf
    echo 'HostPrefix = ${SDKPATHNATIVE}' >> $qtconf
    echo 'HostBinaries = ${SDKPATHNATIVE}${OE_QMAKE_PATH_HOST_BINS}' >> $qtconf
}

PACKAGE_GROUP_qtcreator-debug = "packagegroup-qt5-qtcreator-debug"

