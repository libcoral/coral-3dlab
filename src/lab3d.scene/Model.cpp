#include "Model_Base.h"
#include "eigenOsgConvert.h"

#include <lab3d/dom/BoundingBox.h>

#include <osgDB/ReadFile>
#include <coOsg/NodePtr.h>


namespace lab3d {
namespace scene {

class Model : public Model_Base
{
public:
	Model() : _node( 0 )
	{
        // empty
	}

	virtual ~Model()
	{
		// empty
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

    const std::string& getFilename() { return _filename; }

	// ------ lab3d.scene.IModel Methods ------ //

	const coOsg::NodePtr& getNode()
	{
        if( !_node.get() )
            _node = osgDB::readNodeFile( _filename );
        
        return _node;
	}
    
    virtual const lab3d::dom::BoundingBox& getBounds()
    {
        osg::BoundingBox bbox;
        bbox.expandBy( _node->getBound() );
        
        _bbox.center = vecConvert( bbox.center() );
        _bbox.max = vecConvert( bbox._max );
        _bbox.min = vecConvert( bbox._min );
        return _bbox;
    }

private:
    coOsg::NodePtr _node;
    std::string _filename;
    lab3d::dom::BoundingBox _bbox;
};

CORAL_EXPORT_COMPONENT( Model, Model );

} // namespace scene
} // namespace lab3d
