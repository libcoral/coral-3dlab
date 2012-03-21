################################################################################
# Coral 3D Lab Project
################################################################################

cmake_minimum_required( VERSION 2.8 )
project( 3DLAB )

################################################################################
# Setup Coral
################################################################################

if( IS_DIRECTORY "${CMAKE_BINARY_DIR}/dependencies/coral" )
	set( CORAL_ROOT "${CMAKE_BINARY_DIR}/dependencies/coral" )
	message( STATUS "Using internal Coral SDK" )
elseif( NOT CORAL_ROOT )
	file( TO_CMAKE_PATH "$ENV{CORAL_ROOT}" CORAL_ROOT )
endif()

# Load Coral's CMake package
set( CMAKE_MODULE_PATH "${CORAL_ROOT}/cmake" ${CMAKE_MODULE_PATH} )
find_package( Coral REQUIRED )

set( CORAL_PATH ${CORAL_PATH}
	"${CMAKE_BINARY_DIR}/modules"
	"${CMAKE_SOURCE_DIR}/modules"
)

include_directories( ${CORAL_INCLUDE_DIRS} )

################################################################################
# Packaging
################################################################################

set( CPACK_PACKAGE_NAME					"Coral 3D Lab" )
set( CPACK_PACKAGE_VENDOR				"Tecgraf/PUC-Rio" )
set( CPACK_PACKAGE_VERSION_MAJOR		"0" )
set( CPACK_PACKAGE_VERSION_MINOR		"1" )
set( CPACK_PACKAGE_VERSION_PATCH		"0" )
set( CPACK_PACKAGE_DESCRIPTION_SUMMARY	"Sample 3D viewer built on the Coral framework" )

include( CPack )

################################################################################
# Subdirectories
################################################################################

add_subdirectory( src )
