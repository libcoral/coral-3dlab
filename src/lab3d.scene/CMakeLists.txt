################################################################################
# Module lab3d.scene
################################################################################

find_package( OpenGL REQUIRED )
find_package( OpenSceneGraph 2.0 REQUIRED osgGA osgDB osgUtil osgViewer )

CORAL_GENERATE_MODULE( _MODULE_SOURCES lab3d.scene lab3d.dom.BoundingBox )

include_directories(
	${OPENSCENEGRAPH_INCLUDE_DIRS}
	"${CMAKE_CURRENT_BINARY_DIR}/generated"
)

file( GLOB _SOURCE_FILES *.cpp )
file( GLOB _HEADER_FILES *.h )

add_library( lab3d.scene MODULE ${_HEADER_FILES} ${_SOURCE_FILES} ${_MODULE_SOURCES} )

CORAL_MODULE_TARGET( "lab3d.scene" lab3d.scene )

target_link_libraries( lab3d.scene ${OPENSCENEGRAPH_LIBRARIES} )

################################################################################
# Source Groups
################################################################################

SOURCE_GROUP( "@Generated" FILES ${_MODULE_SOURCES} )
