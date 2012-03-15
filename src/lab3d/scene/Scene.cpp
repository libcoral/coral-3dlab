#include "Scene.h"
#include "OSGUserData.h"

#include "glmOsgConvert.h"
#include "GraphicsContext.h"

#include <lab3d/dom/IView.h>
#include <lab3d/scene/IModel.h>
#include <lab3d/scene/ICamera.h>
#include <lab3d/scene/PickIntersection.h>

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

#include <co/Coral.h>
#include <co/ISystem.h>
#include <co/IServiceManager.h>

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
    
    // register pick intersector service
    co::getSystem()->getServices()->addService( co::typeOf<lab3d::scene::IPickIntersector>::get(), this->getService<lab3d::scene::IPickIntersector>() );
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
    
void Scene::intersect( double x, double y, std::vector<lab3d::scene::PickIntersection>& intersections )
{
    float local_x, local_y = 0.0;
    const osg::Camera* osgCamera = getCameraContainingPosition( x, y, local_x, local_y );
    if( !osgCamera ) return;
    
    osgUtil::LineSegmentIntersector::CoordinateFrame cf = 
    osgCamera->getViewport() ? osgUtil::Intersector::WINDOW : osgUtil::Intersector::PROJECTION;
    
    osg::ref_ptr< osgUtil::LineSegmentIntersector > picker = new osgUtil::LineSegmentIntersector(cf, local_x, local_y);
    osgUtil::IntersectionVisitor iv( picker.get() );
    const_cast<osg::Camera*>( osgCamera )->accept( iv );
    
    if( !picker->containsIntersections() )
    {
        intersections.clear();
        return;
    }
    
    osgUtil::LineSegmentIntersector::Intersections ints = picker->getIntersections();
    for( osgUtil::LineSegmentIntersector::Intersections::iterator it = ints.begin(); it != ints.end(); ++it )
    {
        // runs over all nodes within node path
        const osg::NodePath& np = it->nodePath;
        for( size_t i = 0; i < np.size(); ++i )
        {
            osg::Node* node = np[i];
            osg::Referenced* osgUserData = node->getUserData();
            if( !osgUserData )
                continue;
            
            OSGUserData* userData = dynamic_cast<OSGUserData*>( osgUserData );
            
            lab3d::scene::PickIntersection intersection;
            intersection.entity = userData->getEntity();
            
            intersection.point = vecConvert( it->getWorldIntersectPoint() );
            intersection.normal = vecConvert( it->getWorldIntersectNormal() );
            
            intersections.push_back( intersection );
        }
    }
}
    
void Scene::draw()
{
    frame();
}
    
co::Range<lab3d::scene::IModel* const> Scene::getModels()
{
	// TODO: implement this method.
	return _models;
}

void Scene::addModel( lab3d::scene::IModel* model )
{
	_models.push_back( model );

	osg::ref_ptr<osg::Node> node = model->getNode();
	_rootNode->addChild( node );

	update();
}

void Scene::removeModel( lab3d::scene::IModel* model )
{
	for( ModelList::iterator it = _models.begin(); it != _models.end(); ) 
	{
        lab3d::scene::IModel* current = (*it).get();
		if( current == model )
		{            
            osg::ref_ptr<osg::Node> node = current->getNode();
            
            // remove the reference for the user data set on addModel
            node->setUserData( 0 );
            _rootNode->removeChild( node );
            
			it = _models.erase( it );
            continue;
		}
        ++it;
	}
    update();
}

void Scene::update()
{
    if( !_osgCamera.get() ) // scene not yet initialized
        return;
    
    paint();
    _graphicsContext->update();
}

void Scene::clear()
{
    if( !_rootNode.get() || _rootNode->getNumChildren() == 0 )
        return;
    
	_rootNode->removeChildren( 0, _rootNode->getNumChildren() );
	_models.clear();
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
