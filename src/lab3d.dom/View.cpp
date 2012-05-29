#include "View_Base.h"
#include <co/Log.h>
#include <lab3d/dom/IEntity.h>
#include <lab3d/dom/BoundingBox.h>

namespace lab3d {
namespace dom {

const eigen::Vec3 VIEW_UP( 0, 1, 0 );
const eigen::Vec3 VIEW_RIGHT( 1, 0, 0 );	
const eigen::Vec3 VIEW_FORWARD( 0, 0, -1 );

class View : public View_Base
{
public:
	View() : _position( 0, 0, 0 ), _orientation( eigen::Quat::Identity() )
	{
		// empty
	}

	virtual ~View()
	{
		// empty destructor
	}

	// ------ lab3d.dom.IView Methods ------ //

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

	void getViewMatrix( eigen::Mat4& view )
	{
		eigen::Quat invRot = _orientation.conjugate();
		Eigen::Affine3d t( invRot );
		t.translation() = -( invRot * _position );
		view = t.matrix();
	}

	void getZeroRollOrientation( eigen::Quat& orientation )
	{
		// project our right axis onto the world's XZ plane
		eigen::Vec3 forward = VIEW_FORWARD;
	    eigen::Vec3 newUp = VIEW_UP;
	
		eigen::Vec3 side = forward.cross( newUp );
		side = side.normalized();
		newUp = side.cross( forward );

		Eigen::Affine3d rotation = Eigen::Affine3d::Identity();
		rotation( 0, 0 ) = side.x();
		rotation( 0, 1 ) = side.y();
		rotation( 0, 2 ) = side.z();
		rotation( 1, 0 ) = newUp.x();
		rotation( 1, 1 ) = newUp.y();
		rotation( 1, 2 ) = newUp.z();
		rotation( 2, 0 ) = -forward.x();
		rotation( 2, 1 ) = -forward.y(); 	
		rotation( 2, 2 ) = -forward.z();

		orientation = rotation.rotation();
	}

	void calculateNavigationToObject( lab3d::dom::IEntity* object, eigen::Vec3& position, eigen::Quat& orientation )
	{
		const BoundingBox& bbox = object->getBounds();
		double radius = ( bbox.center - bbox.max ).norm();
		calculatePose( bbox.center, radius, position, orientation );
	}

	void calculateNavigationToPoint( const eigen::Vec3& point, eigen::Vec3& position, eigen::Quat& orientation )
	{
		double distance = ( point - _position ).norm();
		calculatePose( point, distance * 0.666, position, orientation );
	}

private:
	/*
		Calculates a new pose (position and orientation) using the given distance offset from that point. 
		The new orientation transforms a vector from identity view forward direction (0,0,-1) to a vector 
		pointing to the given destination point, always keeping up vector aligned with world up direction.
	 */
	void calculatePose( const eigen::Vec3& target, double offset, eigen::Vec3& position, eigen::Quat& orientation )
	{
		eigen::Vec3 dir = target - _position;
		double distance = dir.norm();
		dir *= ( 1.0 / distance );
		orientation.setFromTwoVectors( VIEW_FORWARD, dir );
		position = _position + dir * ( distance - offset );
	}

private:
	eigen::Vec3 _position;
	eigen::Quat _orientation;
};

CORAL_EXPORT_COMPONENT( View, View );

} // namespace dom
} // namespace lab3d
