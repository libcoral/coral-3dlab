################################################################################
# SiVIEP - Coral 3d lab Project
################################################################################

CMAKE_MINIMUM_REQUIRED( VERSION 2.6 )

PROJECT( CORAL3DLAB )

################################################################################
# Setup Coral 3d lab
################################################################################

# Add Coral's cmake dir to the CMAKE_MODULE_PATH
FILE( TO_CMAKE_PATH "$ENV{CORAL_ROOT}" CORAL_ROOT )
SET( CMAKE_MODULE_PATH ${CORAL_ROOT}/cmake ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH} )

FIND_PACKAGE( Coral REQUIRED )

# Export environment variable CORAL_PATH to a cmake variable
FILE( TO_CMAKE_PATH "$ENV{CORAL_PATH}" ENV_CORAL_PATH )

# Configure the coral path
SET( CORAL_PATH
	"${CORAL_ROOT}/modules"
	"${CMAKE_BINARY_DIR}/modules"
	"${CMAKE_SOURCE_DIR}/modules"
)

################################################################################
# Global Setup
################################################################################

#GLM
FIND_PATH( CORAL_EIGEN_INCLUDE_DIR Eigen/Dense
  PATH_SUFFIXES 
  ../include/
  ../coral-eigen/include/
  PATHS
 ${ENV_CORAL_PATH}
 ${CORAL_ROOT}
  NO_DEFAULT_PATH
)

INCLUDE_DIRECTORIES( ${CMAKE_CURRENT_SOURCE_DIR} ${CORAL_INCLUDE_DIRS} ${CORAL_EIGEN_INCLUDE_DIR} )

# Request OpenGL support
FIND_PACKAGE( OpenGL REQUIRED )
FIND_PACKAGE( OpenSceneGraph 2.0 REQUIRED osgGA osgDB osgUtil osgViewer )

################################################################################
# Packaging
################################################################################
SET( CPACK_PACKAGE_NAME					"Coral 3D Lab" )
SET( CPACK_PACKAGE_VENDOR				"Tecgraf/PUC-Rio" )
SET( CPACK_PACKAGE_VERSION_MAJOR		"0" )
SET( CPACK_PACKAGE_VERSION_MINOR		"0" )	# Sprint number
SET( CPACK_PACKAGE_VERSION_PATCH		"0" )
SET( CPACK_PACKAGE_DESCRIPTION_SUMMARY	"3D Visualization Browser Application for Coral Learning and Collaboration " )

IF( WIN32 )
	SET( CPACK_GENERATOR "ZIP" )
ELSE()
	SET( CPACK_GENERATOR "TBZ2" )
ENDIF()

# install CSL files
INSTALL( DIRECTORY ${CMAKE_SOURCE_DIR}/modules DESTINATION ./ PATTERN ".git" EXCLUDE )

MACRO( ADD_INSTALL_MODULE MODULE_NAME )
	#install other modules that coral-3dlab uses
	SET( MODULE_DIRS "" )
	SET( CURRENT_MODULE_DIR "" )
	FOREACH( REPOSITORY ${ENV_CORAL_PATH} )
		SET( CURRENT_MODULE_DIR "${REPOSITORY}/${MODULE_NAME}" )
		IF( EXISTS ${CURRENT_MODULE_DIR} )
			INSTALL( DIRECTORY ${REPOSITORY} DESTINATION modules/ PATTERN ".git" EXCLUDE PATTERN "_debug" EXCLUDE )
		ENDIF()
	ENDFOREACH()
ENDMACRO( ADD_INSTALL_MODULE )

INSTALL( DIRECTORY ${MODULE_DIRS} DESTINATION "modules/" PATTERN "_debug" EXCLUDE )

ADD_INSTALL_MODULE( "coOsg" )
ADD_INSTALL_MODULE( "eigen" )
ADD_INSTALL_MODULE( "qt" )

#coral base modules
INSTALL( DIRECTORY ${CORAL_ROOT}/modules DESTINATION ./ PATTERN ".git" EXCLUDE )
#coral librarie
INSTALL( DIRECTORY ${CORAL_ROOT}/lib DESTINATION ./ PATTERN ".git" EXCLUDE PATTERN "_debug" EXCLUDE )
#coral executables
INSTALL( DIRECTORY ${CORAL_ROOT}/bin FILE_PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_READ WORLD_READ WORLD_EXECUTE DESTINATION ./ PATTERN ".git" EXCLUDE PATTERN "_debug" EXCLUDE )
FIND_PROGRAM( CORAL_EXECUTABLE ${CORAL_ROOT}/coral )
INSTALL( FILES ${CORAL_EXECUTABLE} PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_READ WORLD_READ WORLD_EXECUTE DESTINATION ./ ) 

################################################################################
# Subdirectories
################################################################################
INCLUDE( CPack )

ADD_SUBDIRECTORY( src )

#ENABLE_TESTING()

