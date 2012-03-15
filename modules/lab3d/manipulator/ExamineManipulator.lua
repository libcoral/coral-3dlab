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

local SceneManager = require "lab3d.SceneManager"
local ProjectObserver = require "lab3d.helper.ProjectObserver"

local ExamineManipulator =  co.Component( "lab3d.manipulator.ExamineManipulator" )

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
	local navigatorObj = co.new "lab3d.dom.ExamineNavigator"
	self.navigator = navigatorObj.navigator

	self.enabled = false
	
	locals.reset( self )
	self.name = self.name or "Examine Manipulator"
	self.canvas = qt.mainWindow:getCentralWidget()
	
	-- registers self table as project observer, using lua api
	ProjectObserver:addObserver( self )
end

function ExamineManipulator:getName() 
	return self.name
end

function ExamineManipulator:setName( name ) 
	self.name = name
end

function ExamineManipulator:activate()
	locals.reset( self )
	
	local application = co.system.services:getService( co.Type["lab3d.IApplication"] )
	
	local selectedEntity = application.currentProject.selectedEntity
	assert( selectedEntity )
	
	local view = self.navigator.view
	view:setPose( view:calculateNavigationToObject( selectedEntity ) )
	self.navigator.rotationCenter = selectedEntity.bounds.center
end

function ExamineManipulator:deactivate()
	-- empty
end

function ExamineManipulator:getNavigator()
	return self.navigator
end

function ExamineManipulator:getDescription()
	return "Examine Manipulator"
end

function ExamineManipulator:getResourceIcon()
	return "lab3d:/ui/resources/examine.png"
end

function ExamineManipulator:getNormalCursor()
	return qt.OpenHandCursor
end

function ExamineManipulator:getDragCursor()
	return qt.ClosedHandCursor
end

function ExamineManipulator:setNavigator( navigator )
	self.navigator = navigator
end

function ExamineManipulator:getEnabled()
	return self.enabled
end

function ExamineManipulator:setEnabled( value )
	self.enabled = value
end

function ExamineManipulator:mousePressed( x, y, button, modifiers )
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
	--local intersectionPoint = locals.pickPoint( self, x, y )
--	if not intersectionPoint then
--		return
--	end
--
--	self.navigator.rotationCenter = intersectionPoint
end

function ExamineManipulator:mouseReleased( x, y, button, modifiers )
	self.navigator:endRotation()
end

function ExamineManipulator:mouseWheel( x, y, delta, modifiers )
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


function ExamineManipulator:onEntitySelectionChanged( project, previous, current )
	self.enabled = (current ~= nil)
	if not current or not self.navigator then return end
	self.navigator.rotationCenter = current.bounds.center
end

return ExamineManipulator

