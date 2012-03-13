--[[---------------------------------------------------------------------------
	FlyManipulator module.
	Provides a lua API for a sivmanip.Manipulator module that implements
	game-like navigation using AWSD keyboard movement and mouse orientation.
--]]---------------------------------------------------------------------------

local qt = require "qt"
local glm = require "glm"

local FlyManipulator =  co.Component( "lab3d.viewer.manipulator.FlyManipulator" )

local locals = {}

-------------------------------------------------------------------------------
-- Local module functions
-------------------------------------------------------------------------------
function locals.reset( self )
	-- movement indicator variables
	self.front 	= false
	self.back 	= false
	self.left 	= false
	self.right 	= false
	self.paused = true
end

function locals.setPaused( self, value )
	self.paused = value
	if not value then
		-- this manipulator alters the canvas cursor because it is only really active
		-- when a button is pressed (ESC pauses the manipulator and restores cursor)
		self.canvas:setCursor( qt.BlankCursor )
				
		-- since lua handles all number as double, we need to round center to integer
		local cw = math.floor( self.canvas.width * 0.5 )
		local ch = math.floor( self.canvas.height * 0.5 )

		-- sets cursor position to canva's center
		local localX, localY = self.canvas:mapToGlobal( cw, ch )
    	self.canvas:setCursorPosition( localX, localY )
    else
		self.canvas:unsetCursor()
    end
end

function locals.getTranslationVector( self )
	local result = glm.Vec3( 0, 0, 0 )
		
	if not ( self.front or self.back or self.left or self.right ) then
		return result
	end
	
	if self.front then
	    result.z = -1
	end
	if self.back then
	    result.z = 1
	end
	if self.right then
	    result.x = 1
	end
	if self.left then
	    result.x = -1
	end
	
	glm.normalize( result, result )

	return result
end

function locals.clamp( value, min, max )
	return math.min( math.max( value, min ), max )
end

-------------------------------------------------------------------------------
-- Component declaration.
-------------------------------------------------------------------------------
function FlyManipulator:__init()
	local navigatorObj = co.new "lab3d.core.domain.FlyNavigator"
	self.navigator = navigatorObj.navigator

	self.navigator.view = self.view
	
	self.canvas = qt.mainWindow:getCentralWidget()
	
	self.listeners = {}
	self.started = true
	self.finished = false
	self.stopped = false
	
	locals.reset( self )
	self.name = self.name or "Fly Manipulator"
	self.translationVelocity = 10
	self.navigator.translationVelocity = self.translationVelocity
	self.animationOnCourse = false
end

function FlyManipulator:taskStarted( task )
	-- empty
end

function FlyManipulator:taskFinished( task )
	-- empty
end

function FlyManipulator:taskPaused( task )
	self.animationOnCourse = false
end

function FlyManipulator:taskReset( task )
	-- empty
end

function FlyManipulator:getName() 
	return self.name
end

function FlyManipulator:setName( name ) 
	self.name = name
end

function FlyManipulator:activate()
	locals.reset( self )
	self.canvas.mouseTracking = true
end

function FlyManipulator:deactivate()
	self.canvas.mouseTracking = false
end

function FlyManipulator:getDescription()
	return "Examine Manipulator"
end

function FlyManipulator:getResourceIcon()
	return "lab3d:/ui/resources/fly.png"
end

function FlyManipulator:getNormalCursor()
	return -1 -- do not change cursor, the manipulator itself handles it (see setPaused closue)
end

function FlyManipulator:getDragCursor()
	return -1 -- do not change cursor, the manipulator itself handles it (see setPaused closue)
end

function FlyManipulator:getNavigator()
	return self.navigator
end

function FlyManipulator:setNavigator( navigator )
	self.navigator = navigator
end

function FlyManipulator:keyPressed( key )
	if key == "Key_Escape" then
		locals.setPaused( self, true )
	end
	
	if self.animationOnCourse then return end

	if key == "Key_W" then
		self.front = true
	end
	if key == "Key_S" then
		self.back = true
	end
	if key == "Key_A" then
		self.left = true
	end
	if key == "Key_D" then
		self.right = true
	end

	self.navigator:setTranslationVector( locals.getTranslationVector( self ) )
end

function FlyManipulator:keyReleased( key )
	if self.animationOnCourse then return end
	
	if key == "Key_W" then
		self.front = false
	end
	if key == "Key_S" then
		self.back = false
	end
	if key == "Key_A" then
		self.left = false
	end
	if key == "Key_D" then
		self.right = false
	end
	
	self.navigator:setTranslationVector( locals.getTranslationVector( self ) )
end

function FlyManipulator:mousePressed( x, y, button, modifiers )	
	-- when right mouse button is pressed, remove manipulator from 'paused' state
	if button == qt.RightButton then
		locals.setPaused( self, not self.paused )
	end
end

function FlyManipulator:mouseDoubleClicked( x, y, button, modifiers )
	if self.animationOnCourse then return end
	
	if button ~= qt.LeftButton then
		return
	end

	local intersector = self.pickIntersector
	local intersections = intersector:intersect( x, y )
	if #intersections == 0 then
		return
	end

	-- sets picked object the examined object and navigate to it
	--TODO: perform navigation task using IViewAnimation
end

local MAXIMUM_ANGLE_INCREMENT = glm.PI
function FlyManipulator:mouseMoved( x, y, button, modifiers )
	if self.paused then
		return
	end
	
	local width = self.canvas.width
	local height = self.canvas.height
	
	
	-- since lua handles all number as double, we need to round center to integer
	local cw = math.floor( width * 0.5 )
	local ch = math.floor( height * 0.5 )

	-- sets cursor position to canva's center
	local localX, localY = self.canvas:mapToGlobal( cw, ch )
   	self.canvas:setCursorPosition( localX, localY )
   	
   	if self.animationOnCourse then return end
	
	-- gets normalized coordinates
	-- since we reset cursor position to 0,0, (x,y) coordinates represents the 
	-- pixel offset of mouse from center. dx and dy are normalized offsets
	local dx, dy = glm.screenToClip( x, y, width, height )
	
	-- uses normalized interval as a linear angle domain [-PI/2 ,PI/2 ] on both directions
	-- angle over Y is built from screen X linear coordinates 'ny' (limited to circle within -MAXIMUM_ANGLE_INCREMENT to MAXIMUM_ANGLE_INCREMENT)
	local angleOverXDir = locals.clamp( dy * glm.PI_2, -MAXIMUM_ANGLE_INCREMENT, MAXIMUM_ANGLE_INCREMENT )
		
	-- angle over X is built from screen Y linear coordinates 'nx' (limited to circle within -MAXIMUM_ANGLE_INCREMENT to MAXIMUM_ANGLE_INCREMENT)
    local angleOverYDir = locals.clamp( dx * glm.PI_2, -MAXIMUM_ANGLE_INCREMENT, MAXIMUM_ANGLE_INCREMENT )
    
    self.navigator:addPitchOffset( angleOverYDir )
    self.navigator:addYawOffset( angleOverXDir )
end

function FlyManipulator:mouseWheel( x, y, delta, modifiers )
	if self.animationOnCourse then return end
	
	local numDegrees = delta / 8
    local numSteps = numDegrees / 15
	
	self.translationVelocity = math.max( 0.5, self.translationVelocity * ( 1 + numSteps ) )
	self.navigator.translationVelocity = self.translationVelocity
end

-------------------------------------------------------------------------------
-- Unused IInputlistener methods
-------------------------------------------------------------------------------
function FlyManipulator:mouseReleased( x, y, button, modifiers ) end

return FlyManipulator
