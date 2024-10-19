cmake_minimum_required (VERSION 3.20)

# Project identification
project ("utils")
set(PACKAGE_NAME "utils")
set(PACKAGE_VERSION "0.1")
set(PACKAGE_INDEX "pkgIndex.tcl")
set(PACKAGE_LIB lib/${PACKAGE_NAME})
message (STATUS "*** Building ${PACKAGE_NAME} ${PACKAGE_VERSION} ***")

#find_package(TCL)
set(TCL_LIBRARY_VERSION "9.0")
set(TCL_INCLUDE_PATH "/usr/local/include/tcl9.0")

# Project config file
configure_file(${utils_SOURCE_DIR}/pkgIndex.tcl.in ${utils_BINARY_DIR}/${PACKAGE_INDEX})

# Install files
install(FILES ${utils_BINARY_DIR}/${PACKAGE_INDEX} DESTINATION ${PACKAGE_LIB})
install(FILES ${utils_SOURCE_DIR}/utils.tcl DESTINATION ${PACKAGE_LIB})
