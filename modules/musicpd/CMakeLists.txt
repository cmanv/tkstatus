cmake_minimum_required (VERSION 3.20)

# Project identification
project ("musicpd")
set(PACKAGE_NAME "musicpd")
set(PACKAGE_VERSION "0.5")
set(PACKAGE_PROVIDE "MPD")
set(PACKAGE_INDEX "pkgIndex.tcl")
set(PACKAGE_LIB mpd${PACKAGE_VERSION})
set(CMAKE_C_COMPILER "/usr/bin/cc")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
message (STATUS "*** Building ${PACKAGE_NAME} ${PACKAGE_VERSION} ***")

# Tcl version
set(TCL_LIBRARY_VERSION "9.0")
set(TCL_INCLUDE_PATH "/usr/local/include/tcl9.0")

# Substitute some variable names
configure_file(${musicpd_SOURCE_DIR}/src/config.h.in ${musicpd_BINARY_DIR}/src/config.h)
configure_file(${musicpd_SOURCE_DIR}/${PACKAGE_INDEX} ${musicpd_BINARY_DIR}/${PACKAGE_INDEX} @ONLY)
configure_file(${musicpd_SOURCE_DIR}/musicpd.tk ${musicpd_BINARY_DIR}/musicpd.tk @ONLY)

# Library build
add_definitions(-I ${musicpd_BINARY_DIR}/src)
include_directories(/usr/local/include/mpd ${TCL_INCLUDE_PATH})
add_library(${PACKAGE_LIB} SHARED)
target_sources(${PACKAGE_LIB} PRIVATE src/init.c src/mpd.c)
link_libraries(-L/usr/local/lib -lmpdclient)

# Install files
install(TARGETS ${PACKAGE_LIB} DESTINATION lib/${PACKAGE_NAME})
install(FILES ${musicpd_BINARY_DIR}/${PACKAGE_INDEX} DESTINATION lib/${PACKAGE_NAME})
install(FILES ${musicpd_BINARY_DIR}/musicpd.tk DESTINATION lib/${PACKAGE_NAME})
