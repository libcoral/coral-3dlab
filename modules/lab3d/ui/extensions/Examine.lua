--[[----------------------------------------------------------------------------
	Examine Manipulator (Canvas Input Handler & Toolbar Item)
		- LMB: rotation around the centerPoint.
		- RMB/Wheel: controls the distanceToCenter.
--]]----------------------------------------------------------------------------

local ca = require "ca"
local qt = require "qt"
local lab3d = require "lab3d"
local ui = require "lab3d.ui"
local eigen = require "eigen"

-------------------------------------------------------------------------------
-- Examine Manipulator State
-------------------------------------------------------------------------------

local normalCursor = qt.OpenHandCursor
local dragCursor = qt.ClosedHandCursor
local navigator = co.new( "lab3d.scene.ExamineNavigator" ).navigator
local action = nil
local canvas = nil

local enabled = false
local lastY = 0

local ExamineManipulator = {}

-------------------------------------------------------------------------------
-- Extension Lifecycle
-------------------------------------------------------------------------------

function ExamineManipulator.install()
	action = qt.new( "QAction" )
	action.text = "Examine Manipulator"
	action.icon = qt.Icon( "lab3d:/ui/resources/examine.png" )
	action.enabled = false
	action.checkable = true
	action:connect( "toggled(bool)", function( sender, value )
		if value then
			ui.setCanvasInputHandler( ExamineManipulator )
		end
	end )
	ui.addToToolbar( "manipulator", action )
	canvas = ui.mainWindow.canvas
end

-------------------------------------------------------------------------------
-- Manipulator Lifecycle
-------------------------------------------------------------------------------

function ExamineManipulator.activate()
	local view = assert( lab3d.activeProject ).currentView
	navigator.view = view
	local selectedEntity = assert( lab3d.selectedEntity )
	local position, orientation = view:calculateNavigationToObject( selectedEntity );
	view.position = position
	view.orientation = orientation
	navigator.rotationCenter = selectedEntity.bounds.center
	canvas:setCursor( normalCursor )
end

function ExamineManipulator.deactivate()
	action.checked = false
	canvas:unsetCursor()
end

-------------------------------------------------------------------------------
-- Manipulator Events
-------------------------------------------------------------------------------

function ExamineManipulator.keyPressed( key )
    if key == "Key_Escape" then
        navigator:abortRotation()
    end
end

function ExamineManipulator.keyReleased( key )
	-- empty
end

function ExamineManipulator.mousePressed( x, y, button, modifiers )
	canvas:setCursor( dragCursor )
	if button == qt.LeftButton then
		local w, h = canvas.width, canvas.height
		local nx, ny = eigen.screenToClip( x, ( h - y ), w, h )
		navigator:beginRotation( nx, ny )
	else
		lastY = y
	end
end

function ExamineManipulator.mouseMoved( x, y, buttons, modifiers )
	local w, h = canvas.width, canvas.height
	if bit32.btest( buttons, qt.LeftButton ) then
		local nx, ny = eigen.screenToClip( x, ( h - y ), w, h )
	    navigator:updateRotation( nx, ny )
	end
	if bit32.btest( buttons, qt.RightButton ) then
		navigator:zoom( ( y - lastY ) / h * -2 )
		lastY = y
	end
end

function ExamineManipulator.mouseDoubleClicked( x, y, button, modifiers )
	-- empty
end

function ExamineManipulator.mouseReleased( x, y, button, modifiers )
	canvas:setCursor( normalCursor )
	if button == qt.LeftButton then
		navigator:endRotation()
	end
end

function ExamineManipulator.mouseWheel( x, y, delta, modifiers )
	-- delta is in eights of degree and tipically each wheel step is 15 degrees
	-- so each degree is 0.0083 of step.
	local degrees = delta * 0.0083
	navigator:zoom( degrees * 0.02 ) -- aproach 2% by degree
end

-- The currently selected entity determines our rotation center.
-- If no entity is selected, the manipulator is disabled.
local observeWorkspace = ca.observe( lab3d.workspace )
function observeWorkspace.selectedEntity( e )
	local selected = e.current
	enabled = ( selected ~= nil )
	action.enabled = enabled
	if enabled then
		navigator.rotationCenter = selected.bounds.center
	end
end

return ExamineManipulator
