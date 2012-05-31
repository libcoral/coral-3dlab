#include "GraphicsContext.h"
#include <osg/State>

#include <cassert>

GraphicsContext::GraphicsContext()
{
	_traits = new GraphicsContext::Traits;

	// initializes using default 1024x768 size
	// this changes when resize event occurs
	_traits->x = 0;
	_traits->y = 0;

	_traits->width = 1024;
	_traits->height = 768;

	setState( new osg::State );
	getState()->setGraphicsContext( this );

	if( _traits->sharedContext )
	{
		getState()->setContextID( _traits->sharedContext->getState()->getContextID() );
		incrementContextIDUsageCount( getState()->getContextID() );
	}
	else
	{
		getState()->setContextID( osg::GraphicsContext::createNewContextID() );
	}
}

void GraphicsContext::update()
{
	// empty
}

bool GraphicsContext::valid() const
{
	return true;
}

bool GraphicsContext::realizeImplementation()
{
	return true;
}

bool GraphicsContext::isRealizedImplementation() const
{
	return true;
}

void GraphicsContext::closeImplementation()
{
	// empty
}

bool GraphicsContext::makeCurrentImplementation()
{
	return true;
}

bool GraphicsContext::makeContextCurrentImplementation( osg::GraphicsContext* readContext )
{
	return makeCurrentImplementation();
}

bool GraphicsContext::releaseContextImplementation()
{
	return true;
}

void GraphicsContext::bindPBufferToTextureImplementation( GLenum buffer )
{
	// Not supported
	assert( false );
}

void GraphicsContext::swapBuffersImplementation()
{
	// ignored
}
