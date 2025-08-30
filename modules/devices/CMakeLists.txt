cmake_minimum_required (VERSION 3.20)

# Project identification
project ("devices")
set(PACKAGE_NAME "devices")
set(PACKAGE_VERSION "0.2")
set(PACKAGE_INDEX "pkgIndex.tcl")
set(PACKAGE_LIB lib/${PACKAGE_NAME})

# Tcl version
set(TCL_LIBRARY_VERSION "9.0")
set(TCL_INCLUDE_PATH "/usr/local/include/tcl9.0")

# Substitute some variable names
configure_file(${devices_SOURCE_DIR}/${PACKAGE_INDEX} ${devices_BINARY_DIR}/${PACKAGE_INDEX} @ONLY)
configure_file(${devices_SOURCE_DIR}/devices.tk ${devices_BINARY_DIR}/devices.tk @ONLY)

# Install files
install(FILES ${devices_BINARY_DIR}/${PACKAGE_INDEX} DESTINATION ${PACKAGE_LIB})
install(FILES ${devices_BINARY_DIR}/devices.tk DESTINATION ${PACKAGE_LIB})
