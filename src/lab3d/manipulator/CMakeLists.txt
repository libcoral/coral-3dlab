################################################################################
# Build the Module
################################################################################

CORAL_GENERATE_MODULE( _MODULE_SOURCES lab3d.manipulator )

INCLUDE_DIRECTORIES( ${CMAKE_CURRENT_SOURCE_DIR} ${OPENSCENEGRAPH_INCLUDE_DIRS} ${CORAL_INCLUDE_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/generated )

FILE( GLOB _SOURCE_FILES *.cpp )
FILE( GLOB _HEADER_FILES *.h )

ADD_LIBRARY( manipulator MODULE ${_HEADER_FILES} ${_SOURCE_FILES} ${_MODULE_SOURCES} )
SET_TARGET_PROPERTIES( manipulator PROPERTIES
	PROJECT_LABEL "manipulator"
	FOLDER "lab3d"
)

CORAL_MODULE_TARGET( "lab3d.manipulator" manipulator )

INSTALL( DIRECTORY ${CMAKE_BINARY_DIR}/modules/lab3d/manipulator DESTINATION modules PATTERN "_debug" EXCLUDE )
