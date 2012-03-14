local glm = require "glm"
local View = require "lab3d.dom.View"
local helper = require "siv.helper.CalciumHelper"

local Project =  co.Component( "lab3d.dom.Project" )

function Project:__init()
	self.entities = {}
	self.name = self.name or ""
	self.application = co.system.services:getService( co.Type["lab3d.IApplication"] )
	
	local viewObj = View{ position = glm.Vec3( 0, -100, 0 ) }
	self.currentView = viewObj.view; -- default camera view
end

function Project:setName( name )
	self.name = name
end

function Project:getName()
	return self.name
end

function Project:setEntities( entities )
	self.entities = entities
end

function Project:getEntities()
	return self.entities
end

function Project:addEntity( entity )
	self.entities[#self.entities+1] = entity
	self.application.space:addChange( self.object.project )
	self.application.space:notifyChanges()
end

function Project:getSelectedEntity()
	return self.selectedEntity
end

function Project:setSelectedEntity( entity )
	self.selectedEntity = entity
end

function Project:setCurrentView( view )
	self.currentView = view
end

function Project:getCurrentView()
	return self.currentView
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
