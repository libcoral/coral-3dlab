#include "GLFBObject.h"
#include <iostream>

GLFBObject::GLFBObject( int width, int height )
{
    _width = width;
    _height = height;
    _targetTextureId = 0;
    _frameBufferObjId = 0;
    _initialized = false;
    _enabled = false;
}

GLFBObject::~GLFBObject()
{
    if( isInitialized() )
    {
        glDeleteFramebuffers(1, &_frameBufferObjId );
        glDeleteTextures( 1, &_targetTextureId );
    }
}

bool GLFBObject::initialize()
{
    if( isInitialized() )
        return true;
    
    glEnable( GL_TEXTURE_2D );
    
    // creates and binds the framebuffer object, which groups 0, 1, or more textures, and 0 or 1 depth buffer.
    glGenFramebuffers( 1, &_frameBufferObjId );
    glGenTextures( 1, &_targetTextureId );

    // bind the newly created texture
    glBindTexture( GL_TEXTURE_2D, _targetTextureId );
    
    // give an empty image to OpenGL, to be assigned to framebuffer object
    glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA32F_ARB, _width, _height, 0, GL_RGBA, GL_FLOAT, 0 );
    
    // poor filtering
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
    
    enable();
    
    // Set "renderedTexture" as our colour attachement #0
    glFramebufferTexture2DEXT( GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, _targetTextureId, 0 );
    
    // Always check that our framebuffer is ok
    if( glCheckFramebufferStatus( GL_FRAMEBUFFER_EXT ) != GL_FRAMEBUFFER_COMPLETE )
        return false;
    
    //! disable FBO texture
    glBindTexture( GL_TEXTURE_2D, 0 );
    
    _initialized = true;
    
    return true;
}

void GLFBObject::enable()
{
    glBindFramebuffer( GL_FRAMEBUFFER_EXT, _frameBufferObjId );
    _enabled = true;
}

void GLFBObject::disable()
{
    glBindFramebuffer( GL_FRAMEBUFFER_EXT, 0 );
    _enabled = false;
}

void GLFBObject::copyTexture( float* buffer )
{
    bool currentlyEnabled = isEnabled();
    enable();
    
    glReadBuffer( GL_COLOR_ATTACHMENT0_EXT );
    glReadPixels( 0, 0, _width, _height, GL_RGBA, GL_FLOAT, buffer );
    
    if( !currentlyEnabled )
        disable();
}

