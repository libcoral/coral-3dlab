################################################################################
# Build the Module
################################################################################

CORAL_GENERATE_MODULE( _MODULE_SOURCES lab3d.dom qt.ISystem qt.ITimerCallback )

INCLUDE_DIRECTORIES( ${CMAKE_CURRENT_SOURCE_DIR} ${OPENSCENEGRAPH_INCLUDE_DIRS} ${CORAL_INCLUDE_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/generated )

FILE( GLOB _SOURCE_FILES *.cpp )
FILE( GLOB _HEADER_FILES *.h )

ADD_LIBRARY( dom MODULE ${_HEADER_FILES} ${_SOURCE_FILES} ${_MODULE_SOURCES} )
SET_TARGET_PROPERTIES( dom PROPERTIES
	PROJECT_LABEL "dom"
	FOLDER "lab3d"
)

TARGET_LINK_LIBRARIES( dom ${CORAL_LIBRARIES} ${OPENSCENEGRAPH_LIBRARIES} )

CORAL_MODULE_TARGET( "lab3d.dom" dom )

INSTALL( DIRECTORY ${CMAKE_BINARY_DIR}/modules/lab3d/dom DESTINATION modules PATTERN "_debug" EXCLUDE )

################################################################################
# Source Groups
################################################################################

SOURCE_GROUP( "@Generated" FILES ${_MODULE_SOURCES} )
