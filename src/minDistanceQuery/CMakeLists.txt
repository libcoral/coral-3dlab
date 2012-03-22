################################################################################
# Build the Module
################################################################################

find_package( OpenGL REQUIRED )

CORAL_GENERATE_MODULE( _MODULE_SOURCES minDistanceQuery lab3d.scene.IDrawer )

INCLUDE_DIRECTORIES( ${CMAKE_CURRENT_SOURCE_DIR} ${OPENGL_INCLUDE_DIR} ${CORAL_INCLUDE_DIRS} ${CMAKE_CURRENT_BINARY_DIR}/generated )

FILE( GLOB _SOURCE_FILES *.cpp *.c )
FILE( GLOB _HEADER_FILES *.h )

ADD_DEFINITIONS( -DGLEW_NO_GLU -DGLEW_STATIC )

ADD_LIBRARY( minDistanceQuery MODULE ${_HEADER_FILES} ${_SOURCE_FILES} ${_MODULE_SOURCES} )
SET_TARGET_PROPERTIES( minDistanceQuery PROPERTIES
	PROJECT_LABEL "minDistanceQuery"
)

TARGET_LINK_LIBRARIES( minDistanceQuery ${CORAL_LIBRARIES} ${OPENGL_LIBRARIES} )

CORAL_MODULE_TARGET( "minDistanceQuery" minDistanceQuery )

INSTALL( DIRECTORY ${CMAKE_BINARY_DIR}/modules/minDistanceQuery DESTINATION modules PATTERN "_debug" EXCLUDE )

################################################################################
# Source Groups
################################################################################

SOURCE_GROUP( "@Generated" FILES ${_MODULE_SOURCES} )
