################################################################################
# Common Build Settings
################################################################################

set_property( DIRECTORY APPEND PROPERTY COMPILE_DEFINITIONS
	"EIGEN_DONT_VECTORIZE"
	"EIGEN_DONT_ALIGN_STATICALLY"
	"EIGEN_DISABLE_UNALIGNED_ARRAY_ASSERT"
)

################################################################################
# Subdirectories
################################################################################

add_subdirectory( lab3d )
add_subdirectory( lab3d.dom )
add_subdirectory( lab3d.scene )
add_subdirectory( lab3d.manipulator )

################################################################################
# Run Target
################################################################################

CORAL_GET_PATH_STRING( CORAL_PATH_STR )
set( RUN_ARGS -p "${CORAL_PATH_STR}" lua.Launcher lab3d.Main
	DEPENDS lab3d lab3d.dom lab3d.scene lab3d.manipulator
)
add_custom_target( run ${CORAL_LAUNCHER} ${RUN_ARGS}
	COMMENT "Starting application..."
)
add_custom_target( run-debug ${CORAL_LAUNCHER} --mode debug ${RUN_ARGS}
	COMMENT "Starting application in Debug mode..."
)

################################################################################
# Install Rules
################################################################################

# Start off with the Coral redistributables, then add our own modules
install(
	DIRECTORY
		"${CORAL_ROOT}/bin"
		"${CORAL_ROOT}/lib"
		"${CORAL_ROOT}/modules"
		"${CMAKE_BINARY_DIR}/modules"
		"${CMAKE_SOURCE_DIR}/modules"
	DESTINATION .
	USE_SOURCE_PERMISSIONS
	PATTERN "*_debug*" EXCLUDE
)

# Re-use the Coral Launcher renamed as '3dlab'
install(
	PROGRAMS "${CORAL_ROOT}/coral${CMAKE_EXECUTABLE_SUFFIX}"
	DESTINATION .
	RENAME "3dlab${CMAKE_EXECUTABLE_SUFFIX}"
)

# Add our coral.properties config file
install( FILES "coral.properties" DESTINATION . )
