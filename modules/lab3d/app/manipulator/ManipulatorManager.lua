local qt = require "qt"

-- A global service for managing manipulators
local function checkManipulatorExists( manipulators, name )
	if not manipulators[name] then
		error( "No such manipulator found by name '" .. name .. "'" )
	end
end

local function addManipulatorToUI( manager, manipulator )
	local name = manipulator.name
	if not manager.actionGroup then
		-- creates a action group to add all manipulators into
		manager.actionGroup = qt.new( "QActionGroup" )
	end
	-- creates an action for the manipulator
	local action = qt.new( "QAction" )
	action.text = manipulator.name
	action.icon = qt.Icon( manipulator.resourceIcon )
	action.checkable = true
	qt.mainWindow.toolBar:insertAction( 2, action )
	manager.actionGroup:addActionIntoGroup( action )
	
	-- save manipulator action
	manager.manipulators[name].action = action
	
	local slot = function( sender, value ) 
		if value then 
			manager:setCurrent( name )
		end
	end
	
	action:connect( "toggled(bool)", slot )
end

local ManipulatorManager =  co.Component( "lab3d.app.manipulator.ManipulatorManager" )

function ManipulatorManager:__init()
	-- this allows a manipulator list to be previously passed at construction time
	self.manipulators = self.manipulators or {}
	
	-- creates a timer using qt system
	local system = co.getService( "qt.ISystem" )
	self.timerCookie = 	system:addTimer( self.object.timer )
	system:startTimer( self.timerCookie, 1000.0/60.0 )
	
	local application = co.system.services:getService( co.Type["lab3d.app.IApplication"] )
	self.application = application
end

function ManipulatorManager:timeUpdate( dt )
	if not self.currentManipulator then
		return
	end
	-- evolve current manipulator navigator
	self.currentManipulator.navigator:evolve( dt )
	self.application.context.currentScene:update()
end

function ManipulatorManager:getManipulatorByName( name )
	checkManipulatorExists( self.manipulators, name )
	return self.manipulators[name].instance
end

function ManipulatorManager:addManipulator( manipulator )
	local name = manipulator.name
	if self.manipulators[name] then
		error( "Manipulator name clash between instance " .. tostring( self.manipulators[name].instance ) .. " and " .. tostring( manipulator ) )
	end
	self.manipulators[name] = { instance = manipulator }
	addManipulatorToUI( self, manipulator )
end

function ManipulatorManager:setCurrent( name )
	checkManipulatorExists( self.manipulators, name )
	if self.currentManipulator then
		self.currentManipulator:deactivate()
		qt.mainWindow:getCentralWidget():unsetCursor()
	end
	self.currentManipulator = self.manipulators[name].instance
	self.currentManipulator:activate()
	local cursor = self.currentManipulator.normalCursor
	if cursor > 0 then
		qt.mainWindow:getCentralWidget():setCursor( cursor )
	end
end

function ManipulatorManager:mousePressed( x, y, button, modifiers )
	if not self.currentManipulator then return end
	
	-- apply drag cursor, if available
	local cursor = self.currentManipulator.dragCursor
	if cursor > 0 then
		qt.mainWindow:getCentralWidget():setCursor( cursor )
	end
	self.currentManipulator:mousePressed( x, y, button, modifiers )
end

function ManipulatorManager:mouseMoved( x, y, button, modifiers )
	if not self.currentManipulator then return end
	self.currentManipulator:mouseMoved( x, y, button, modifiers )
end

function ManipulatorManager:mouseReleased( x, y, button, modifiers )
	if not self.currentManipulator then return end
	self.currentManipulator:mouseReleased( x, y, button, modifiers )
	
	-- unapply drag cursor, if available
	local cursor = self.currentManipulator.dragCursor
	local normalCursor = self.currentManipulator.normalCursor
	if cursor > 0 and normalCursor > 0 then
		qt.mainWindow:getCentralWidget():setCursor( normalCursor )
	end
end

function ManipulatorManager:mouseDoubleClicked( x, y, button, modifiers )
	if not self.currentManipulator then return end
	self.currentManipulator:mouseDoubleClicked( x, y, button, modifiers )
end

function ManipulatorManager:keyPressed( key )
	if not self.currentManipulator then return end
	self.currentManipulator:keyPressed( key )
end

function ManipulatorManager:keyReleased( key )
	if not self.currentManipulator then return end
	self.currentManipulator:keyReleased( key )
end

function ManipulatorManager:mouseWheel( x, y, button, modifiers )
	if not self.currentManipulator then return end
	self.currentManipulator:mouseWheel( x, y, button, modifiers )
end

return ManipulatorManager
