cmake_minimum_required (VERSION 3.20)

# Project identification
project ("zconf")
set(PACKAGE_NAME "zconf")
set(PACKAGE_VERSION "0.1")
set(PACKAGE_INDEX "pkgIndex.tcl")
set(PACKAGE_LIB lib/${PACKAGE_NAME})

#find_package(TCL)
set(TCL_LIBRARY_VERSION "9.0")
set(TCL_INCLUDE_PATH "/usr/local/include/tcl9.0")

# Project config file
configure_file(${zconf_SOURCE_DIR}/pkgIndex.tcl.in ${zconf_BINARY_DIR}/${PACKAGE_INDEX})

# Install files
install(FILES ${zconf_BINARY_DIR}/${PACKAGE_INDEX} DESTINATION ${PACKAGE_LIB})
install(FILES ${zconf_SOURCE_DIR}/zconf.tcl DESTINATION ${PACKAGE_LIB})
