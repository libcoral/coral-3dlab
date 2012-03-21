################################################################################
# Call this script from within your build dir to get all project dependencies.
# For instance, starting at the source tree root:
#	mkdir build && cd build
#	cmake -P ../dependencies/build.cmake
# Dependencies are built into a subdir "dependencies", which is then
# automatically detected and used by the main project.
################################################################################

set( BIN_DIR "dependencies/tmp" )

file( MAKE_DIRECTORY ${BIN_DIR} )
get_filename_component( SRC_DIR ${CMAKE_SCRIPT_MODE_FILE} PATH )

if( APPLE )
	set( CMAKE_ARGS -G Xcode )
endif()

execute_process(
	COMMAND cmake ${CMAKE_ARGS} ${SRC_DIR}
	WORKING_DIRECTORY ${BIN_DIR}
)

execute_process(
	COMMAND cmake --build .
	WORKING_DIRECTORY ${BIN_DIR}
)
