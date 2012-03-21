#ifndef _OSGUSERDATA_H_
#define _OSGUSERDATA_H_

#include <co/RefPtr.h>
#include <lab3d/dom/IEntity.h>

#include <osg/Referenced>

class OSGUserData : public osg::Referenced
{
public:
	OSGUserData( lab3d::dom::IEntity* entity );
	~OSGUserData();

	void setEntity( lab3d::dom::IEntity* entity ) { _entity = entity; }
	lab3d::dom::IEntity* getEntity() { return _entity.get(); }

private:
	co::RefPtr<lab3d::dom::IEntity> _entity;
};

#endif // _OSGUSERDATA_H_
