cmake_minimum_required (VERSION 3.20)

# Project identification
project ("tclshmem")
set(PACKAGE_NAME "tclshmem")
set(PACKAGE_VERSION "0.1")
set(PACKAGE_PROVIDE "SharedMem")
set(PACKAGE_INDEX "pkgIndex.tcl")
set(PACKAGE_LIB ${PACKAGE_NAME}${PACKAGE_VERSION})
set(CMAKE_C_COMPILER "/usr/bin/cc")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
message (STATUS "*** Building ${PACKAGE_NAME} ${PACKAGE_VERSION} ***")

find_package(TCL)
add_library(${PACKAGE_LIB} SHARED)
target_sources(${PACKAGE_LIB} 
PRIVATE src/init.c src/shmem.c
)
install(TARGETS ${PACKAGE_LIB} DESTINATION lib/${PACKAGE_NAME}-${PACKAGE_VERSION})
install(FILES ${tclshmem_BINARY_DIR}/${PACKAGE_INDEX} DESTINATION lib/${PACKAGE_NAME}-${PACKAGE_VERSION})

include_directories(/usr/local/include ${TCL_INCLUDE_PATH})

# Project config file
configure_file(${tclshmem_SOURCE_DIR}/src/config.h.in ${tclshmem_BINARY_DIR}/src/config.h)
configure_file(${tclshmem_SOURCE_DIR}/tcl/pkgIndex.tcl.in ${tclshmem_BINARY_DIR}/${PACKAGE_INDEX})
add_definitions(-I ${tclshmem_BINARY_DIR}/src)
