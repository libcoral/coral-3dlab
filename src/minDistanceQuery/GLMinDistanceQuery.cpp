#if defined(_WIN32) || defined(__WIN32__)
	// windows.h header file (or more correctly, windef.h that it includes in turn) 
	// has macros for min and max which are interfering.
	#define NOMINMAX
	#define _USE_MATH_DEFINES
#endif

#include "GLMinDistanceQuery_Base.h"

#include "GLSLShader.h"
#include "GLFBObject.h"

#include <lab3d/scene/IDrawer.h>

#include <co/RefPtr.h>

#include "GL_portable.h"
#include "glew_portable.h"

#include <cmath>
#include <float.h>
#include <algorithm>
namespace {
    const float FBO_NULL_VALUE = -1;
    const char* VERTEX_PROGRAM = "uniform mat4 projectionMatrix;"
                                 "uniform mat4 currentViewTransform;"
                                "varying vec3 wcPosition;"
                                "void main()"
                                "{"
                                   "wcPosition = ( currentViewTransform * gl_ModelViewMatrix * gl_Vertex ).xyz;"
                                   "gl_Position = projectionMatrix * gl_ModelViewMatrix * gl_Vertex;"
                                "}";
    const char* FRAGMENT_PROGRAM = "varying vec3 wcPosition;"
                            "uniform vec3 userPosition;"
                            "uniform float near;"
                            "uniform float far;"
                            "void main()"
                            "{"
                                "vec3 fragVector = - wcPosition;"
                                "float distance = length( fragVector );"
                                "float normalizedDist = ( distance - near ) / ( far - near );"
                                "gl_FragColor = vec4( 0, 0, 0, normalizedDist );"
                            "}";

}

namespace minDistanceQuery {
    
enum CameraDirection
{
    Direction_Front     = 0,
    Direction_Back      = 1,
    Direction_Left      = 2,
    Direction_Right     = 3,
    Direction_Top       = 4,
    Direction_Bottom    = 5
};

// builds a 90 degree FOV perspective matrix using aspect = 1
void buildPerspectiveMatrix( float *m, float zNear, float zFar )
{
    float xymax = zNear * tan( M_PI_4 );
    float ymin = -xymax;
    float xmin = -xymax;
    
    float width = xymax - xmin;
    float height = xymax - ymin;
    
    float depth = zFar - zNear;
    float q = -( zFar + zNear) / depth;
    float qn = -2 * ( zFar * zNear ) / depth;
    
    float w = 2 * zNear / width;
    float h = 2 * zNear / height;
    
    m[0]  = w;
    m[1]  = 0;
    m[2]  = 0;
    m[3]  = 0;
    
    m[4]  = 0;
    m[5]  = h;
    m[6]  = 0;
    m[7]  = 0;
    
    m[8]  = 0;
    m[9]  = 0;
    m[10] = q;
    m[11] = -1;
    
    m[12] = 0;
    m[13] = 0;
    m[14] = qn;
    m[15] = 0;
}

    
static void updateShader( GLSLShader& shader, CameraDirection direction, double eyeX, double eyeY, double eyeZ, double zNear, double zFar )
{
    static const float c = cos( M_PI );
    static const float s = sin( M_PI );
    static const float c_2 = cos( M_PI_2 );
    static const float s_2 = sin( M_PI_2 );
    static const float cm_2 = cos( -M_PI_2 );
    static const float sm_2 = sin( -M_PI_2 );
    
    static const float lookMatrices[6][16] = {
            // identity
          { 1,      0,        0,        0,
            0,      1,        0,        0,
            0,      0,        1,        0,
            0,      0,        0,        1 },
            // 180 rotation over x
          { 1,      0,        0,        0,
            0,      c,        -s,       0,
            0,      s,        c,        0,
            0,      0,        0,        1 },
            // 90 over z
          { c,      -s,       0,        0,
            s,      c,        0,        0,
            0,      0,        1,        0,
            0,      0,        0,        1 },
            // minus 90 over z
          { cm_2,   -sm_2,    0,        0,
            sm_2,   cm_2,     0,        0,
            0,      0,        1,        0,
            0,      0,        0,        1 },
            // 90 over x
          { 1,      0,        0,        0,
            0,      c_2,      -s_2,     0,
            0,      s_2,      c_2,      0,
            0,      0,        0,        1 },
            // minus 90 over x
          { 1,      0,        0,        0,
            0,      cm_2,     -sm_2,    0,
            0,      sm_2,     cm_2,     0,
            0,      0,        0,        1 }
    };

    // update shader uniform variables
    shader.setMatrix4( "currentViewTransform", lookMatrices[direction] );
    shader.setUniform3( "userPosition", eyeX, eyeY, eyeZ  );
    shader.setUniform( "near", zNear );
    shader.setUniform( "far", zFar );
    
    
    // setup the projection matrix to be used when generation the cubemap
    float projection[16];
    buildPerspectiveMatrix( projection, static_cast<float>( zNear ), static_cast<float>( zFar ) );
    shader.setMatrix4( "projectionMatrix", projection );
}
    
class GLMinDistanceQuery : public GLMinDistanceQuery_Base
{
public:
    GLMinDistanceQuery() 
        : _initialized( false ), _shader( VERTEX_PROGRAM, FRAGMENT_PROGRAM ), _fbobject( 64, 64 )
    {
        _currentMinDistance = -1;
    }
    
    virtual ~GLMinDistanceQuery()
    {
        // empty
    }
    
    double getMinDistance()
    {
        return _currentMinDistance;
    }
    
    double getMinDistanceForDirection( CameraDirection direction, double eyeX, double eyeY, double eyeZ, double zNear, double zFar )
    {
        glClearColor( 0, 0, 0, FBO_NULL_VALUE );
        glClear( GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT );

        // update shader variables
        updateShader( _shader, direction, eyeX, eyeY, eyeZ, zNear, zFar );
        
        // render the scene
        _drawer->setViewport( 0, 0, 64, 64 );
        _drawer->clear( 0, 0, 0, -1 );
        _drawer->draw();
       // glutSwapBuffers();
        
        // copy 
        _fbobject.copyTexture( &_targetBuffer[0] );
        return extractMinimum( _targetBuffer );
    }

    void update( double eyeX, double eyeY, double eyeZ, double zNear, double zFar )
    {
        if( !_initialized )
            initialize();
        
        glPushAttrib( GL_LIGHTING_BIT );
        glDisable( GL_LIGHTING );
        
        // enable shaders and FBO state
        _shader.enable();
        _fbobject.enable();
        
        double mFront = getMinDistanceForDirection( Direction_Front, eyeX, eyeY, eyeZ, zNear, zFar );
        double mBack = getMinDistanceForDirection( Direction_Back, eyeX, eyeY, eyeZ, zNear, zFar );
        double mLeft = getMinDistanceForDirection( Direction_Left, eyeX, eyeY, eyeZ, zNear, zFar );
        double mRight = getMinDistanceForDirection( Direction_Right, eyeX, eyeY, eyeZ, zNear, zFar );
        double mTop = getMinDistanceForDirection( Direction_Top, eyeX, eyeY, eyeZ, zNear, zFar );
        double mBottom = getMinDistanceForDirection( Direction_Bottom, eyeX, eyeY, eyeZ, zNear, zFar );
        
        _currentMinDistance = std::min( mFront, std::min( mBack, std::min( mLeft, std::min( mRight, std::min( mTop, mBottom ) ) ) ) );

        _shader.disable();
        _fbobject.disable();
        
        glPopAttrib();
    }
    
    lab3d::scene::IDrawer* getDrawerService()
    {
        return _drawer.get();
    }
    
	//! Set the service at receptacle 'drawer', of type siv.scene.IDrawer.
    void setDrawerService( lab3d::scene::IDrawer* drawer )
    {
        _drawer = drawer;
    }
    
private:
    void initialize()
    {
        GLenum err = glewInit();
        if( err != GLEW_OK )
        {
            exit( -1 );
        }

        _fbobject.initialize();
        _shader.initialize();
        
        int bufferSize = 4 * 64 * 64;
        _targetBuffer.resize( bufferSize );
        memset( &_targetBuffer[0], -1, bufferSize * sizeof( float ) );
        _initialized = true;
    }
    
    double extractMinimum( const std::vector<float>& buffer )
    {
       // printImg( buffer );
        
        double min = DBL_MAX;
        for( int i = 0; i < buffer.size() / 4; ++i )
        {
            double value = buffer[4*i+3];
            if( value != FBO_NULL_VALUE && value < min )
                min = value;
        }
        
        if( min == DBL_MAX )
            return FBO_NULL_VALUE;
        
        return min;
    }
    
private:
    bool _initialized;
    GLSLShader _shader;
    GLFBObject _fbobject;
    double _currentMinDistance;
    std::vector<float> _targetBuffer;
    co::RefPtr<lab3d::scene::IDrawer> _drawer;
};

CORAL_EXPORT_COMPONENT( GLMinDistanceQuery, GLMinDistanceQuery );
    
} // namespace minDistanceQuery
