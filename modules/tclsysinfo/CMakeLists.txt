cmake_minimum_required (VERSION 3.20)

# Project identification
project ("tclsysinfo")
set(PACKAGE_NAME "tclsysinfo")
set(PACKAGE_VERSION "0.5")
set(PACKAGE_PROVIDE "SysInfo")
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
PRIVATE src/init.c src/sysinfo.c
)
install(TARGETS ${PACKAGE_LIB} DESTINATION lib/${PACKAGE_NAME})
install(FILES ${tclsysinfo_BINARY_DIR}/${PACKAGE_INDEX} DESTINATION lib/${PACKAGE_NAME})

include_directories(/usr/local/include ${TCL_INCLUDE_PATH})

# Project config file
configure_file(${tclsysinfo_SOURCE_DIR}/src/config.h.in ${tclsysinfo_BINARY_DIR}/src/config.h)
configure_file(${tclsysinfo_SOURCE_DIR}/tcl/pkgIndex.tcl.in ${tclsysinfo_BINARY_DIR}/${PACKAGE_INDEX})
add_definitions(-I ${tclsysinfo_BINARY_DIR}/src)
