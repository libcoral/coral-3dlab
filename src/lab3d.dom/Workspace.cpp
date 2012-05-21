#include "Workspace_Base.h"
#include <co/IllegalStateException.h>
#include <lab3d/dom/IProject.h>
#include <lab3d/dom/IEntity.h>

namespace lab3d {
namespace dom {

class Workspace : public Workspace_Base
{
public:
	Workspace()
	{
		// empty constructor
	}

	virtual ~Workspace()
	{
		// empty destructor
	}

	// ------ lab3d.dom.IWorkspace Methods ------ //

	lab3d::dom::IProject* getActiveProject()
	{
		return _activeProject.get();
	}

	void setActiveProject( lab3d::dom::IProject* activeProject )
	{
		_activeProject = activeProject;
	}

	lab3d::dom::IEntity* getSelectedEntity()
	{
		return _activeProject.isValid() ? _activeProject->getSelectedEntity() : NULL;
	}

	void setSelectedEntity( lab3d::dom::IEntity* selectedEntity )
	{
		if( !_activeProject.isValid() )
			throw co::IllegalStateException( "no active project" );
		_activeProject->setSelectedEntity( selectedEntity );
	}

private:
	co::RefPtr<lab3d::dom::IProject> _activeProject;
};

CORAL_EXPORT_COMPONENT( Workspace, Workspace );

} // namespace dom
} // namespace lab3d
