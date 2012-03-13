--[[---------------------------------------------------------------------------
	Map instances domain layer instances of IEntity to graphical layer instances
	of IActor.
--]]---------------------------------------------------------------------------
local ActorFactory =  co.Component( "lab3d.scene.ActorFactory" )

-- hash of mapped entities and actors
local M = { actors = {} }

function ActorFactory:getOrCreate( entity )
	local actor = M.actors[entity]
	-- if an actor has already been build for the given entity, retrieve it...
	if actor then
		return actor
	end
	
	actor = co.new "lab3d.scene.Actor"
	actor.entity = entity
	
	M.actors[entity] = actor.actor
	return actor.actor
end

function ActorFactory:clear()
	M.actors = {}
end

return ActorFactory
