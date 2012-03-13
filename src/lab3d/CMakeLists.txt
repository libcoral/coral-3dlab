################################################################################
# Build the Module
################################################################################

CORAL_GENERATE_MODULE( _MODULE_SOURCES lab3d )

INCLUDE_DIRECTORIES( ${CMAKE_CURRENT_SOURCE_DIR} ${OPENSCENEGRAPH_INCLUDE_DIRS} ${CORAL_INCLUDE_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/generated )

FILE( GLOB _SOURCE_FILES *.cpp )
FILE( GLOB _HEADER_FILES *.h )

ADD_LIBRARY( lab3d MODULE ${_HEADER_FILES} ${_SOURCE_FILES} ${_MODULE_SOURCES} )
SET_TARGET_PROPERTIES( lab3d PROPERTIES
	PROJECT_LABEL "lab3d"
	FOLDER "lab3d"
)

TARGET_LINK_LIBRARIES( lab3d ${CORAL_LIBRARIES} ${OPENSCENEGRAPH_LIBRARIES} )

CORAL_MODULE_TARGET( "lab3d" lab3d )

INSTALL( DIRECTORY ${CMAKE_BINARY_DIR}/modules/lab3d/ DESTINATION modules PATTERN "_debug" EXCLUDE )

################################################################################
# Source Groups
################################################################################

SOURCE_GROUP( "@Generated" FILES ${_MODULE_SOURCES} )

################################################################################
# Subdirectories
################################################################################

ADD_SUBDIRECTORY( dom )
ADD_SUBDIRECTORY( scene )
ADD_SUBDIRECTORY( manipulator )

