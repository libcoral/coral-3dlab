################################################################################
# Module lab3d.ui
################################################################################

coral_generate_module( _GENERATED_FILES lab3d.ui
	lab3d.dom.IProject
	lab3d.dom.IWorkspace
	blue.open.render.IScreenProvider
	blue.open.basic.render.PerspectiveProvider 
	blue.open.basic.render.IPerspectiveConfigurator
)

include_directories( "${CMAKE_CURRENT_BINARY_DIR}/generated" )

file( GLOB _SOURCE_FILES *.cpp )
file( GLOB _HEADER_FILES *.h )

add_library( lab3d.ui MODULE ${_HEADER_FILES} ${_SOURCE_FILES} ${_GENERATED_FILES} )

coral_module_target( "lab3d.ui" lab3d.ui )

################################################################################
# Source Groups
################################################################################

source_group( "@Generated" FILES ${_GENERATED_FILES} )
