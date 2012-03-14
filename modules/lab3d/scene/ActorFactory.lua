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
		assert( actor.associatedEntity == entity )
		return actor
	end
	
	local actorObj = co.new "lab3d.scene.Actor"
	
	local actor = actorObj.actor
	actor.associatedEntity = entity
	
	M.actors[entity] = actor
	return actor
end

function ActorFactory:clear()
	M.actors = {}
end

return ActorFactory
