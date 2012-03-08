# Export environment variable CORAL_PATH to a cmake variable
FILE( TO_CMAKE_PATH "$ENV{CORAL_PATH}" ENV_CORAL_PATH )

################################################################################
# Subdirectories
################################################################################

ADD_SUBDIRECTORY( app )
ADD_SUBDIRECTORY( core )
