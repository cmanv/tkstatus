cmake_minimum_required (VERSION 3.20)

# Project identification
project ("metar")
set(PACKAGE_NAME "metar")
set(PACKAGE_VERSION "1.0")
set(PACKAGE_INDEX "pkgIndex.tcl")
set(PACKAGE_LIB lib/${PACKAGE_NAME})
message (STATUS "*** Building ${PACKAGE_NAME} ${PACKAGE_VERSION} ***")

#find_package(TCL)
set(TCL_LIBRARY_VERSION "9.0")
set(TCL_INCLUDE_PATH "/usr/local/include/tcl9.0")

# Project config file
configure_file(${metar_SOURCE_DIR}/tcl/pkgIndex.tcl.in ${metar_BINARY_DIR}/${PACKAGE_INDEX})

# Install files
install(FILES ${metar_BINARY_DIR}/${PACKAGE_INDEX} DESTINATION ${PACKAGE_LIB})
install(FILES ${metar_SOURCE_DIR}/tcl/metar.tk DESTINATION ${PACKAGE_LIB})
install(FILES ${metar_SOURCE_DIR}/tcl/metar_decode.tcl DESTINATION ${PACKAGE_LIB})
