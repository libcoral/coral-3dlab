--[[---------------------------------------------------------------------------
	ExamineManipulator component.
	Provides qt.InpuListener service and handles mouse events to change camera
	position and orientation in order to implement examine manipulation.
	The camera rotates around a central point (centerPoint) with a varying
	distance (distanceToCenter) that can be adjusted using mouse wheel.
	Double click events are also implemented to perform a navigation to
	double click point location (\see ICamera:navigateToPoint()).
--]]---------------------------------------------------------------------------

local qt = require "qt"
local glm = require "glm"

local ExamineManipulator =  co.Component( "lab3d.app.manipulator.ExamineManipulator )

-- local functions table
local locals = {}

-------------------------------------------------------------------------------
-- Local module functions
-------------------------------------------------------------------------------

function locals.reset( self )

end

-------------------------------------------------------------------------------
-- Component declaration
-------------------------------------------------------------------------------
-- TODO: set rotation center whenever an object is double clicked
function ExamineManipulator:__init()
	if not self.navigator then
		error( "a IExamineNavigator instance must be provided in order to implement examine manipulators or devices." )
	end
	
	locals.reset( self )
	self.name = self.name or ""
end

function ExamineManipulator:getName() 
	return self.name
end

function ExamineManipulator:setName( name ) 
	self.name = name
end

function ExamineManipulator:activate()
	locals.reset( self )
	self.canvas:setCursor( qt.OpenHandCursor )
end

function ExamineManipulator:deactivate()
	self.canvas:unsetCursor()
end

function ExamineManipulator:getNavigator()
	return self.navigator
end

function ExamineManipulator:setNavigator( navigator )
	self.navigator = navigator
end

function ExamineManipulator:mousePressed( x, y, button, modifiers )
	-- pauses navigation on user interaction
	self.navigationTask:pause()
	
	-- changes cursor
	self.canvas:setCursor( qt.ClosedHandCursor )

	-- calculates screen center
	-- since lua handles all number as double, we need to round center to integer
	local width = self.canvas.width
	local height = self.canvas.height
	local nx, ny = glm.screenToClip( x, ( height - y ), width, height )

	self.navigator:beginRotation( nx, ny )
end

function ExamineManipulator:mouseMoved( x, y, button, modifiers )
	local width = self.canvas.width
	local height = self.canvas.height
 	local nx, ny = glm.screenToClip( x, ( height - y ), width, height )

    self.navigator:updateRotation( nx, ny )
end

function ExamineManipulator:mouseDoubleClicked( x, y, button, modifiers ) 
	local intersectionPoint = locals.pickPoint( self, x, y )
	if not intersectionPoint then
		return
	end

	locals.postNavigationTask( self, intersectionPoint )
	self.navigator.rotationCenter = intersectionPoint
end

function ExamineManipulator:mouseReleased( x, y, button, modifiers )
	-- changes the current cursor
	self.canvas:setCursor( qt.OpenHandCursor )
	self.navigator:endRotation()
end

function ExamineManipulator:mouseWheel( x, y, delta, modifiers )
	-- pauses navigation on user interaction
	self.navigationTask:pause()
	
	self.navigator:zoom( delta * 0.0083 )
end

-------------------------------------------------------------------------------
-- Unused IInputlistener methods
-------------------------------------------------------------------------------
function ExamineManipulator:keyPressed( key ) 
    if key == "Key_Escape" then
        self.navigator:abortRotation()
    end
end

function ExamineManipulator:keyReleased( key ) end

return ExamineManipulator

