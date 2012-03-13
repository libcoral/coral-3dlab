local helper = require "siv.helper.CalciumHelper"

local Project =  co.Component( "lab3d.core.domain.Project" )

function Project:__init()
	self.entities = {}
	self.name = self.name or ""
	self.application = co.system.services:getService( co.Type["lab3d.core.IApplication"] )
end

function Project:save( filename )
end

function Project:getName()
	return self.name
end

function Project:getEntities()
	return self.entities
end

function Project:addEntity( entity )
	self.entities[#self.entities+1] = entity
	print( "adding change",  self.object.project )
	self.application.space:addChange( self.object.project )
	self.application.space:notifyChanges()
end

function Project:getSelectedEntity()
	return self.selectedEntity
end

function Project:setEntitySelected( entity )
	if self.selectedEntity == entity then return end
	
	self.selectedEntity = entity
	self.application.space:addChange( self.object.project )
	self.application.space:notifyChanges()
end

function Project:removeEntity( entity )
	local obs = self.entities
	local size = #obs
	for i = 1, size do
		if obs[i] == entity then 
			obs[i] = obs[size]
			obs[size] = nil
			
			self.application.space:addChange( self.object.project )
			self.application.space:notifyChanges()
			return
		end
	end
	error( "no such entity" )
end

function Project:findEntity( entityName )
	local obs = self.entities
	local size = #obs
	for i = 1, size do
		if obs[i].name == entityName then 
			return obs[i]
		end
	end
	return nil
end
