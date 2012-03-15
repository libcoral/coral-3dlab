local ObserveFields = require "lab3d.helper.ObserveFields"
local UpdateNotifier = require "lab3d.helper.UpdateNotifier"
local EntityObserver = require "lab3d.helper.EntityObserver"
local ProjectObserver = require "lab3d.helper.ProjectObserver"

--[[---------------------------------------------------------------------------
	Local utility functions
--]]---------------------------------------------------------------------------
local L = {}

--[[---------------------------------------------------------------------------
	Module functions
--]]---------------------------------------------------------------------------


local M = {}

function M:updateHighlightModel( entity )
	if entity ~= self.application.currentProject.selectedEntity then return end
	self.highlightModel.entity = entity
end

function M:onDecoratorAdded( entity, decorator )
	local group = self.entityTransforms[entity]
	if not group then return end
	
	-- if decorator is an IModel, add it to the group
	if decorator.interface.fullName == "lab3d.scene.IModel" then
		group:addChild( decorator )
	end
end

function M:onDecoratorRemoved( entity,  decorator )
	local group = self.entityTransforms[entity]
	if not group then return end
	
	-- if decorator is an IModel, add it to the group
	if decorator.interface.fullName == "lab3d.scene.IModel" then
		group:removeChild( decorator )
		
		if group:getNumChildren() == 0 then
			self.entityTransforms[entity] = nil
		end
	end
end

function M:onPoseChanged( entity, position, orientation )
	local group = self.entityTransforms[entity]
	if not group then return end
	group:setTranslation( position )
	group:setOrientation( orientation )
	updateHighlightModel( entity )
end

function M:onScaleChanged( entity, scale )
	local group = self.entityTransforms[entity]
	if not group then return end
	group:setScale( scale )
	updateHighlightModel( entity )
end

function M:onProjectOpened( newProject )
	self:onEntitiesAdded( newProject, newProject.entities )
	self.scene.camera.view = newProject.currentView
end

function M:onProjectClosed( project )
	self.scene:clear()
end

function M:onEntitiesAdded( project, entities )
	for i, entity in ipairs( entities ) do
		-- create a transform model
		local groupObj = co.new "lab3d.scene.TransformModel"
		groupObj.entity = entity
		
		local group = groupObj.model
		group:setTranslation( entity.position )
		group:setOrientation( entity.orientation )
		group:setScale( entity.scale )
		local modelDecorators = entity:getDecoratorsForType( co.Type["lab3d.scene.IModel"] )
		for _, v in ipairs( modelDecorators ) do
			group:addChild( v )
		end
		entity.bounds = group:getBounds()
		
		self.entityTransforms[entity] = group
		
		self.scene:addModel( group )
		
		-- start listening to changes in this entity
		EntityObserver:addObserver( entity, self )
	end
end

function M:onEntitiesRemoved( project, entities )
	for i, entity in ipairs( entities ) do
		local entityTransformModel = self.entityTransforms[entity]
		if entityTransformModel then
			self.scene:removeModel( entityTransformModel )
			-- stop listening to changes in this entity
			EntityObserver:removeObserver( entity, self )
		end
	end
end

function M:onEntitySelectionChanged( project, previous, current )
	if current then
		self.highlightModelObj.entity = current
		self.scene:addModel( self.highlightModelObj.model )
	else
		self.scene:removeModel( self.highlightModelObj.model )
	end
end

function M:initialize( scene )
	self.scene = scene
	
	-- highlight box model for mark selected node in the scene
	self.highlightModelObj = co.new "lab3d.scene.HighlightModel"
	
	-- save entity transforms to update its position/scale/orientation when a Entity change
	self.entityTransforms = {}
	
	-- registers self table as project observer, using lua api
	ProjectObserver:addObserver( self )
	
	-- registers self table as update notifier observer, using lua api
	UpdateNotifier:addObserver( self )
	
	-- access application main entry point (IApplication service)
	self.application = co.system.services:getService( co.Type["lab3d.IApplication"] )
	
	return self
end

function M:timeUpdate( dt )
	self.scene:update()
end

return M