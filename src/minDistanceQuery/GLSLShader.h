#ifndef _GLSL_SHADER_H_
#define _GLSL_SHADER_H_

#include "glew_portable.h"

#include <string>

class GLSLShader
{
public:
    GLSLShader( const std::string& vsString, const std::string& fsString );
    
    ~GLSLShader();
    
    //! Creates, loads and compiles shaders and returns whether the process was sucessfull.
    bool initialize();
    
    //! Retrieves whether shaders were sucessfully initialized.
    bool isInitialized() { return _shaderProgramId != -1; }
    
    //! Enables vertex and fragment shader in the current OpenGL context.
    void enable();
    bool isEnabled() { return _enabled; }
    
    //! Disables vertex and fragment shader in the current OpenGL context.
    void disable();
    
    //! Loads a 4 dimensional matrix with the given name.
    void setMatrix4( const char* name, const float* matrix );
    
    //! Sets a 3-dimensional variable with the using the given name.
    void setUniform3( const char* name, double x, double y, double z );
    
    //! Sets a 1-dimensional double variable.
    void setUniform( const char* name, double value );
    
    //! Reload shaders from disk and performs a clean initialization.
    //! Returns true if it successfully reloads shaders.
    bool reload();
    
    //! Retrieves latest GLSL compilation status. Returns true if compilation was sucessfull.
    bool getCompileStatus( std::string& errorMessage );
    
    //! Retrieves lastes GLSL linking status. Returns true if linking was sucessfull.
    bool getLinkStatus( std::string& errorMessage );
    
private:
    char* textFileRead( const char* filename );
    void cleanup();
    
private:
    bool _enabled;
    GLuint _shaderProgramId;
    std::string _vsString;
    std::string _fsString;
};

#endif
