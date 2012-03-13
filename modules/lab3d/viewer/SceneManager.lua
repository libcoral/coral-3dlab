local ProjectObserver = require "lab3d.core.domain.ProjectObserver"

local M = {}

function M:onProjectOpened( newProject )

end

function M:onProjectClosed( project )

end

function M:onEntitiesAdded( project, entities )
	print( "ENTITIES ADDED!!", #entities )
	for i, entity in ipairs( entities ) do
		local actor = self.actorFactory:getOrCreate( entity )
		self.scene:addActor( actor )
	end

end

function M:onEntitiesRemoved( project, entities )

end

function M:onEntitySelectionChanged( project, previous, current )

end

return function( scene )
	local self = setmetatable( {}, { __index = M } )
	self.scene = scene
	ProjectObserver:addObserver( self )
	
	self.actorFactory = co.system.services:getService( co.Type["lab3d.core.scene.IActorFactory"] )
	
	-- access application main entry point (IApplication service)
	self.application = co.system.services:getService( co.Type["lab3d.core.IApplication"] )
	
	return self
end