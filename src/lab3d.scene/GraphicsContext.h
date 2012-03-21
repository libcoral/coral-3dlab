#ifndef _GRAPHICSCONTEXT_H_
#define _GRAPHICSCONTEXT_H_

#include <co/RefPtr.h>
#include <osg/GraphicsContext>

namespace qt
{
	class IGLContext;
}

class GraphicsContext : public osg::GraphicsContext
{
public:
	GraphicsContext();

	//! Sets wrapped external context (decouples qt module from app module)
	void setUserContext( qt::IGLContext* context );
	qt::IGLContext* getUserContext() { return _glContext.get(); }

	// qt::IGLContext update method
	void update();

	// osg::GraphicsContext methods:
	virtual bool valid() const;
	virtual bool realizeImplementation();
	virtual bool isRealizedImplementation() const;
	virtual void closeImplementation();
	virtual bool makeCurrentImplementation();
	virtual bool makeContextCurrentImplementation( osg::GraphicsContext* readContext );
	virtual bool releaseContextImplementation();
	virtual void bindPBufferToTextureImplementation( GLenum buffer );
	virtual void swapBuffersImplementation();

private:
	co::RefPtr<qt::IGLContext> _glContext;
};

#endif // _GRAPHICSCONTEXT_H_
