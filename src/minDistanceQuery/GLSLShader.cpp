#include "GLSLShader.h"

#include <cassert>

GLSLShader::GLSLShader( const std::string& vsString, const std::string& fsString ) : _shaderProgramId( -1 )
{
    _vsString = vsString;
    _fsString = fsString;
    cleanup();
}

GLSLShader::~GLSLShader()
{
    cleanup();
}

bool GLSLShader::initialize() 
{
    if( isInitialized() ) 
        return true;
        
    GLuint fragment = glCreateShader( GL_FRAGMENT_SHADER );	
    const char* fs = _fsString.c_str();
    
    printf( "FS SHADER = %s\n" , fs );
    fflush( stdout );
    assert( fs != 0 ); // this should not fail (did you set work dir to siviep root?)
    
    glShaderSource( fragment, 1, &fs, NULL );
    
    GLuint vertex = glCreateShader( GL_VERTEX_SHADER );	
    const char* vs = _vsString.c_str();
    
    printf( "VS SHADER = %s\n" , vs );
    fflush( stdout );
    glShaderSource( vertex, 1, &vs, NULL );

    glCompileShader( fragment );
    glCompileShader( vertex );
    
    _shaderProgramId = glCreateProgram();
    glAttachShader( _shaderProgramId, fragment );
    glAttachShader( _shaderProgramId, vertex );
    
    glLinkProgram( _shaderProgramId );
    
    std::string msg;
    if( getLinkStatus( msg ) )
    {
        return true;
    }
    else
    {
        printf( "GLShader error: %s\n", msg.c_str() );
        fflush( stdout );
        _shaderProgramId = -1;
    }
    
    return false;
}

void GLSLShader::enable()
{
    glUseProgram( _shaderProgramId );
    _enabled = true;
}

void GLSLShader::disable()
{
    glUseProgram( 0 );
    _enabled = false;
}

bool GLSLShader::getCompileStatus( std::string& errorMessage )
{
    GLint isCompiled;
    glGetShaderiv( _shaderProgramId, GL_COMPILE_STATUS, &isCompiled );
    if( isCompiled == 0 )
    {
        GLint maxLength;
        glGetShaderiv( _shaderProgramId, GL_INFO_LOG_LENGTH, &maxLength );
        if( maxLength > 0 )
        {
            // maxLength includes the NULL character
            char* vertexInfoLog = new char[maxLength];
            glGetShaderInfoLog( _shaderProgramId, maxLength, &maxLength, vertexInfoLog );
            errorMessage = vertexInfoLog;
            delete[] vertexInfoLog;
            
            return false;
        }
    }
    
    return true;
}

bool GLSLShader::reload()
{
    disable();
    cleanup();
    return initialize();
}

bool GLSLShader::getLinkStatus( std::string& errorMessage )
{
    GLint isLinked;
    glGetProgramiv( _shaderProgramId, GL_LINK_STATUS, &isLinked );
    if( isLinked == 0 )
    {
        GLint maxLength;
        glGetProgramiv( _shaderProgramId, GL_INFO_LOG_LENGTH, &maxLength );
        if( maxLength > 0 )
        {
            // maxLength includes the NULL character
            char *pLinkInfoLog = new char[maxLength];
            glGetProgramInfoLog( _shaderProgramId, maxLength, &maxLength, pLinkInfoLog );
            errorMessage = pLinkInfoLog;
            delete[] pLinkInfoLog;
            
            return false;
        }
    }
    
    return true;
}

//! Loads a 4 dimensional matrix with the given name.
void GLSLShader::setMatrix4( const char* name, const float* matrix )
{
    GLint location = glGetUniformLocation( _shaderProgramId, name );
    glUniformMatrix4fv( location, 1, false, matrix );
}

void GLSLShader::setUniform3( const char* name, double x, double y, double z )
{
    GLint location = glGetUniformLocation( _shaderProgramId, name );
    glUniform3f( location, x, y, z );
}

void GLSLShader::setUniform( const char* name, double value )
{
    GLint location = glGetUniformLocation( _shaderProgramId, name );
    glUniform1f( location, value );
}

char* GLSLShader::textFileRead( const char* filename )
{
    FILE *fp;
    int count = 0;
    char *content = NULL;
    
    if( filename != NULL ) 
    {
        fp = fopen( filename, "rt" );
        
        if( fp != NULL ) 
        {                
            fseek( fp, 0, SEEK_END );
            count = ftell(fp);
            rewind( fp );
            
            if( count > 0 )
            {
                content = new char[ count+1 ];
                count = fread( content,sizeof(char), count, fp );
                content[count] = '\0';
            }
            fclose( fp );
        }
    }
    
    return content;
}

void GLSLShader::cleanup()
{
    if( isInitialized() )
    {
        glDeleteProgram( _shaderProgramId );
        _shaderProgramId = -1;
    }
    _enabled = false;
}
