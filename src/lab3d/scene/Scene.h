#ifndef _SCENE_H_
#define _SCENE_H_

#include "Scene_Base.h"

#include "GraphicsContext.h"

#include <osg/Material>
#include <osgViewer/Viewer>

#include <co/RefVector.h>

namespace osg
{
    class Image;
    class Camera;
}

namespace lab3d {
namespace domain
{
    class IEntity;
}

namespace scene {

class IActor;

class Scene : public Scene_Base, public osgViewer::Viewer
{
public:
	static int translateMouseButton( co::int32 button );

public:
	Scene();
	virtual ~Scene();

public:
	// qt.IPainter methods:
	virtual void initialize();
	virtual void resize( co::int32 width, co::int32 height );
	virtual void paint();
    
    // siv.scene.IDrawer method:
    void draw();
    void setViewport( co::int32 x, co::int32 y, co::int32 width, co::int32 height );
	void clear( float r, float g, float b, float a );

	// graphics.IScene methods:
	virtual co::Range<lab3d::scene::IActor* const> getActors();
	virtual void addActor( lab3d::scene::IActor* actor );
	virtual void removeActor( lab3d::scene::IActor* actor );
    virtual void update();
    virtual void clear();

	virtual lab3d::scene::ICamera* getCamera();
	virtual void setCamera( lab3d::scene::ICamera* camera );
    
    virtual void setAutoAdjustNearFar( bool value ) 
    { 
        _autoCalculateNearFar = value; 
    }
    
    virtual bool getAutoAdjustNearFar() { return _autoCalculateNearFar; }
    
    virtual qt::IGLContext* getGraphicsContextService();
    virtual void setGraphicsContextService( qt::IGLContext*  context );

private:
    void setupLight();
	void setCameraDefaultSettings( lab3d::scene::ICamera* camera );
	void copyCameraStateToOSG( lab3d::scene::ICamera* from, osg::Camera* to );

private:
    typedef co::RefVector<lab3d::scene::IActor> ActorList;
	ActorList _actors;
    
    bool _autoCalculateNearFar;
    osg::ref_ptr<osg::Group> _rootNode;
    osg::ref_ptr<osg::Camera> _osgCamera;
    osg::ref_ptr<osg::Material> _overrideMaterial;
    osg::ref_ptr<GraphicsContext> _graphicsContext;
    co::RefPtr<lab3d::scene::ICamera> _activeCamera;
};

} // namespace lab3d
} // namespace scene

#endif // _SCENE_H_

