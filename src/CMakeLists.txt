# Export environment variable CORAL_PATH to a cmake variable
FILE( TO_CMAKE_PATH "$ENV{CORAL_PATH}" ENV_CORAL_PATH )

set_property( DIRECTORY APPEND PROPERTY COMPILE_DEFINITIONS "EIGEN_DONT_VECTORIZE" )
set_property( DIRECTORY APPEND PROPERTY COMPILE_DEFINITIONS "EIGEN_DISABLE_UNALIGNED_ARRAY_ASSERT" )
set_property( DIRECTORY APPEND PROPERTY COMPILE_DEFINITIONS "EIGEN_DONT_ALIGN_STATICALLY" )

################################################################################
# Subdirectories
################################################################################

ADD_SUBDIRECTORY( lab3d )
