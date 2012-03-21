################################################################################
# Automagically download and build all project dependencies
################################################################################

cmake_minimum_required( VERSION 2.8.4 )
include( ExternalProject )

# Settings
set( CORAL_BRANCH "develop" )

set_property( DIRECTORY PROPERTY EP_PREFIX "${CMAKE_CURRENT_BINARY_DIR}" )

if( NOT INSTALL_PREFIX )
	set( INSTALL_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/.." )
endif()

set( CORAL_ROOT "${INSTALL_PREFIX}/coral" )

# Coral
ExternalProject_Add( coral
	GIT_REPOSITORY git://github.com/libcoral/coral.git
	GIT_TAG ${CORAL_BRANCH}
	CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CORAL_ROOT}
	BUILD_COMMAND cmake --build . --config Debug --target install
	INSTALL_COMMAND cmake --build . --config Release --target install --clean-first
)

# Modules
function( CORAL_REQUIRE_MODULE name )
	ExternalProject_Add( ${name}
		GIT_REPOSITORY git://github.com/libcoral/coral-${name}.git
		GIT_TAG ${CORAL_BRANCH}
		CMAKE_ARGS -DCORAL_ROOT=${CORAL_ROOT} -DCMAKE_INSTALL_PREFIX=${CORAL_ROOT}
		BUILD_COMMAND cmake --build . --config Debug --target install
		INSTALL_COMMAND cmake --build . --config Release --target install --clean-first
		${ARGN}
	)
endfunction()

CORAL_REQUIRE_MODULE( calcium DEPENDS coral )
CORAL_REQUIRE_MODULE( eigen DEPENDS coral )
CORAL_REQUIRE_MODULE( osg DEPENDS coral )
CORAL_REQUIRE_MODULE( qt DEPENDS coral )
