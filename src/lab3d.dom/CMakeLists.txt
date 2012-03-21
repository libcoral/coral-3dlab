################################################################################
# Module lab3d.dom
################################################################################

CORAL_GENERATE_MODULE( _MODULE_SOURCES lab3d.dom qt.ISystem qt.ITimerCallback )

include_directories( "${CMAKE_CURRENT_BINARY_DIR}/generated" )

file( GLOB _SOURCE_FILES *.cpp )
file( GLOB _HEADER_FILES *.h )

add_library( lab3d.dom MODULE ${_HEADER_FILES} ${_SOURCE_FILES} ${_MODULE_SOURCES} )

CORAL_MODULE_TARGET( "lab3d.dom" lab3d.dom )

################################################################################
# Source Groups
################################################################################

SOURCE_GROUP( "@Generated" FILES ${_MODULE_SOURCES} )
