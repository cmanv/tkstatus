cmake_minimum_required (VERSION 3.20)

# Project identification
project ("maildir")
set(PACKAGE_NAME "maildir")
set(PACKAGE_VERSION "0.2")
set(PACKAGE_INDEX "pkgIndex.tcl")
set(PACKAGE_LIB lib/${PACKAGE_NAME})

# Tcl version
set(TCL_LIBRARY_VERSION "9.0")
set(TCL_INCLUDE_PATH "/usr/local/include/tcl9.0")

# Substitute some variable names
configure_file(${maildir_SOURCE_DIR}/${PACKAGE_INDEX} ${maildir_BINARY_DIR}/${PACKAGE_INDEX} @ONLY)
configure_file(${maildir_SOURCE_DIR}/maildir.tk ${maildir_BINARY_DIR}/maildir.tk @ONLY)

# Install files
install(FILES ${maildir_BINARY_DIR}/${PACKAGE_INDEX} DESTINATION ${PACKAGE_LIB})
install(FILES ${maildir_BINARY_DIR}/maildir.tk DESTINATION ${PACKAGE_LIB})
