cmake_minimum_required (VERSION 3.20)

# Project identification
project ("musicpd")
set(PACKAGE_NAME "musicpd")
set(PACKAGE_VERSION "0.3")
set(PACKAGE_PROVIDE "MPD")
set(PACKAGE_INDEX "pkgIndex.tcl")
set(PACKAGE_LIB ${PACKAGE_NAME}${PACKAGE_VERSION})
set(CMAKE_C_COMPILER "/usr/bin/cc")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
message (STATUS "*** Building ${PACKAGE_NAME} ${PACKAGE_VERSION} ***")

#find_package(TCL)
set(TCL_LIBRARY_VERSION "9.0")
set(TCL_INCLUDE_PATH "/usr/local/include/tcl9.0")

add_library(${PACKAGE_LIB} SHARED)
target_sources(${PACKAGE_LIB} 
PRIVATE src/init.c src/mpd.c
)

# Install files
install(TARGETS ${PACKAGE_LIB} DESTINATION lib/${PACKAGE_NAME})
install(FILES ${musicpd_BINARY_DIR}/${PACKAGE_INDEX} DESTINATION lib/${PACKAGE_NAME})

# Project config file
configure_file(${musicpd_SOURCE_DIR}/src/config.h.in ${musicpd_BINARY_DIR}/src/config.h)
configure_file(${musicpd_SOURCE_DIR}/tcl/pkgIndex.tcl.in ${musicpd_BINARY_DIR}/${PACKAGE_INDEX})
add_definitions(-I ${musicpd_BINARY_DIR}/src)

# Include files
include_directories(/usr/local/include/mpd ${TCL_INCLUDE_PATH})
# Linker options
link_libraries(-L/usr/local/lib -lmpdclient)
