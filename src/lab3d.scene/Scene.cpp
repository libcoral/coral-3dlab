#include "Scene_Base.h"

#include "OSGUserData.h"
#include "eigenOsgConvert.h"
#include "GraphicsContext.h"

#include <lab3d/dom/IView.h>
#include <lab3d/scene/IModel.h>
#include <lab3d/scene/PickIntersection.h>

#include <blue/open/render/ICamera.h>
#include <blue/open/render/IScreen.h>
#include <blue/open/render/Viewport.h>


#include <osg/Image>
#include <osg/Light>
#include <osg/Camera>
#include <osg/Material>
#include <osg/StateSet>
#include <osg/Texture2D>
#include <osg/LightSource>

#include <osg/Shader>
#include <osg/Program>
#include <osg/Uniform>
#include <osgDB/ReadFile>
#include <osgDB/FileUtils>
#include <osgDB/WriteFile>
#include <osgViewer/Viewer>

#include <co/Log.h>
#include <co/Coral.h>
#include <co/Range.h>
#include <co/RefPtr.h>
#include <co/ISystem.h>
#include <co/IInterface.h>
#include <co/IServiceManager.h>
#include <co/IllegalStateException.h>
#include <co/NotSupportedException.h>

namespace
{
    const osg::Vec4 DEFAULT_CLEAR_COLOR = osg::Vec4( 0, 0, 0.4, 1 );
}

namespace lab3d {
namespace scene {

class Scene : public Scene_Base, public osgViewer::Viewer
{
public:
	Scene() : _autoCalculateNearFar( true )
	{
		// register pick intersector service
		co::getSystem()->getServices()->addService(
				co::typeOf<lab3d::scene::IPickIntersector>::get(),
				this->getService<lab3d::scene::IPickIntersector>() );
	}

	virtual ~Scene()
	{
		// empty
	}

	// --- qt.IPainter methods --- //

	void initialize()
	{
		CORAL_DLOG(INFO) << "Initializing the scene...";

		// sets context in to camera
		_osgCamera = osgViewer::Viewer::getCamera();
		_osgCamera->setGraphicsContext( new GraphicsContext() );
		_osgCamera->setClearColor( DEFAULT_CLEAR_COLOR );

		_rootNode = new osg::Group();
		setSceneData( _rootNode.get() );

		setupLight();
	}

	co::int32 getWidth()
	{
		return _screenWidth;
	}

	co::int32 getHeight()
	{
		return _screenHeight;
	}

	void resize( co::int32 width, co::int32 height )
	{
		CORAL_DLOG(INFO) << "Canvas resized to " << width << " x " << height;

		_screenWidth = width;
		_screenHeight = height;
	}

	void render( co::Range<blue::open::render::IScreen* const> screens )
	{
		if( !_osgCamera.get() ) return;

		for( ; screens; screens.popFirst() )
		{
			blue::open::render::IScreen* screen = screens.getFirst();
			
			// mono rendering by now
			blue::open::render::ICamera* cam = screen->getLeftEye(); 
			const blue::open::render::Viewport& vp = cam->getViewport();	
			_osgCamera->setViewport( vp.x * _screenWidth, 
									vp.y * _screenHeight, 
									vp.w * _screenWidth, 
									vp.h * _screenHeight );

			_osgCamera->setProjectionMatrix( osg::Matrixd( cam->getProjection().data() ) );
			_osgCamera->setViewMatrix( osg::Matrixd( cam->getView().data() ) );

			frame();
		}
	}

	// --- lab3d.scene.IPickIntersector --- //

	void intersect( double x, double y, std::vector<lab3d::scene::PickIntersection>& intersections )
	{
		float local_x, local_y = 0.0;
		const osg::Camera* osgCamera = getCameraContainingPosition( x, y, local_x, local_y );
		if( !osgCamera ) return;
		
		osgUtil::LineSegmentIntersector::CoordinateFrame cf = ( osgCamera->getViewport() ?
				osgUtil::Intersector::WINDOW : osgUtil::Intersector::PROJECTION );
		
		osg::ref_ptr< osgUtil::LineSegmentIntersector > picker = new osgUtil::LineSegmentIntersector( cf, local_x, local_y);
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

	bool getAutoAdjustNearFar()
	{
		return _autoCalculateNearFar;
	}

	void setAutoAdjustNearFar( bool value ) 
    { 
        _autoCalculateNearFar = value; 
    }

	co::Range<lab3d::scene::IModel* const> getModels()
	{
		return _models;
	}

	void addModel( lab3d::scene::IModel* model )
	{
		_models.push_back( model );

		osg::ref_ptr<osg::Node> node = model->getNode();
		_rootNode->addChild( node );
	}

	void removeModel( lab3d::scene::IModel* model )
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
	}

	void clear()
	{
		if( !_rootNode.get() || _rootNode->getNumChildren() == 0 )
			return;

		CORAL_DLOG(INFO) << "Clearing the scene...";

		const int NUM_PERSISTENT_CHILDREN = 1; // LightSource
		_rootNode->removeChildren( NUM_PERSISTENT_CHILDREN, _rootNode->getNumChildren() );
	
		_models.clear();
	}

private:
	void setupLight()
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

private:
    typedef co::RefVector<lab3d::scene::IModel> ModelList;
	ModelList _models;
    
	// temporary screen size control
	int _screenWidth;
	int _screenHeight;

    bool _autoCalculateNearFar;
    osg::ref_ptr<osg::Group> _rootNode;
    osg::ref_ptr<osg::Camera> _osgCamera;
};

CORAL_EXPORT_COMPONENT( Scene, Scene );

} // namespace scene
} // namespace lab3d
