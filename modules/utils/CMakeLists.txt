cmake_minimum_required (VERSION 3.20)

# Project identification
project ("utils")
set(PACKAGE_NAME "utils")
set(PACKAGE_VERSION "0.1")
set(PACKAGE_INDEX "pkgIndex.tcl")
set(PACKAGE_LIB lib/${PACKAGE_NAME})
message (STATUS "*** Building ${PACKAGE_NAME} ${PACKAGE_VERSION} ***")

# Tcl version
set(TCL_LIBRARY_VERSION "9.0")
set(TCL_INCLUDE_PATH "/usr/local/include/tcl9.0")

# Substitute some variable names
configure_file(${utils_SOURCE_DIR}/${PACKAGE_INDEX} ${utils_BINARY_DIR}/${PACKAGE_INDEX} @ONLY)
configure_file(${utils_SOURCE_DIR}/utils.tcl ${utils_BINARY_DIR}/utils.tcl @ONLY)

# Install files
install(FILES ${utils_BINARY_DIR}/${PACKAGE_INDEX} DESTINATION ${PACKAGE_LIB})
install(FILES ${utils_BINARY_DIR}/utils.tcl DESTINATION ${PACKAGE_LIB})
