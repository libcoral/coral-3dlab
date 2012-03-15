--[[---------------------------------------------------------------------------
	Observes entities and forwards notifications using lua closures.
--]]---------------------------------------------------------------------------
local EntityObserver = co.Component( "lab3d.helper.EntityObserver" )

function EntityObserver:__init()
	-- empty
end

function EntityObserver:onNameChanged( entity, name )
	for k, v in pairs( self.observers[entity] ) do
		if v and type( v.onNameChanged ) == "function" then
			v:onNameChanged( entity, name )
		end
	end
end

function EntityObserver:onDecoratorAdded( entity, decorator )
	for k, v in pairs( self.observers[entity] ) do
		if v and type( v.onDecoratorAdded ) == "function" then
			v:onDecoratorAdded( entity, decorator )
		end
	end
end

function EntityObserver:onDecoratorRemoved( entity,  decorator )
	for k, v in pairs( self.observers[entity] ) do
		if v and type( v.onDecoratorRemoved ) == "function" then
			v:onDecoratorRemoved( entity, decorator )
		end
	end
end

function EntityObserver:onPoseChanged( entity, position, orientation )
	for k, v in pairs( self.observers[entity] ) do
		if v and type( v.onPoseChanged ) == "function" then
			v:onPoseChanged( entity, position, orientation )
		end
	end
end

function EntityObserver:onScaleChanged( entity, scale )
	for k, v in pairs( self.observers[entity] ) do
		if v and type( v.onScaleChanged ) == "function" then
			v:onScaleChanged( entity, scale )
		end
	end
end

local M = {}
 
function M:addObserver( entity, obsTable )
	if not self.observers then
		-- initialize
		self.observers = {}
		M.instance = EntityObserver{ observers = M.observers }.observer
	end
	
	entity:addObserver( self.instance )
	
	self.observers[entity] = self.observers[entity] or {}
	self.observers[entity][obsTable] = obsTable
end

function M:removeObserver( entity, obsTable )
	self.observers[entity][obsTable] = nil
end

return M