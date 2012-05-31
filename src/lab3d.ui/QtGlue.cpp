#include "QtGlue_Base.h"

#include <eigen/Mat4.h>

#include <qt/IGLContext.h>
#include <lab3d/dom/IView.h>
#include <lab3d/dom/IProject.h>
#include <lab3d/dom/IWorkspace.h>
#include <blue/open/render/IScreen.h>
#include <blue/open/render/IScreenProvider.h>
#include <blue/open/basic/render/IPerspectiveConfigurator.h>

#include <co/Coral.h>
#include <co/RefPtr.h>
#include <co/ISystem.h>
#include <co/IServiceManager.h>

namespace lab3d {
namespace ui {

class QtGlue : public QtGlue_Base
{
public:
	QtGlue()
	{
		// Temporary HACK!!
		co::IObject* perspectiveProvider = co::newInstance("blue.open.basic.render.PerspectiveProvider");
		_screenProviderService = perspectiveProvider->getService<blue::open::render::IScreenProvider>();
		_screenConfiguratorService = perspectiveProvider->getService<blue::open::basic::render::IPerspectiveConfigurator>();
	}

	virtual ~QtGlue()
	{
		// empty destructor
	}

	// ------ qt.IPainter Methods ------ //

	void initialize()
	{
		assert( _rendererService.get() );
		_rendererService->initialize();
	}

	void paint()
	{
		_qtglcontextService->makeCurrent();
		// accesses current workspace to get current view
		lab3d::dom::IWorkspace* workspace = co::getService<lab3d::dom::IWorkspace>();
		lab3d::dom::IProject* currentProject = workspace->getActiveProject();
		if( !currentProject )
			return;

		// accesses current view
		eigen::Mat4 currentUserView;
		currentProject->getCurrentView()->getViewMatrix( currentUserView );
		
		// update screen provider with the current view matrix
		
		_screenProviderService->setUserView( currentUserView );

		// render screens
		co::RefVector<blue::open::render::IScreen> screens;
		_screenProviderService->getScreens( screens );
		_rendererService->render( screens );
		_qtglcontextService->swapBuffers();
	}

	void resize( co::int32 width, co::int32 height )
	{
		assert( _canvasService.get() && _screenConfiguratorService.get());
		if(height == 0 )
			height = 1; //dont matter this value, nothing will be shown
		_screenConfiguratorService->setAspect( (double)width / (double)height );		
		_canvasService->resize( width, height );
	}

	bool getAutoSwapBuffers()
	{
		assert( _qtglcontextService.get() );
		return _qtglcontextService->getAutoSwapBuffers();
	}

	void setAutoSwapBuffers( bool autoSwapBuffers )
	{
		assert( _qtglcontextService.get() );
		_qtglcontextService->setAutoSwapBuffers( autoSwapBuffers );		
	}

	bool isValid()
	{
		static bool dummy;
		return dummy;
	}

	void makeCurrent()
	{
		assert( _qtglcontextService.get() );
		return _qtglcontextService->makeCurrent();
	}

	void setFormat( co::int32 desiredFormat )
	{
		assert( _qtglcontextService.get() );
		_qtglcontextService->setFormat( desiredFormat );	
	}

	void swapBuffers()
	{
		assert( _qtglcontextService.get() );
		return _qtglcontextService->swapBuffers();
	}

protected:
	// ------ Receptacle 'canvas' (blue.open.render.IDrawingArea) ------ //

	blue::open::render::IDrawingArea* getDrawingAreaService()
	{
		return _canvasService.get();
	}

	void setDrawingAreaService( blue::open::render::IDrawingArea* canvas )
	{
		_canvasService = canvas;
	}

	// ------ Receptacle 'renderer' (blue.open.render.IRenderer) ------ //

	blue::open::render::IRenderer* getRendererService()
	{
		return _rendererService.get();
	}

	void setRendererService( blue::open::render::IRenderer* renderer )
	{
		_rendererService = renderer;
	}

	qt::IGLContext* getQtglcontextService()
	{
		return _qtglcontextService.get();
	}

	void setQtglcontextService( qt::IGLContext* qtglcontext )
	{
		_qtglcontextService = qtglcontext;
	}

private:
	co::RefPtr<qt::IGLContext> _qtglcontextService;
	co::RefPtr<blue::open::render::IRenderer> _rendererService;
	co::RefPtr<blue::open::render::IDrawingArea> _canvasService;
	co::RefPtr<blue::open::render::IScreenProvider> _screenProviderService;
	co::RefPtr<blue::open::basic::render::IPerspectiveConfigurator> _screenConfiguratorService;
};

CORAL_EXPORT_COMPONENT( QtGlue, QtGlue );

} // namespace ui
} // namespace lab3d
