#if defined(__APPLE__) && defined(__GNUC__)
	#include <OpenGL/gl.h>
	#include <OpenGL/glu.h>
#else
	#if defined(_WIN32) || defined(__WIN32__)
		#include <windows.h>
	#endif
	#include <GL/gl.h>
	#include <GL/glu.h>
#endif