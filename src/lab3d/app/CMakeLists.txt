################################################################################
# Build the Module
################################################################################

CORAL_GENERATE_MODULE( _MODULE_SOURCES lab3d.app )

INCLUDE_DIRECTORIES( ${CMAKE_CURRENT_SOURCE_DIR} ${OPENSCENEGRAPH_INCLUDE_DIRS} ${CORAL_INCLUDE_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/generated )

FILE( GLOB _SOURCE_FILES *.cpp )
FILE( GLOB _HEADER_FILES *.h )

ADD_LIBRARY( app MODULE ${_HEADER_FILES} ${_SOURCE_FILES} ${_MODULE_SOURCES} )
SET_TARGET_PROPERTIES( app PROPERTIES
	PROJECT_LABEL "app"
	FOLDER "lab3d"
)

TARGET_LINK_LIBRARIES( app ${CORAL_LIBRARIES} ${OPENSCENEGRAPH_LIBRARIES} )

CORAL_MODULE_TARGET( "lab3d.app" app )

INSTALL( DIRECTORY ${CMAKE_BINARY_DIR}/modules/lab3d/app DESTINATION modules PATTERN "_debug" EXCLUDE )

################################################################################
# Source Groups
################################################################################

SOURCE_GROUP( "@Generated" FILES ${_MODULE_SOURCES} )

ADD_SUBDIRECTORY( manipulator )
