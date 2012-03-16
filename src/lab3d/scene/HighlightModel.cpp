#include "HighlightModel_Base.h"
#include <lab3d/dom/BoundingBox.h>

#include "eigenOsgConvert.h"

#include <osg/Geode>
#include <osg/Matrix>
#include <osg/Geometry>
#include <osg/Transform>
#include <osg/BoundingBox>
#include <osg/MatrixTransform>

namespace lab3d {
namespace scene {

class HighlightModel : public HighlightModel_Base
{
public:
	HighlightModel()
	{
		createHighlightBox();
	}

	virtual ~HighlightModel()
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

	const lab3d::dom::BoundingBox& getBounds()
	{
		return _highlightedEntity->getBounds();
	}

	const coOsg::NodePtr& getNode()
	{
		return _bboxNode;
	}
    
    void recalculateBoxFor( lab3d::dom::IEntity* entity )
    {
        lab3d::dom::BoundingBox bbox = entity->getBounds();
        eigen::Vec3 min( bbox.min );
        eigen::Vec3 max( bbox.max );
        _bboxTransformMatrix.setTrans( vecConvert( entity->getPosition() ) );
        
        _bboxVertices->clear();
        _bboxVertices->push_back( osg::Vec3( min.x(), min.y(), min.z() ) );
        _bboxVertices->push_back( osg::Vec3( max.x(), min.y(), min.z() ) );
        _bboxVertices->push_back( osg::Vec3( min.x(), max.y(), min.z() ) );
        _bboxVertices->push_back( osg::Vec3( max.x(), max.y(), min.z() ) );
        _bboxVertices->push_back( osg::Vec3( min.x(), min.y(), max.z() ) );
        _bboxVertices->push_back( osg::Vec3( max.x(), min.y(), max.z() ) );
        _bboxVertices->push_back( osg::Vec3( min.x(), max.y(), max.z() ) );
        _bboxVertices->push_back( osg::Vec3( max.x(), max.y(), max.z() ) );
        _bboxGeometry->setVertexArray( _bboxVertices );
    }
    
    void createHighlightBox()
    {        
        // create and set the indices of the bbox cube (first part is a strip)
        osg::DrawElementsUInt* bboxStrip = new osg::DrawElementsUInt( osg::PrimitiveSet::LINE_STRIP );
        bboxStrip->push_back( 0 ); 
        bboxStrip->push_back( 1 ); 
        bboxStrip->push_back( 3 );
        bboxStrip->push_back( 2 ); 
        bboxStrip->push_back( 0 ); 
        bboxStrip->push_back( 4 );
        bboxStrip->push_back( 5 ); 
        bboxStrip->push_back( 7 ); 
        bboxStrip->push_back( 6 );
        bboxStrip->push_back( 4 );
        
        osg::DrawElementsUInt* bboxNonStrip = new osg::DrawElementsUInt( osg::PrimitiveSet::LINES );
        bboxNonStrip->push_back( 1 );
        bboxNonStrip->push_back( 5 );
        bboxNonStrip->push_back( 2 );
        bboxNonStrip->push_back( 6 ); 
        bboxNonStrip->push_back( 3 );
        bboxNonStrip->push_back( 7 );
        
        osg::Vec4Array* bboxColor = new osg::Vec4Array;
        bboxColor->push_back( osg::Vec4( 0.0f, 1.0f, 0.0f, 1.0f ) );
        
        _bboxGeometry = new osg::Geometry();
        _bboxGeometry->addPrimitiveSet( bboxStrip );
        _bboxGeometry->addPrimitiveSet( bboxNonStrip );
        _bboxGeometry->getOrCreateStateSet()->setMode( GL_LIGHTING, osg::StateAttribute::OFF );
        _bboxGeometry->setUseDisplayList( false );
        _bboxGeometry->setColorArray( bboxColor );
        _bboxGeometry->setColorBinding( osg::Geometry::BIND_OVERALL );
        
        osg::Geode* bboxGeode = new osg::Geode();
        _bboxNode = bboxGeode;
        
        bboxGeode->addDrawable( _bboxGeometry ); 
        
        _bboxTransform = new osg::MatrixTransform;
        _bboxTransform->setMatrix( _bboxTransformMatrix );
        _bboxTransform->addChild( bboxGeode );
        
        // create and set the indices of the bbox cube (first part is a strip
        _bboxVertices = new osg::Vec3Array;
        _bboxVertices->push_back( osg::Vec3( -0.5, -0.5, -0.5 ) );
        _bboxVertices->push_back( osg::Vec3( 0.5, -0.5, -0.5 ) );
        _bboxVertices->push_back( osg::Vec3( -0.5, 0.5, -0.5 ) );
        _bboxVertices->push_back( osg::Vec3( 0.5, 0.5, -0.5 ) );
        _bboxVertices->push_back( osg::Vec3( -0.5, -0.5, 0.5 ) );
        _bboxVertices->push_back( osg::Vec3( 0.5, -0.5, 0.5 ) );
        _bboxVertices->push_back( osg::Vec3( -0.5, 0.5, 0.5 ) );
        _bboxVertices->push_back( osg::Vec3( 0.5, 0.5, 0.5 ) );
        _bboxGeometry->setVertexArray( _bboxVertices );
    }

protected:
	// ------ Receptacle 'entity' (lab3d.dom.IEntity) ------ //

	lab3d::dom::IEntity* getEntityService()
	{
		return _highlightedEntity.get();
	}

	void setEntityService( lab3d::dom::IEntity* entity )
	{
		_highlightedEntity = entity;
        recalculateBoxFor( entity );
	}

private:
	// member variables
	std::string _filename;
	co::RefPtr<lab3d::dom::IEntity> _highlightedEntity;
    
    osg::Matrix _bboxTransformMatrix;
	osg::ref_ptr<osg::Node> _bboxNode;
	osg::ref_ptr<osg::Geometry> _bboxGeometry;
	osg::ref_ptr<osg::Vec3Array> _bboxVertices;
	osg::ref_ptr<osg::MatrixTransform> _bboxTransform;
};

CORAL_EXPORT_COMPONENT( HighlightModel, HighlightModel );

} // namespace scene
} // namespace lab3d
