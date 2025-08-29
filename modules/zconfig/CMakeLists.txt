cmake_minimum_required (VERSION 3.20)

# Project identification
project ("zconfig")
set(PACKAGE_NAME "zconfig")
set(PACKAGE_VERSION "0.1")
set(PACKAGE_INDEX "pkgIndex.tcl")
set(PACKAGE_LIB lib/${PACKAGE_NAME})

# Tcl version
set(TCL_LIBRARY_VERSION "9.0")
set(TCL_INCLUDE_PATH "/usr/local/include/tcl9.0")

# Substitute some variable names
configure_file(${zconfig_SOURCE_DIR}/${PACKAGE_INDEX} ${zconfig_BINARY_DIR}/${PACKAGE_INDEX} @ONLY)

# Install files
install(FILES ${zconfig_BINARY_DIR}/${PACKAGE_INDEX} DESTINATION ${PACKAGE_LIB})
install(FILES ${zconfig_SOURCE_DIR}/zconfig.tcl DESTINATION ${PACKAGE_LIB})
