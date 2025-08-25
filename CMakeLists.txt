cmake_minimum_required (VERSION 3.20)

# Project identification
project ("zstatus")
set(PACKAGE_NAME "zstatus")
set(PACKAGE_VERSION "20250825")
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

# Install files
install(PROGRAMS ${zstatus_SOURCE_DIR}/zstatus.tk DESTINATION bin)
install(PROGRAMS ${zstatus_SOURCE_DIR}/zstatus.sh DESTINATION bin)
