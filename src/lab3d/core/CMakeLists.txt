################################################################################
# Build the Module
################################################################################

CORAL_GENERATE_MODULE( _MODULE_SOURCES lab3d.core )

INCLUDE_DIRECTORIES( ${CMAKE_CURRENT_SOURCE_DIR} ${OPENSCENEGRAPH_INCLUDE_DIRS} ${CORAL_INCLUDE_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/generated )

FILE( GLOB _SOURCE_FILES *.cpp )
FILE( GLOB _HEADER_FILES *.h )

ADD_LIBRARY( core MODULE ${_HEADER_FILES} ${_SOURCE_FILES} ${_MODULE_SOURCES} )
SET_TARGET_PROPERTIES( core PROPERTIES
	PROJECT_LABEL "core"
	FOLDER "lab3d"
)

TARGET_LINK_LIBRARIES( core ${CORAL_LIBRARIES} ${OPENSCENEGRAPH_LIBRARIES} )

CORAL_MODULE_TARGET( "lab3d.core" core )

INSTALL( DIRECTORY ${CMAKE_BINARY_DIR}/modules/lab3d/core DESTINATION modules PATTERN "_debug" EXCLUDE )

################################################################################
# Source Groups
################################################################################

SOURCE_GROUP( "@Generated" FILES ${_MODULE_SOURCES} )


ADD_SUBDIRECTORY( domain )
ADD_SUBDIRECTORY( scene )
