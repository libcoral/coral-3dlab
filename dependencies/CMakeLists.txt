################################################################################
# Automagically download and build all project dependencies
################################################################################

cmake_minimum_required( VERSION 2.8.5 )
project( 3DLAB_DEPENDENCIES )

# Settings
set( CORAL_BRANCH "develop" )
set( PREFIX "${CMAKE_CURRENT_BINARY_DIR}" )

set_property( DIRECTORY PROPERTY EP_PREFIX "${PREFIX}" )
if( NOT INSTALL_PREFIX )
	set( INSTALL_PREFIX "${PREFIX}/.." )
endif()

set( CORAL_ROOT "${INSTALL_PREFIX}/coral" )

include( ExternalProject )
include( CMakeParseArguments )

function( CORAL_BUILD name config )
	ExternalProject_Add( "${name}-${config}"
		SOURCE_DIR "${PREFIX}/src/${name}"
		BINARY_DIR "${PREFIX}/src/${name}-${config}"
		DOWNLOAD_COMMAND ""
		CMAKE_ARGS -DCORAL_ROOT=${CORAL_ROOT} -DCMAKE_BUILD_TYPE=${config} -DCMAKE_INSTALL_PREFIX=${CORAL_ROOT}
		BUILD_COMMAND ${CMAKE_COMMAND} --build . --config ${config} --target install
		INSTALL_COMMAND ""
		${ARGN}
	)
endfunction()

function( CORAL_REQUIRE name )
	cmake_parse_arguments( CORAL_REQUIRE "" "" "DEPENDS" ${ARGN} )
	set( ghname "coral" )
	if( NOT name STREQUAL "coral" )
		set( ghname "coral-${name}" )
	endif()
	set( deps "${name}-GetSource" )
	foreach( dep ${CORAL_REQUIRE_DEPENDS} )
		list( APPEND deps "${dep}-Debug" "${dep}-Release" )
	endforeach()
	ExternalProject_Add( "${name}-GetSource"
		SOURCE_DIR "${PREFIX}/src/${name}"
		GIT_REPOSITORY git://github.com/libcoral/${ghname}.git
		GIT_TAG ${CORAL_BRANCH}
		CONFIGURE_COMMAND ""
		BUILD_COMMAND ""
		INSTALL_COMMAND ""
	)
	CORAL_BUILD( ${name} Debug DEPENDS ${deps} )
	CORAL_BUILD( ${name} Release DEPENDS ${deps} )
endfunction()

CORAL_REQUIRE( coral )
CORAL_REQUIRE( calcium DEPENDS coral )
CORAL_REQUIRE( eigen DEPENDS coral )
CORAL_REQUIRE( osg DEPENDS coral )
CORAL_REQUIRE( qt DEPENDS coral )
