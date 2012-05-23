#include "Project_Base.h"
#include <co/Coral.h>
#include <lab3d/dom/IView.h>
#include <lab3d/dom/IEntity.h>

namespace lab3d {
namespace dom {

class Project : public Project_Base
{
public:
	Project()
	{
		_currentView = co::newInstance( "lab3d.dom.View" )->getService<lab3d::dom::IView>();
		_currentView->setPosition( eigen::Vec3( 0, 0, 100 ) );
		//_currentView->setOrientation( eigen::Quat( Eigen::AngleAxisd( ( M_PI / 180 ) * -90.0, eigen::Vec3( 1, 0, 0 ) ) ) );
	}

	virtual ~Project()
	{
		// empty destructor
	}

	// ------ lab3d.dom.IProject Methods ------ //

	const std::string& getName()
	{
		return _name;
	}

	void setName( const std::string& name )
	{
		_name = name;
	}
	
	const std::string& getFilePath()
	{
		return _filePath;
	}
	
	void setFilePath( const std::string& filePath )
	{
		_filePath = filePath;
	}

	lab3d::dom::IView* getCurrentView()
	{
		return _currentView.get();
	}

	void setCurrentView( lab3d::dom::IView* currentView )
	{
		_currentView = currentView;
	}

	co::Range<lab3d::dom::IEntity* const> getEntities()
	{
		return _entities;
	}

	void setEntities( co::Range<lab3d::dom::IEntity* const> entities )
	{
		co::assign( entities, _entities );
	}

	lab3d::dom::IEntity* getSelectedEntity()
	{
		return _selectedEntity.get();
	}

	void setSelectedEntity( lab3d::dom::IEntity* selectedEntity )
	{
		_selectedEntity = selectedEntity;
	}

	void addEntity( lab3d::dom::IEntity* entity )
	{
		_entities.push_back( entity );
	}

	bool insertEntity( lab3d::dom::IEntity* beforeEntity, lab3d::dom::IEntity* toInsert )
	{
		// asserts that the entity to be insert is not already in this world
		assert( findEntity( toInsert->getName() ) == NULL );

		for( co::RefVector<lab3d::dom::IEntity>::iterator it = _entities.begin(); it != _entities.end(); ++it  ) 
		{
			if( it->get() == beforeEntity )
			{
				_entities.insert( it, toInsert );
				return true;
			}
		}

		return false;
	}
	
	bool removeEntity( lab3d::dom::IEntity* entity )
	{
		EntityList::iterator end = _entities.end();
		EntityList::iterator newEnd = std::remove( _entities.begin(), end, entity );
		size_t numRemoved = std::distance( newEnd, end );
		assert( numRemoved <= 1 );
		_entities.erase( newEnd, end );
		return numRemoved > 0;
	}

	lab3d::dom::IEntity* findEntity( const std::string& entityName )
	{
		size_t numEntities = _entities.size();
		for( size_t i = 0; i < numEntities; ++i )
			if( _entities[i]->getName() == entityName )
				return _entities[i].get();
		return NULL;
	}

private:
	std::string _name;
	std::string _filePath;

	co::RefPtr<lab3d::dom::IView> _currentView;

	typedef co::RefVector<lab3d::dom::IEntity> EntityList;
	EntityList _entities;

	co::RefPtr<lab3d::dom::IEntity> _selectedEntity;
};

CORAL_EXPORT_COMPONENT( Project, Project );

} // namespace dom
} // namespace lab3d
