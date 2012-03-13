local UpdateNotifier = require "lab3d.dom.UpdateNotifier"
local ProjectObserver = require "lab3d.dom.ProjectObserver"

local M = {}

function M:onProjectOpened( newProject )
	self:onEntitiesAdded( newProject, newProject.entities )
	self.scene.camera.view = newProject.currentView
end

function M:onProjectClosed( project )
	self.scene:clear()
end

function M:onEntitiesAdded( project, entities )
	for i, entity in ipairs( entities ) do
		local actor = self.actorFactory:getOrCreate( entity )
		self.scene:addActor( actor )
	end
end

function M:onEntitiesRemoved( project, entities )
	for i, entity in ipairs( entities ) do
		local actor = self.actorFactory:getOrCreate( entity )
		self.scene:removeActor( actor )
	end
end

function M:onEntitySelectionChanged( project, previous, current )

end

function M:initialize( scene )
	self.scene = scene
	ProjectObserver:addObserver( self )
	UpdateNotifier:addObserver( self )
	
	self.actorFactory = co.system.services:getService( co.Type["lab3d.scene.IActorFactory"] )
	
	-- access application main entry point (IApplication service)
	self.application = co.system.services:getService( co.Type["lab3d.IApplication"] )
	
	return self
end

function M:timeUpdate( dt )
	self.scene:update()
end

return M