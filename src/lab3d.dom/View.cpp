#include "View_Base.h"
#include <lab3d/dom/IEntity.h>
#include <lab3d/dom/BoundingBox.h>

namespace lab3d {
namespace dom {

const eigen::Vec3 VIEW_UP( 0, 1, 0 );
const eigen::Vec3 VIEW_DIR( 0, 0, -1 );

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

	void getZeroRollOrientation( eigen::Quat& zeroRollOrientation )
	{
		eigen::Quat fixRoll;
		eigen::Vec3 forward = _orientation * VIEW_DIR;
		if( forward.cross( VIEW_UP ).isApprox( eigen::Vec3::Zero() ) )
		{
			// different approach if the camera is looking 100% up or down
			fixRoll.setFromTwoVectors( _orientation * VIEW_UP, VIEW_UP );
		}
		else
		{
			lookAt( forward, VIEW_UP, fixRoll );
		}
		zeroRollOrientation = _orientation * fixRoll;
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
	void lookAt( const eigen::Vec3& forward, const eigen::Vec3& up, eigen::Quat& rotation )
	{
		const eigen::Vec3& zaxis = forward;
		eigen::Vec3 xaxis = up.cross( zaxis );
		eigen::Vec3 yaxis = zaxis.cross( xaxis );
		Eigen::Matrix3d axes;
		axes << xaxis, yaxis, zaxis;
		rotation = axes;
	}

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
		lookAt( dir, VIEW_UP, orientation );
		position = _position + dir * ( distance - offset );
	}

private:
	eigen::Vec3 _position;
	eigen::Quat _orientation;
};

CORAL_EXPORT_COMPONENT( View, View );

} // namespace dom
} // namespace lab3d
