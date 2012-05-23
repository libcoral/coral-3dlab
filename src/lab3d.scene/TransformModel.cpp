#include "TransformModel_Base.h"

#include <lab3d/dom/IEntity.h>

#include "OSGUserData.h"
#include "eigenOsgConvert.h"

#include <co/RefVector.h>

#include <coOsg/NodePtr.h>
#include <lab3d/dom/BoundingBox.h>

#include <osg/BoundingBox>
#include <osg/MatrixTransform>

namespace lab3d {
namespace scene {

class TransformModel : public TransformModel_Base
{
public:
    
	typedef co::RefVector<lab3d::scene::IModel> ModelList;
    
	TransformModel()
	{
		_transform = new osg::MatrixTransform();
        _node = _transform;
	}

	virtual ~TransformModel()
	{
		// empty destructor
	}

	const std::string& getFilename()
	{
		return _filename;
	}

	void setFilename( const std::string& filename )
	{
		_filename = filename;
	}

	void setVisible( bool visible )
	{
		_node->setNodeMask( visible ? 0xffffffff : 0x0 );
	}
    
	bool getVisible()
	{
		return _node->getNodeMask() == 0xffffffff;
	}

	const lab3d::dom::BoundingBox& getBounds()
	{
        osg::BoundingBox bbox;
		for( int i = 0; i < _childModels.size(); ++i )
        {
            const lab3d::dom::BoundingBox& childBbox = _childModels[i]->getBounds();
            bbox.expandBy( vecConvert( childBbox.min ) );
            bbox.expandBy( vecConvert( childBbox.max ) );
        }
        
        _bounds.center = vecConvert( bbox.center() );
        _bounds.max = vecConvert( bbox._max );
        _bounds.min = vecConvert( bbox._min );
        
        return _bounds;
	}

	const coOsg::NodePtr& getNode()
	{
		return _node;
	}

	// ------ lab3d.scene.ITransformModel Methods ------ //

	void addChild( lab3d::scene::IModel* child )
	{
		_childModels.push_back( child );
        
        osg::Node* node = child->getNode();
        _transform->addChild( node );
        node->setUserData( new OSGUserData( _entity.get() ) );
	}

	void removeChild( lab3d::scene::IModel* child )
	{
        for( ModelList::iterator it = _childModels.begin(); it != _childModels.end(); ++it )
        {
            if( *it == child )
            {
                _childModels.erase( it );
                
                osg::Node* node = (*it)->getNode();
                // release userdata
                node->setUserData( 0 );
                _transform->removeChild( node );
                return;
            }
        }
	}
    
    co::int32 getNumChildren()
    {
        return _childModels.size();
    }

	void setOrientation( const eigen::Quat& orientation )
	{
        osg::Vec3d scale;
        osg::Vec3d translation;
        osg::Quat quat, so;
        
        osg::Matrixd m = _transform->getMatrix();
        m.decompose( translation, quat, scale, so );
              
        m.makeScale( scale );
        m.postMultRotate( quatConvert( orientation.conjugate() ) );
        m.postMultTranslate( translation );
        _transform->setMatrix( m );
	}

	void setTranslation( const eigen::Vec3& position )
	{
        osg::Vec3d scale;
        osg::Vec3d translation;
        osg::Quat quat, so;
        
        osg::Matrixd m = _transform->getMatrix();
        m.decompose( translation, quat, scale, so );
        
        m.makeScale( scale );
        m.postMultRotate( quat );
        m.postMultTranslate( vecConvert( position ) );
        _transform->setMatrix( m );
	}
                    
    void setScale( const eigen::Vec3& scale )
    {
        osg::Vec3d s;
        osg::Vec3d translation;
        osg::Quat quat, so;
        
        osg::Matrixd m = _transform->getMatrix();
        m.decompose( translation, quat, s, so );
        
        m.makeScale( vecConvert( scale ) );
        m.postMultRotate( quat );
        m.postMultTranslate( translation );
        _transform->setMatrix( m );
    }
    
    void setEntityService( lab3d::dom::IEntity* entity )
    {
        _entity = entity;
    }
    
    lab3d::dom::IEntity* getEntityService()
    {
        return _entity.get();
    }
        
private:
    std::string _filename;
    osg::ref_ptr<osg::Node> _node;
    lab3d::dom::BoundingBox _bounds;
    osg::MatrixTransform* _transform;
            
    co::RefPtr<lab3d::dom::IEntity> _entity;
    
    ModelList _childModels;
};

CORAL_EXPORT_COMPONENT( TransformModel, TransformModel );

} // namespace scene
} // namespace lab3d
