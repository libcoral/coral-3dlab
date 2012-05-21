#include "Entity_Base.h"
#include <co/IInterface.h>
#include <co/MissingServiceException.h>
#include <lab3d/dom/BoundingBox.h>

namespace lab3d {
namespace dom {

class Entity : public Entity_Base
{
public:
	Entity() : _scale( 1, 1, 1 ),
		_position( 0, 0, 0 ),
		_orientation( eigen::Quat::Identity() )
	{
		// empty
	}

	virtual ~Entity()
	{
		// empty destructor
	}

	// ------ lab3d.dom.IEntity Methods ------ //

	const std::string& getName()
	{
		return _name;
	}

	void setName( const std::string& name )
	{
		_name = name;
	}

	const eigen::Vec3& getScale()
	{
		return _scale;
	}

	void setScale( const eigen::Vec3& scale )
	{
		_scale = scale;
	}

	const eigen::Vec3& getPosition()
	{
		return _position;
	}

	void setPosition( const eigen::Vec3& position )
	{
		_position = position;
	}

	const eigen::Quat& getOrientation()
	{
		return _orientation;
	}

	void setOrientation( const eigen::Quat& orientation )
	{
		_orientation = orientation;
	}

	const lab3d::dom::BoundingBox& getBounds()
	{
		return _bounds;
	}

	void setBounds( const lab3d::dom::BoundingBox& bounds )
	{
		_bounds = bounds;
	}

	co::Range<co::IService* const> getDecorators()
	{
		return _decorators;
	}

	void setDecorators( co::Range<co::IService* const> decorators )
	{
		co::assign( decorators, _decorators );
	}

	void addDecorator( co::IService* decorator )
	{
		_decorators.push_back( decorator );
	}

	void removeDecorator( co::IService* decorator )
	{
		DecoratorList::iterator end = _decorators.end();
		DecoratorList::iterator newEnd = std::remove( _decorators.begin(), end, decorator );
		assert( newEnd < end ); // something must have been removed
		_decorators.erase( newEnd, end );
	}

	co::IService* find( co::IInterface* type )
	{
		assert( type );
		size_t numDecorators = _decorators.size();
		for( size_t i = 0; i < numDecorators; ++i )
			if( _decorators[i]->getInterface()->isSubTypeOf( type ) )
				return _decorators[i].get();
		return NULL;
	}

	co::IService* get( co::IInterface* type )
	{
		co::IService* res = find( type );
		if( res ) return res;
		CORAL_THROW( co::MissingServiceException, "no decorator of type " << type->getFullName() << " was found" );
	}

	void getAllOf( co::IInterface* type, co::RefVector<co::IService>& decorators )
	{
		size_t numDecorators = _decorators.size();
		for( size_t i = 0; i < numDecorators; ++i )
			if( _decorators[i]->getInterface()->isSubTypeOf( type ) )
				decorators.push_back( _decorators[i] );
	}

private:
	std::string _name;
	eigen::Vec3 _scale;
	eigen::Vec3 _position;
	eigen::Quat _orientation;
	lab3d::dom::BoundingBox _bounds;

	typedef co::RefVector<co::IService> DecoratorList;
	DecoratorList _decorators;
};

CORAL_EXPORT_COMPONENT( Entity, Entity );

} // namespace dom
} // namespace lab3d
