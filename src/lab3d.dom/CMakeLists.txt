################################################################################
# Module lab3d.dom
################################################################################

coral_generate_module( _GENERATED_FILES lab3d.dom )

include_directories( "${CMAKE_CURRENT_BINARY_DIR}/generated" )

file( GLOB _SOURCE_FILES *.cpp )
file( GLOB _HEADER_FILES *.h )

add_library( lab3d.dom MODULE ${_HEADER_FILES} ${_SOURCE_FILES} ${_GENERATED_FILES} )

coral_module_target( "lab3d.dom" lab3d.dom )

################################################################################
# Source Groups
################################################################################

source_group( "@Generated" FILES ${_GENERATED_FILES} )
