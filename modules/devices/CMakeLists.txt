cmake_minimum_required (VERSION 3.20)

# Project identification
project ("devices")
set(PACKAGE_NAME "devices")
set(PACKAGE_VERSION "0.1")
set(PACKAGE_INDEX "pkgIndex.tcl")
set(PACKAGE_LIB lib/${PACKAGE_NAME})

#find_package(TCL)
set(TCL_LIBRARY_VERSION "9.0")
set(TCL_INCLUDE_PATH "/usr/local/include/tcl9.0")

# Project config file
configure_file(${devices_SOURCE_DIR}/pkgIndex.tcl.in ${devices_BINARY_DIR}/${PACKAGE_INDEX})

# Install files
install(FILES ${devices_BINARY_DIR}/${PACKAGE_INDEX} DESTINATION ${PACKAGE_LIB})
install(FILES ${devices_SOURCE_DIR}/devices.tk DESTINATION ${PACKAGE_LIB})
