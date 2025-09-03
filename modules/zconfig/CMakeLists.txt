cmake_minimum_required (VERSION 3.20)

# Project identification
project ("zconfig")
set(PACKAGE_NAME "zconfig")
set(PACKAGE_VERSION "0.1")

# Tcl version
set(TCL_LIBRARY_VERSION "9.0")
set(TCL_INCLUDE_PATH "/usr/local/include/tcl9.0")

# Substitute some variable names
set(PKG_INDEX pkgIndex.tcl)
configure_file(${zconfig_SOURCE_DIR}/${PKG_INDEX} ${zconfig_BINARY_DIR}/${PKG_INDEX} @ONLY)
configure_file(${zconfig_SOURCE_DIR}/zconfig.tcl ${zconfig_BINARY_DIR}/zconfig.tcl @ONLY)

# Install files
set(PACKAGE_LIB ${CMAKE_INSTALL_LIBDIR}/zstatus/${PACKAGE_NAME})
install(FILES ${zconfig_BINARY_DIR}/${PKG_INDEX} DESTINATION ${PACKAGE_LIB})
install(FILES ${zconfig_BINARY_DIR}/zconfig.tcl DESTINATION ${PACKAGE_LIB})
