-- Creates and configures the InputListener for pick manipulator component
local SelectionManipulator =  co.Component( "lab3d.manipulator.SelectionManipulator" )

function SelectionManipulator:__init()
	self.name = self.name or "Selection Manipulator"
end

function SelectionManipulator:getName() 
	return self.name
end

function SelectionManipulator:setName( name ) 
	self.name = name
end

function SelectionManipulator:getDescription()
	return "Selection Manipulator"
end

function SelectionManipulator:getResourceIcon()
	return "lab3d:/ui/resources/select.png"
end

function SelectionManipulator:getNormalCursor()
	return -1 -- do not change cursor, the manipulator itself handles it (see setPaused closue)
end

function SelectionManipulator:getDragCursor()
	return -1 -- do not change cursor, the manipulator itself handles it (see setPaused closue)
end

function SelectionManipulator:getNavigator()
	return self.navigator
end

function SelectionManipulator:setNavigator( navigator )
	self.navigator = navigator
end
-------------------------------------------------------------------------------
-- Component implementation
-------------------------------------------------------------------------------
function SelectionManipulator:mousePressed( x, y, buttons, modifiers )

--	local intersector = self.pickIntersector
--	local intersections = intersector:intersect( x, y )
--	local pickedObject = nil
--	if #intersections > 0 then
--		pickedObject = intersections[1].object
--	end
--
--	local worldManager = co.system.services:getService( co.Type["siv.world.IWorldManager"] )
--	local user = worldManager.world.user
--	if user.selectedEntity == pickedObject then return end
--	
--	worldManager.undo:beginChange( "Selecionar Objeto(s)" )
--	user.selectedEntity = pickedObject
--	worldManager.space:addChange( user )
--	worldManager.undo:endChange()
end
-------------------------------------------------------------------------------
-- Unused IInputlistener methods
-------------------------------------------------------------------------------
function SelectionManipulator:activate() end
function SelectionManipulator:deactivate() end
function SelectionManipulator:keyPressed( key ) end
function SelectionManipulator:keyReleased( key ) end
function SelectionManipulator:mouseMoved( x, y, button, modifiers ) end
function SelectionManipulator:mouseReleased( x, y, button, modifiers ) end
function SelectionManipulator:mouseDoubleClicked( x, y, button, modifiers ) end
function SelectionManipulator:mouseWheel( x, y, button, modifiers ) end

function SelectionManipulator:getNavigator()
	-- selection manipulator does not use a navigator
	return nil
end

function SelectionManipulator:setNavigator( navigator )
	-- selection manipulator does not use a navigator
end

return SelectionManipulator

