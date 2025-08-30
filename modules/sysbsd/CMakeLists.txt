cmake_minimum_required (VERSION 3.20)

# Project identification
project ("sysbsd")
set(PACKAGE_NAME "sysbsd")
set(PACKAGE_VERSION "0.6")
set(PACKAGE_PROVIDE "sysbsd")
set(PACKAGE_INDEX "pkgIndex.tcl")
set(PACKAGE_LIB ${PACKAGE_NAME}${PACKAGE_VERSION})
set(CMAKE_C_COMPILER "/usr/bin/cc")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
message (STATUS "*** Building ${PACKAGE_NAME} ${PACKAGE_VERSION} ***")

# Tcl version
set(TCL_LIBRARY_VERSION "9.0")
set(TCL_INCLUDE_PATH "/usr/local/include/tcl9.0")

# Substitute some variable names
configure_file(${sysbsd_SOURCE_DIR}/src/config.h.in ${sysbsd_BINARY_DIR}/src/config.h)
configure_file(${sysbsd_SOURCE_DIR}/pkgIndex.tcl ${sysbsd_BINARY_DIR}/${PACKAGE_INDEX})

# Library build
add_definitions(-I ${sysbsd_BINARY_DIR}/src)
add_library(${PACKAGE_LIB} SHARED)
target_sources(${PACKAGE_LIB} PRIVATE src/init.c src/sysbsd.c)
include_directories(/usr/local/include ${TCL_INCLUDE_PATH})

# Install files
install(TARGETS ${PACKAGE_LIB} DESTINATION lib/${PACKAGE_NAME})
install(FILES ${sysbsd_BINARY_DIR}/${PACKAGE_INDEX} DESTINATION lib/${PACKAGE_NAME})
