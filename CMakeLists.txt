cmake_minimum_required (VERSION 3.20)

# Project identification
project ("zstatus")
set(PACKAGE_NAME "zstatus")
set(PACKAGE_VERSION "alpha1")
message (STATUS "*** Building ${PACKAGE_NAME} ${PACKAGE_VERSION} ***")

#find_package(TCL)
set(TCL_LIBRARY_VERSION "9.0")
set(TCL_INCLUDE_PATH "/usr/local/include/tcl9.0")

# Subdirs

add_subdirectory(modules/devices)
add_subdirectory(modules/maildir)
add_subdirectory(modules/metar)
add_subdirectory(modules/musicpd)
add_subdirectory(modules/sysinfo)
add_subdirectory(modules/utils)
add_subdirectory(modules/zconfig)

# Project config file
configure_file(${zstatus_SOURCE_DIR}/zstatus.tk ${zstatus_BINARY_DIR}/${PACKAGE_NAME})
# Install files
install(PROGRAMS ${zstatus_BINARY_DIR}/zstatus DESTINATION bin)
install(PROGRAMS ${zstatus_SOURCE_DIR}/zstatus-send DESTINATION bin)
install(PROGRAMS ${zstatus_SOURCE_DIR}/zstatus.sh DESTINATION bin)
