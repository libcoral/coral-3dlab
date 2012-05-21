--------------------------------------------------------------------------------
-- Module 'lab3d.scene' (provides 3D visualization)
--------------------------------------------------------------------------------

local pairs = pairs
local ipairs = ipairs
local ca = require "ca"
local lab3d = require "lab3d"

-- create the Scene object
local sceneObject = co.new "lab3d.scene.Scene"
local scene = sceneObject.scene
scene.camera = co.new( "lab3d.dom.Camera" ).camera

-- highlight box model for mark selected node in the scene
local highlight = co.new "lab3d.scene.HighlightModel"

-- save entity transforms to update them when an Entity changes
local entityTransforms = {}

--------------------------------------------------------------------------------
-- Project Observers
--------------------------------------------------------------------------------

local function onEntityAdded( entity )
	co.log( 'INFO', "Entity Added" )

	local transformObject = co.new "lab3d.scene.TransformModel"
	transformObject.entity = entity

	local transform = transformObject.model
	transform:setTranslation( entity.position )
	transform:setOrientation( entity.orientation )
	transform:setScale( entity.scale )

	local model = entity:get( co.Type "lab3d.scene.IModel" )
	transform:addChild( assert( model ) )

	entity.bounds = transform:getBounds()
	entityTransforms[entity] = transform

	scene:addModel( transform )
end

local function onEntityRemoved( entity )
	co.log( 'INFO', "Entity Removed" )

	local transform = assert( entityTransforms[entity] )
	scene:removeModel( transform )
end

ca.observe( "lab3d.dom.IProject", function( e )
	if e.service ~= lab3d.activeProject then return end

	local changedEntities = e.changedFields.entities
	if not changedEntities then return end

	for entity in pairs( changedEntities.added ) do
		onEntityAdded( entity )
	end

	for entity in pairs( changedEntities.removed ) do
		onEntityRemoved( entity )
	end
end )

ca.observe( "lab3d.dom.IEntity", function( e )
	local entity = e.service
	local transform = entityTransforms[entity]
	if not transform then return end

	local changed = e.changedFields
	if changed.scale then
		transform:setScale( changed.scale.current )
	end
	if changed.position then
		transform:setTranslation( changed.position.current )
	end
	if changed.orientation then
		transform:setOrientation( changed.orientation.current )
	end

	if entity == lab3d.workspace.selectedEntity then
		highlight.entity = entity
	end
end )

-- redraw if anything changes
ca.observe( lab3d.projectUniverse, function( e )
	scene:update()
end )

--------------------------------------------------------------------------------
-- Workspace Observer
--------------------------------------------------------------------------------

local observeWorkspace = ca.observe( lab3d.workspace )

function observeWorkspace.activeProject( e )
	if e.previous then
		co.log( 'INFO', "Project Closed" )
		entityTransforms = {}
		scene:clear()
	end

	local newProject = e.current
	if newProject then
		co.log( 'INFO', "New Project" )
		for i, entity in ipairs( newProject.entities ) do
			onEntityAdded( entity )
		end
		scene.camera.view = newProject.currentView
	end
end

function observeWorkspace.selectedEntity( e )
	if e.current then
		highlight.entity = e.current
		if not e.previous then
			scene:addModel( highlight.model )
		end
	else
		scene:removeModel( highlight.model )
	end
end

--------------------------------------------------------------------------------
-- Module Functions
--------------------------------------------------------------------------------

local M = { scene = scene }

function M.getPainter()
	return sceneObject.painter
end

function M.setGLContext( glContext )
	sceneObject.glContext = glContext
end

return M
