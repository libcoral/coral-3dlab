--[[---------------------------------------------------------------------------
	Entity Component.
	Provides lab3d.dom.Entity interface which contains common object 
	attributes such as name, position and scale and a data attribute that 
	points to a specific data container	type. \see lab3d.domai.IEntity.
--]]---------------------------------------------------------------------------

local eigen = require "eigen"

local function notifyNameChanged( self, newName )
	local obs = self.observers
	local size = #obs
	for i = 1, size do
		obs[i]:onNameChanged( self.object.entity, newName )
	end
end

local function notifyDecoratorAdded( self, decorator )
	local obs = self.observers
	local size = #obs
	for i = 1, size do
		obs[i]:onDecoratorAdded( self.object.entity, decorator )
	end
end

local function notifyDecoratorRemoved( self, decorator )
	local obs = self.observers
	local size = #obs
	for i = 1, size do
		obs[i]:onDecoratorRemoved( self.object.entity, decorator )
	end
end

local function notifyPoseChanged( self, position, orientation )
	local obs = self.observers
	local size = #obs
	for i = 1, size do
		obs[i]:onPoseChanged( self.object.entity, position, orientation )
	end
end

local function notifyScaleChanged( self, scale )
	local obs = self.observers
	local size = #obs
	for i = 1, size do
		obs[i]:onScaleChanged( self.object.entity, scale )
	end
end
-------------------------------------------------------------------------------
-- Component declaration
-------------------------------------------------------------------------------
local Entity =  co.Component( "lab3d.dom.Entity" )

-- Entity constructor
function Entity:__init()
	self.name = self.name or ""
	self.scale = self.scale or eigen.Vec3( 1, 1, 1 )
	self.position = self.position or eigen.Vec3()
	self.orientation = self.orientation or eigen.Quat()
	self.bounds = self.bounds or co.new "lab3d.dom.BoundingBox"
	self.filename = ""
	self.decorators = self.decorators or {}
	self.observers = {}
end

function Entity:getData()
	return self.data
end

function Entity:getName() 
	return self.name
end

function Entity:setName( name )
	self.name = name
	notifyNameChanged( self, self.name)
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
	notifyPoseChanged( self, position, self.orientation )
end

function Entity:getScale()
	return self.scale
end

function Entity:setScale( scale ) 
	 self.scale = scale
	 notifyScaleChanged( self, self.scale )
end

function Entity:getBounds()
	return self.bounds
end

function Entity:setBounds( bounds )
	self.bounds = bounds
end

function Entity:addDecorator( decorator )
	local decoTypeName = decorator.interface.fullName
	local pos = 1
	while pos <= #self.decorators and self.decorators[pos].interface.fullName < decoTypeName do
		pos = pos + 1
	end
	
	table.insert( self.decorators, pos, decorator )
	notifyDecoratorAdded( self, decorator )
end

function Entity:removeDecorator( decorator )
	for i, v in ipairs( self.decorators ) do
		if v == decorator then
			table.remove( self.decorators, i )
			return
		end
	end
	notifyDecoratorRemoved( self, decorator )
end

function Entity:getDecoratorsForType( type )
	local decoTypeName = type.fullName
	local pos = 1
	while pos <= #self.decorators and self.decorators[pos].interface.fullName ~= decoTypeName do
		pos = pos + 1
	end
	
	if pos == ( #self.decorators + 1 ) then return {} end
	
	local firstPos = pos
	local lastPos = firstPos
	local types = {}
	while lastPos <= #self.decorators and self.decorators[pos].interface.fullName == decoTypeName do
		table.insert( types, self.decorators[lastPos] )
		lastPos = lastPos + 1
	end
	
	return types
end

function Entity:addObserver( observer )
	self.observers[#self.observers+1] = observer
end

function Entity:removeObserver( observer )
	local obs = self.observers
	local size = #obs
	for i = 1, size do
		if obs[i] == observer then 
			obs[i] = obs[size]
			obs[size] = nil
			return
		end
	end
	error( "no such observer" )
end
	
function Entity:getDecorators()
	return self.decorators
end

function Entity:setDecorators( decorators )
	self.decorators = decorators
end

return Entity
