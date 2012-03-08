-- A global service for managing manipulators
local function checkManipulatorExists( manipulators, name )
	if not manipulators[name] then
		error( "No such manipulator found by name '" .. name .. "'" )
	end
end

local ManipulatorManager =  co.Component( "lab3d.app.manipulator.ManipulatorManager" )

function ManipulatorManager:__init()
	-- this allows a manipulator list to be previously passed at construction time
	self.manipulators = self.manipulators or {}
end

function ManipulatorManager:getManipulatorByName( name )
	checkManipulatorExists( self.manipulators, name )
	return self.manipulators[name]
end

function ManipulatorManager:addManipulator( manipulator )
	local name = manipulator.name
	if self.manipulators[name] then
		error( "Manipulator name clash between instance " .. tostring( self.manipulators[name] ) .. " and " .. tostring( manipulator ) )
	end
	self.manipulators[name] = manipulator
end

function ManipulatorManager:onManipulatorNameChanged( service, previous, current )
	checkManipulatorExists( self.manipulators, current )
	if self.currentManipulator then
		self.currentManipulator:deactivate()
	end
	self.currentManipulator = self.manipulators[current]
	self.currentManipulator:activate()
end

function ManipulatorManager:mousePressed( x, y, button, modifiers )
	if not self.currentManipulator then return end
	self.currentManipulator:mousePressed( x, y, button, modifiers )
end

function ManipulatorManager:mouseMoved( x, y, button, modifiers )
	if not self.currentManipulator then return end
	self.currentManipulator:mouseMoved( x, y, button, modifiers )
end

function ManipulatorManager:mouseReleased( x, y, button, modifiers )
	if not self.currentManipulator then return end
	self.currentManipulator:mouseReleased( x, y, button, modifiers )
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
