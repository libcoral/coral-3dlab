#include "Scene.h"

#include "glmOsgConvert.h"
#include "GraphicsContext.h"

#include <lab3d/dom/IView.h>
#include <lab3d/scene/IActor.h>
#include <lab3d/scene/ICamera.h>

#include <qt/IGLContext.h>

#include <osg/Image>
#include <osg/Light>
#include <osg/Camera>
#include <osg/StateSet>
#include <osg/Texture2D>
#include <osg/LightSource>

#include <osg/Shader>
#include <osg/Program>
#include <osg/Uniform>
#include <osgDB/ReadFile>
#include <osgDB/FileUtils>
#include <osgDB/WriteFile>

#include <co/Coral.h>
#include <co/RefVector.h>
#include <co/IInterface.h>
#include <co/IllegalStateException.h>
#include <co/NotSupportedException.h>

#include <cassert>
#include <sstream>

#include <string.h>
#include <glm/glm.hpp>

namespace
{
    const osg::Vec4 DEFAULT_CLEAR_COLOR = osg::Vec4( 0, 0, 0.4, 1 );
}

namespace lab3d {
namespace scene {
    
int Scene::translateMouseButton( co::int32 button )
{
	switch ( button )
	{
		case 1: return osgGA::GUIEventAdapter::LEFT_MOUSE_BUTTON;
		case 2: return osgGA::GUIEventAdapter::RIGHT_MOUSE_BUTTON;
		case 4: return osgGA::GUIEventAdapter::MIDDLE_MOUSE_BUTTON;
		default: return 0;
	}
}

Scene::Scene() : _autoCalculateNearFar( true )
{
	_graphicsContext = new GraphicsContext();
    
	_activeCamera = 0;
}

Scene::~Scene()
{
	_graphicsContext->setUserContext( 0 );
}

static void updateCameraViewport( lab3d::scene::ICamera* camera, double w, double h )
{
	camera->setViewportWidth( w );
	camera->setViewportHeight( h );
	camera->setAspect( w / h );
}
    
void Scene::initialize()
{
    assert( _graphicsContext->getUserContext() );
    
	// sets context in to camera
    _osgCamera = osgViewer::Viewer::getCamera();
	_osgCamera->setGraphicsContext( _graphicsContext.get() );
    _osgCamera->setClearColor( DEFAULT_CLEAR_COLOR );
   
   	_rootNode = new osg::Group();
    setSceneData( _rootNode.get() );
}

void Scene::resize( co::int32 width, co::int32 height )
{
	_graphicsContext->resized( 0, 0, width, height );
    if( !_activeCamera )
        return;
    
	updateCameraViewport( _activeCamera.get(), width, height );
	paint();
}

void Scene::paint()
{
    lab3d::dom::IView* view = _activeCamera->getView();
    if( !view )
        return;
    
    copyCameraStateToOSG( _activeCamera.get(), _osgCamera.get() );

    _osgCamera->setViewport( 0, 0, _activeCamera->getViewportWidth(), _activeCamera->getViewportHeight() );
    _osgCamera->setClearColor( DEFAULT_CLEAR_COLOR );
    
    frame();
}
    
void Scene::setViewport( co::int32 x, co::int32 y, co::int32 width, co::int32 height ) 
{
    _osgCamera->setViewport( x, y, width, height );
}
    
void Scene::clear( float r, float g, float b, float a ) 
{
    _osgCamera->setClearColor( osg::Vec4( r, g, b, a ) );
}
    
void Scene::draw()
{
    frame();
}
    
co::Range<lab3d::scene::IActor* const> Scene::getActors()
{
	// TODO: implement this method.
	return _actors;
}

void Scene::addActor( lab3d::scene::IActor* actor )
{
	_actors.push_back( actor );

	osg::ref_ptr<osg::Node> node = actor->getNode();
	_rootNode->addChild( node );

	update();
}

void Scene::removeActor( lab3d::scene::IActor* actor )
{
	for( ActorList::iterator it = _actors.begin(); it != _actors.end(); ) 
	{
        lab3d::scene::IActor* current = (*it).get();
		if( current == actor )
		{            
            osg::ref_ptr<osg::Node> node = current->getNode();
            _rootNode->removeChild( node );
            
			it = _actors.erase( it );
            continue;
		}
        ++it;
	}
    update();
}

void Scene::update()
{
    paint();
    _graphicsContext->update();
}

void Scene::clear()
{
	_rootNode->removeChildren( 0, _rootNode->getNumChildren() );
	_actors.clear();
    update();
    
    // setup light
    setupLight();
}

lab3d::scene::ICamera* Scene::getCamera()
{
	return _activeCamera.get();
}

void Scene::setCamera( lab3d::scene::ICamera* camera )
{
	_activeCamera = camera;
}
    
qt::IGLContext* Scene::getGraphicsContextService()
{
    return _graphicsContext->getUserContext();
}
    
void Scene::setGraphicsContextService( qt::IGLContext*  context )
{
    _graphicsContext->setUserContext( context );
}
    
void Scene::setupLight()
{
    osg::Light* light = new osg::Light();
    light->setPosition( osg::Vec4( -1.0, -1.0, -1.0, 0.0 ) );
    light->setDiffuse( osg::Vec4( 1.0, 1.0, 1.0, 1.0 ) );
    light->setSpecular( osg::Vec4( 1.0, 1.0, 1.0, 1.0 ) );
    light->setAmbient( osg::Vec4( 0.4, 0.4, 0.4, 1.0 ) );
    
    osg::LightSource* ls = new osg::LightSource();
    ls->setLight( light );
    
    osg::StateSet* stateSet = _rootNode->getOrCreateStateSet();
    ls->setLocalStateSetModes( osg::StateAttribute::ON );
    ls->setStateSetModes( *stateSet, osg::StateAttribute::ON );
    
    _rootNode->addChild( ls );
}

void Scene::setCameraDefaultSettings( lab3d::scene::ICamera* camera )
{
	updateCameraViewport( camera, 1024, 768 );
	camera->setFovy( 90 );
	camera->setZNear( 100 );
	camera->setZFar( 100000 );
}

void Scene::copyCameraStateToOSG( lab3d::scene::ICamera* from, osg::Camera* to )
{
    to->setProjectionMatrixAsPerspective( from->getFovy(), from->getAspect(), from->getZNear(), from->getZFar() );
    
    lab3d::dom::IView* view = _activeCamera->getView();
    osg::Vec3d eye = vecConvert( view->getPosition() );
    osg::Vec3d at = vecConvert( view->getPosition() + view->getDirection() );
    osg::Vec3d up = vecConvert( view->getUp() );
	to->setViewMatrixAsLookAt( eye, at, up );
}

CORAL_EXPORT_COMPONENT( Scene, Scene );

} // namespace scene
} // namespace lab3d
