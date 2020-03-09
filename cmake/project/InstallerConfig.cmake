# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# In this file, you give your instructions to build your package installer for
# your binaries and sources. To know how to fill this file, please see cmake
# documentation of `CPack()` (https://cmake.org/cmake/help/latest/module/CPack.html).
# By default, all variables are initialized with project values. It is suggested to
# keep them and supplement them with additionnal instructions.
#
# Warning: Don't edit CPACK_OUTPUT_CONFIG_FILE and CPACK_SOURCE_OUTPUT_CONFIG_FILE
# to keep default values or you will get an error.

set(CPACK_SYSTEM_NAME                   "${SYSTEM_NAME}")
set(CPACK_TOPLEVEL_TAG                  "")
set(CPACK_PACKAGE_NAME                  "${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}-${CMAKE_SYSTEM_NAME}")
string(TOLOWER "${CPACK_PACKAGE_NAME}" CPACK_PACKAGE_NAME)
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY   "${${PROJECT_NAME}_SUMMARY}")
set(CPACK_PACKAGE_VENDOR                "${${PROJECT_NAME}_VENDOR_NAME}")
set(CPACK_PACKAGE_DESCRIPTION_FILE      "${${PROJECT_NAME}_PROJECT_PATH}/README.md")
set(CPACK_RESOURCE_FILE_LICENSE         "${${PROJECT_NAME}_PROJECT_PATH}/LICENSE.md")
set(CPACK_PACKAGE_VERSION_MAJOR         "${${PROJECT_NAME}_VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR         "${${PROJECT_NAME}_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH         "${${PROJECT_NAME}_VERSION_PATCH}")
set(CPACK_PACKAGE_FILE_NAME             "${CPACK_PACKAGE_NAME}")
set(CPACK_PACKAGE_INSTALL_DIRECTORY     "${${PROJECT_NAME}_BIN_PATH}")
set(CPACK_PACKAGE_DIRECTORY             "${${PROJECT_NAME}_BIN_PATH}")
set(CPACK_SOURCE_PACKAGE_FILE_NAME      "${CPACK_PACKAGE_NAME}-source")
set(CPACK_SOURCE_IGNORE_FILES           "")

if(WIN32)
	set(CPACK_GENERATOR         "NSIS")
	set(CPACK_SOURCE_GENERATOR  "NSIS")
	set(CPACK_NSIS_DISPLAY_NAME "${CPACK_PACKAGE_NAME}")
	set(CPACK_NSIS_CONTACT      "${${PROJECT_NAME}_VENDOR_CONTACT}")
	set(CPACK_NSIS_MODIFY_PATH  ON)
elseif(UNIX)
	set(CPACK_GENERATOR         "ZIP")
	set(CPACK_SOURCE_GENERATOR  "ZIP")
elseif(APPLE)
	set(CPACK_GENERATOR         "ZIP")
	set(CPACK_SOURCE_GENERATOR  "ZIP")
endif()