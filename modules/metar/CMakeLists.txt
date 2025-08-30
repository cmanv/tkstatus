cmake_minimum_required (VERSION 3.20)

# Project identification
project ("metar")
set(PACKAGE_NAME "metar")
set(PACKAGE_VERSION "1.0")
set(PACKAGE_INDEX "pkgIndex.tcl")
set(PACKAGE_LIB lib/${PACKAGE_NAME})
message (STATUS "*** Building ${PACKAGE_NAME} ${PACKAGE_VERSION} ***")

# Tcl version
set(TCL_LIBRARY_VERSION "9.0")
set(TCL_INCLUDE_PATH "/usr/local/include/tcl9.0")

# Substitute some variable names
configure_file(${metar_SOURCE_DIR}/${PACKAGE_INDEX} ${metar_BINARY_DIR}/${PACKAGE_INDEX} @ONLY)
configure_file(${metar_SOURCE_DIR}/metar.tk ${metar_BINARY_DIR}/metar.tk @ONLY)
configure_file(${metar_SOURCE_DIR}/metar_decode.tcl ${metar_BINARY_DIR}/metar_decode.tcl @ONLY)

# Install files
install(FILES ${metar_BINARY_DIR}/${PACKAGE_INDEX} DESTINATION ${PACKAGE_LIB})
install(FILES ${metar_BINARY_DIR}/metar.tk DESTINATION ${PACKAGE_LIB})
install(FILES ${metar_BINARY_DIR}/metar_decode.tcl DESTINATION ${PACKAGE_LIB})
