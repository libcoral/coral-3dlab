--[[---------------------------------------------------------------------------
	Entity Component.
	Provides lab3d.dom.Entity interface which contains common object 
	attributes such as name, position and scale and a data attribute that 
	points to a specific data container	type. \see lab3d.domai.IEntity.
--]]---------------------------------------------------------------------------

local glm = require "glm"

-------------------------------------------------------------------------------
-- Component declaration
-------------------------------------------------------------------------------
local Entity =  co.Component( "lab3d.dom.Entity" )

-- Entity constructor
function Entity:__init()
	self.name = self.name or ""
	self.scale = self.scale or glm.Vec3( 1, 1, 1 )
	self.position = self.position or glm.Vec3()
	self.orientation = self.orientation or glm.Quat()
	self.bounds = self.bounds or co.new "lab3d.dom.BoundingBox"
	self.filename = ""
end

function Entity:getData()
	return self.data
end

function Entity:getName() 
	return self.name
end

function Entity:setName( name )
	self.name = name
end

function Entity:setFilename( filename )
	self.filename = filename
end

function Entity:getFilename() 
	return self.filename
end

function Entity:getOrientation()
	return self.orientation
end

function Entity:setOrientation( orientation )
	self.orientation = orientation
end

function Entity:getPosition()
	return self.position
end

function Entity:setPosition( position ) 
	self.position = position
end

function Entity:getScale()
	return self.scale
end

function Entity:setScale( scale ) 
	 self.scale = scale
end

function Entity:getBounds()
	return self.bounds
end

function Entity:setBounds( bounds )
	self.bounds = bounds
end

function Entity:getSelected()
	return self.selected
end

function Entity:setSelected( value )
	self.selected = value
end

-- IActorProvider method
function Entity:getOrCreateActor( filename )
	
end

return Entity
