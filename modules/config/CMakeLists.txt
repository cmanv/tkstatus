cmake_minimum_required (VERSION 3.20)

# Project identification
project ("config")
set(PACKAGE_NAME "zstatus::config")
set(PACKAGE_VERSION "0.1")

# Tcl version
set(TCL_LIBRARY_VERSION "9.0")
set(TCL_INCLUDE_PATH "/usr/local/include/tcl9.0")

# Substitute some variable names
set(PKG_INDEX pkgIndex.tcl)
configure_file(${config_SOURCE_DIR}/${PKG_INDEX} ${config_BINARY_DIR}/${PKG_INDEX} @ONLY)
configure_file(${config_SOURCE_DIR}/config.tcl ${config_BINARY_DIR}/config.tcl @ONLY)

# Install files
set(PACKAGE_LIB ${CMAKE_INSTALL_LIBDIR}/zstatus/config)
install(FILES ${config_BINARY_DIR}/${PKG_INDEX} DESTINATION ${PACKAGE_LIB})
install(FILES ${config_BINARY_DIR}/config.tcl DESTINATION ${PACKAGE_LIB})
