cmake_minimum_required (VERSION 3.20)

# Project identification
project ("zstatus")
set(PACKAGE_NAME "zstatus")
set(PACKAGE_VERSION "alpha1")
message (STATUS "*** Building ${PACKAGE_NAME} ${PACKAGE_VERSION} ***")

# Tcl version
set(TCL_LIBRARY_VERSION "9.0")
set(TCL_INCLUDE_PATH "/usr/local/include/tcl9.0")
include(GNUInstallDirs)

# Add modules
add_subdirectory(modules/devices)
add_subdirectory(modules/mail)
add_subdirectory(modules/metar)
add_subdirectory(modules/musicpd)
add_subdirectory(modules/sysbsd)
add_subdirectory(modules/utils)
add_subdirectory(modules/zconfig)

# Substitute some variable names
configure_file(${zstatus_SOURCE_DIR}/zstatus.tk ${zstatus_BINARY_DIR}/zstatus.tk @ONLY)

# Install files
install(PROGRAMS ${zstatus_BINARY_DIR}/zstatus.tk DESTINATION bin)
install(PROGRAMS ${zstatus_SOURCE_DIR}/zstatus-send DESTINATION bin)
install(PROGRAMS ${zstatus_SOURCE_DIR}/zstatus.sh DESTINATION bin)
install(FILES man/zstatus.1 DESTINATION ${CMAKE_INSTALL_MANDIR}/man1)
