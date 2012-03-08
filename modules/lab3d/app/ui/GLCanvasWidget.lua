local qt = require "qt"

local L = {}

return function( canvasPainter )
	if not L.widgetInstance then
		-- create a gl canvas for displaying the graphics
		local glWidgetComponent = co.new "qt.GLWidget"
		glWidgetComponent.context:setFormat( qt.FormatOption.DoubleBuffer + qt.FormatOption.DepthBuffer + qt.FormatOption.Rgba + qt.FormatOption.AlphaChannel )
		
		-- accesses glwidget component as a qobject
		local glWidget = qt.objectCast( glWidgetComponent ) 
		
		-- sets the strong focus policy in canvas (necessary to capture keyboard events)
		glWidget.focusPolicy = qt.StrongFocus
		
		-- accesses IPainter service and sets it into canvas
		glWidgetComponent.painter = canvasPainter
		
		--glWidgetComponent.inputListener = canvasInputListener
	
		L.widgetInstance = glWidget
		L.graphicsContext = glWidgetComponent.context
	end
	
	return L.widgetInstance, L.graphicsContext
end