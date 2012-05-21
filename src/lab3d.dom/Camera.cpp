#include "Camera_Base.h"
#include <co/Coral.h>
#include <co/RefPtr.h>
#include <lab3d/dom/IView.h>

namespace lab3d {
namespace dom {

class Camera : public Camera_Base
{
public:
	Camera() : _fovy( 60 ), _zNear( 1 ), _zFar( 10000 ),
		_viewportWidth( 800 ), _viewportHeight( 600 )
	{
		_view = co::newInstance( "lab3d.dom.View" )->getService<lab3d::dom::IView>();
		updateAspect();
	}

	virtual ~Camera()
	{
		// empty destructor
	}

	// ------ lab3d.dom.ICamera Methods ------ //
	
	lab3d::dom::IView* getView()
	{
		return _view.get();
	}
	
	void setView( lab3d::dom::IView* view )
	{
		_view = view;
	}
	
	double getFovy()
	{
		return _fovy;
	}
	
	void setFovy( double fovy )
	{
		_fovy = fovy;
	}
	
	double getZNear()
	{
		return _zNear;
	}
	
	void setZNear( double zNear )
	{
		_zNear = zNear;
	}
	
	double getZFar()
	{
		return _zFar;
	}
	
	void setZFar( double zFar )
	{
		_zFar = zFar;
	}
	
	co::int32 getViewportWidth()
	{
		return _viewportWidth;
	}
	
	void setViewportWidth( co::int32 viewportWidth )
	{
		_viewportWidth = viewportWidth;
		updateAspect();
	}

	co::int32 getViewportHeight()
	{
		return _viewportHeight;
	}

	void setViewportHeight( co::int32 viewportHeight )
	{
		_viewportHeight = viewportHeight;
		updateAspect();
	}
	
	double getAspect()
	{
		return _aspect;
	}
	
	void setAspect( double aspect )
	{
		_aspect = aspect;
	}

private:
	inline void updateAspect()
	{
		_aspect = static_cast<double>( _viewportWidth ) / _viewportHeight;
	}

private:
	co::RefPtr<lab3d::dom::IView> _view;
	double _fovy;
	double _zNear;
	double _zFar;
	double _aspect;
	co::int32 _viewportWidth;
	co::int32 _viewportHeight;
};

CORAL_EXPORT_COMPONENT( Camera, Camera );

} // namespace dom
} // namespace lab3d
