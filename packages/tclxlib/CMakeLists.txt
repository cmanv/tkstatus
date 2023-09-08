cmake_minimum_required (VERSION 3.20)

# Project identification
project ("tclxlib")
set(PACKAGE_NAME "tclxlib")
set(PACKAGE_VERSION "0.5")
set(PACKAGE_PROVIDE "XLib")
set(PACKAGE_INDEX "pkgIndex.tcl")
set(PACKAGE_LIB ${PACKAGE_NAME}${PACKAGE_VERSION})
set(CMAKE_C_COMPILER "/usr/bin/cc")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
message (STATUS "*** Building ${PACKAGE_NAME} ${PACKAGE_VERSION} ***")

# Packages
find_package(TCL)
find_package(X11)

# Include files
include_directories(/usr/local/include ${X11_INCLUDE_DIR} ${TCL_INCLUDE_PATH})

# Project config file
configure_file(${tclxlib_SOURCE_DIR}/src/config.h.in ${tclxlib_BINARY_DIR}/src/config.h)
configure_file(${tclxlib_SOURCE_DIR}/tcl/pkgIndex.tcl.in ${tclxlib_BINARY_DIR}/${PACKAGE_INDEX})
add_definitions(-I ${tclxlib_BINARY_DIR}/src)

# Targets
add_library(${PACKAGE_LIB} SHARED)
target_sources(${PACKAGE_LIB} 
PRIVATE src/init.c src/xlib.c
)

# Linker options
link_libraries(-L/usr/local/lib ${X11_LIBRARIES})

# Install files
install(TARGETS ${PACKAGE_LIB} DESTINATION lib/${PACKAGE_NAME}-${PACKAGE_VERSION})
install(FILES ${tclxlib_BINARY_DIR}/${PACKAGE_INDEX} DESTINATION lib/${PACKAGE_NAME}-${PACKAGE_VERSION})
