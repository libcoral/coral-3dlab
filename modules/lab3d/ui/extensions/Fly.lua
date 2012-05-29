--[[---------------------------------------------------------------------------
	Fly Manipulator (Canvas Input Handler & Toolbar Item)
	First-person camera controlled with the mouse and the WASD keys.
--]]---------------------------------------------------------------------------

local qt = require "qt"

local lab3d = require "lab3d"
local ui = require "lab3d.ui"

local eigen = require "eigen"

local Vec3 = eigen.Vec3
local pi = math.pi
local floor = math.floor

-------------------------------------------------------------------------------
-- Fly Manipulator State
-------------------------------------------------------------------------------

local navigator = co.new( "lab3d.scene.FlyNavigator" ).navigator

local action = nil
local canvas = nil

local paused = true
local front, back, left, right = false, false, false, false
local autoControlled = false
local velocity = 10

local FlyManipulator = {}

-------------------------------------------------------------------------------
-- Extension Lifecycle
-------------------------------------------------------------------------------

function FlyManipulator.install()
	action = qt.new( "QAction" )
	action.text = "Fly Manipulator"
	action.icon = qt.Icon( "lab3d:/ui/resources/fly.png" )
	action.checkable = true
	action:connect( "toggled(bool)", function( sender, value )
		if value then
			ui.setCanvasInputHandler( FlyManipulator )
		end
	end )
	ui.addToToolbar( "manipulator", action )
	canvas = ui.mainWindow.canvas
	lab3d.addUpdateCallback( function( dt )
		if not paused then navigator:evolve( dt ) end
	end )
end

-------------------------------------------------------------------------------
-- Manipulator Lifecycle
-------------------------------------------------------------------------------

function FlyManipulator.activate()
	local view = assert( lab3d.activeProject ).currentView
	navigator.view = view

	-- remove any roll rotation
	view.orientation = view:getZeroRollOrientation()

	canvas.mouseTracking = true
end

function FlyManipulator.deactivate()
	canvas.mouseTracking = false
end

-------------------------------------------------------------------------------
-- Manipulator Events
-------------------------------------------------------------------------------

local function setPaused( value )
	paused = value
	if not paused then
		-- this manipulator alters the canvas cursor because it is only really active
		-- when a button is pressed (ESC pauses the manipulator and restores cursor)
		canvas:setCursor( qt.BlankCursor )

		local cw = floor( canvas.width * 0.5 )
		local ch = floor( canvas.height * 0.5 )

		-- center the cursor on the canvas
		local localX, localY = canvas:mapToGlobal( cw, ch )
    	canvas:setCursorPosition( localX, localY )
    else
		canvas:unsetCursor()
    end
end

local function getTranslationVector()
	local res = Vec3( 0, 0, 0 )
	if front or back or left or right then
		res.z = ( front and -1 or 0 ) + ( back and 1 or 0 )
		res.x = ( left and -1 or 0 ) + ( right and 1 or 0 )
		if front == back and left == right then return res end -- (normalize zero vector yields bad numbers)
		eigen.normalize( res, res )
	end
	return res
end

local function updateKey( key, state )
	if autoControlled then return end

	if key == "Key_W" then front = state
	elseif key == "Key_S" then back = state
	elseif key == "Key_A" then left = state
	elseif key == "Key_D" then right = state end

	navigator:setTranslationVector( getTranslationVector() )
end

function FlyManipulator.keyPressed( key )
	if key == "Key_Escape" then
		setPaused( true )
	end
	updateKey( key, true )
end

function FlyManipulator.keyReleased( key )
	updateKey( key, false )
end

function FlyManipulator.mousePressed( x, y, button, modifiers )
	-- when right mouse button is pressed, toggle 'paused' state
	if button == qt.RightButton then
		setPaused( not paused )
	end
end

function FlyManipulator.mouseReleased( x, y, button, modifiers )
	-- empty
end

function FlyManipulator.mouseDoubleClicked( x, y, button, modifiers )
	-- empty
end

local function clamp( n, min, max )
	return ( n > max and max or ( n < min and min or n ) )
end

function FlyManipulator.mouseMoved( x, y, button, modifiers )
	if paused then return end

	local width = canvas.width
	local height = canvas.height

	local cw = floor( width * 0.5 )
	local ch = floor( height * 0.5 )

	-- set cursor position to canvas center
	local localX, localY = canvas:mapToGlobal( cw, ch )
   	canvas:setCursorPosition( localX, localY )

   	if autoControlled then return end

	-- Since we reset the cursor position, we really work with offsets
	-- dx and dy are normalized offsets from the center
	local dx, dy = eigen.screenToClip( x, y, width, height )

	-- Linearly map deltas from -PI to PI on both directions
    navigator:addPitchOffset( -clamp( dx * pi * 0.5, -pi, pi ) )
    navigator:addYawOffset( -clamp( dy * pi * 0.5, -pi, pi ) )
end

function FlyManipulator.mouseWheel( x, y, delta, modifiers )
	if autoControlled then return end

	local numDegrees = delta / 8
    local numSteps = numDegrees / 15

	velocity = clamp( velocity * ( 1 + numSteps ), 0.5, 10000 )
	navigator.translationVelocity = velocity
end

return FlyManipulator
