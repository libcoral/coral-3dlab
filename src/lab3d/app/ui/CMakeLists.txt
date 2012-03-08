################################################################################
# Build the Module
################################################################################

CORAL_GENERATE_MODULE( _MODULE_SOURCES lab3d.app.ui )

INCLUDE_DIRECTORIES( ${CMAKE_CURRENT_SOURCE_DIR} ${OPENSCENEGRAPH_INCLUDE_DIRS} ${CORAL_INCLUDE_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/generated )

FILE( GLOB _SOURCE_FILES *.cpp )
FILE( GLOB _HEADER_FILES *.h )

ADD_LIBRARY( ui MODULE ${_HEADER_FILES} ${_SOURCE_FILES} ${_MODULE_SOURCES} )
SET_TARGET_PROPERTIES( ui PROPERTIES
	PROJECT_LABEL "ui"
	FOLDER "lab3d.app"
)

TARGET_LINK_LIBRARIES( ui ${CORAL_LIBRARIES} )

CORAL_MODULE_TARGET( "lab3d.app.ui" ui )

INSTALL( DIRECTORY ${CMAKE_BINARY_DIR}/modules/coLab/app/ui DESTINATION modules PATTERN "_debug" EXCLUDE )

################################################################################
# Source Groups
################################################################################

SOURCE_GROUP( "@Generated" FILES ${_MODULE_SOURCES} )
