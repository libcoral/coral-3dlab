#include "GraphicsContext.h"
#include <qt/IGLContext.h>
#include <osg/State>

GraphicsContext::GraphicsContext() : _glContext( 0 )
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

void GraphicsContext::setUserContext( qt::IGLContext* context )
{
	_glContext = context;
}

void GraphicsContext::update()
{
	if( valid() )
		_glContext->update();
}

bool GraphicsContext::valid() const
{
	return _glContext != 0;
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
	bool isValid = valid();
	if( isValid )
		_glContext->makeCurrent();
	return isValid;
}

bool GraphicsContext::makeContextCurrentImplementation( osg::GraphicsContext* readContext )
{
	assert( readContext == this );
	return makeCurrentImplementation();
}

bool GraphicsContext::releaseContextImplementation()
{
	return true;
}

void GraphicsContext::bindPBufferToTextureImplementation( GLenum buffer )
{
	// NYI
	assert( false );
}

void GraphicsContext::swapBuffersImplementation()
{
	// ignored
}
