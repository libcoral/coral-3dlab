#ifndef _GRAPHICSCONTEXT_H_
#define _GRAPHICSCONTEXT_H_

#include <co/RefPtr.h>
#include <osg/GraphicsContext>

namespace qt
{
	class IGLContext;
}

// Dummy graphics context
class GraphicsContext : public osg::GraphicsContext
{
public:
	GraphicsContext();

	// qt::IGLContext update method
	void update();

	// osg::GraphicsContext methods:
	bool valid() const;
	bool realizeImplementation();
	bool isRealizedImplementation() const;
	void closeImplementation();
	bool makeCurrentImplementation();
	bool makeContextCurrentImplementation( osg::GraphicsContext* readContext );
	bool releaseContextImplementation();
	void bindPBufferToTextureImplementation( GLenum buffer );
	void swapBuffersImplementation();
};

#endif // _GRAPHICSCONTEXT_H_
