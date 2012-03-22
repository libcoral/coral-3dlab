#ifndef _FB_OBJECT_H_
#define _FB_OBJECT_H_

#include "glew_portable.h"
#include "GL_portable.h"

class GLFBObject
{
    
public:
    //! Creates a FBO using a RGBA float texture of 'width' x 'height' size;
    GLFBObject( int width, int height );
    ~GLFBObject();
    
    bool initialize();
    bool isInitialized() { return _initialized; }
    
    void enable();
    bool isEnabled() { return _enabled; }
    
    void disable();
    
    int getWidth() { return _width; }
    int getHeight() { return _height; }
    
    //! Copies GPU RGBA float texture assigned to this FBO to the given buffer.
    //! The buffer must have at least getWidth() * getWidth() * 4 * sizeof(float) size.
    void copyTexture( float* buffer );
    
private:
    int _width;
    int _height;
    bool _enabled;
    bool _initialized;
    GLuint _targetTextureId;
    GLuint _frameBufferObjId;
};
                  
#endif