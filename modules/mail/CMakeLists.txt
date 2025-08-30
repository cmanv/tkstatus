cmake_minimum_required (VERSION 3.20)

# Project identification
project ("mail")
set(PACKAGE_NAME "mail")
set(PACKAGE_VERSION "0.2")
set(PACKAGE_INDEX "pkgIndex.tcl")
set(PACKAGE_LIB lib/${PACKAGE_NAME})

# Tcl version
set(TCL_LIBRARY_VERSION "9.0")
set(TCL_INCLUDE_PATH "/usr/local/include/tcl9.0")

# Substitute some variable names
configure_file(${mail_SOURCE_DIR}/${PACKAGE_INDEX} ${mail_BINARY_DIR}/${PACKAGE_INDEX} @ONLY)
configure_file(${mail_SOURCE_DIR}/mail.tk ${mail_BINARY_DIR}/mail.tk @ONLY)

# Install files
install(FILES ${mail_BINARY_DIR}/${PACKAGE_INDEX} DESTINATION ${PACKAGE_LIB})
install(FILES ${mail_BINARY_DIR}/mail.tk DESTINATION ${PACKAGE_LIB})
