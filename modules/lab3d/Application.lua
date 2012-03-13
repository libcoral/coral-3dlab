--[[---------------------------------------------------------------------------
	Application Component.
	Provides the main entry point for all application level services and
	instances sucha as IScene through IApplicationContext service.
--]]---------------------------------------------------------------------------

local helper = require "lab3d.helper.CalciumHelper"
local observeFields = require "lab3d.helper.ObserveFields"

--[[---------------------------------------------------------------------------
	Local utility functions
--]]---------------------------------------------------------------------------

-- local function table for use along with ObserveFields
local L = {}

local function notifyProjectOpened( self )
	local obs = self.projectObservers
	for i = 1, #obs do
		obs[i]:onProjectOpened( self.currentProject )
	end
end

local function notifyProjectClosed( self )
	local obs = self.projectObservers
	for i = 1, #obs do
		obs[i]:onProjectClosed( self.currentProject )
	end
end

local function notifyEntityAdded( self, entities )
	local obs = self.projectObservers
	for i = 1, #obs do
		obs[i]:onEntitiesAdded( self.currentProject, entities )
	end
end

local function notifyEntityRemoved( self, entities )
	local obs = self.projectObservers
	for i = 1, #obs do
		obs[i]:onEntitiesRemoved( self.currentProject, entities )
	end
end

local function notifyEntitySelectionChanged( self, previous, current )
	local obs = self.projectObservers
	for i = 1, #obs do
		obs[i]:onEntitySelectionChanged( self.currentProject, previous, current )
	end
end

local function openProject( self, projectObj )
	if self.space and self.currentProject then
		observeFields:removeFieldObserver( self.space, self.currentProject, self )
	end
	
	notifyProjectClosed( self )
	
	self.space = helper:setupCaSpace( self.model )

	self.projectObj = projectObj
	self.currentProject = self.projectObj.project
	self.space:setRootObject( self.projectObj )
	observeFields:addFieldObserver( self.space, self.currentProject, self )
	
	notifyProjectOpened( self )
end

--[[---------------------------------------------------------------------------
	Component declaration
--]]---------------------------------------------------------------------------
local Application =  co.Component( "lab3d.Application" )

function Application:__init()
	self.model = helper:setupModel( "Project" )
	self.archiveObj = co.new "ca.LuaArchive"
	self.archiveObj.model = self.model
	self.projectObservers = {}
end

function Application:saveProject( project, filename )
	self.archiveObj.file.name = fileName
	self.archiveObj.archive:save( self.projectObj )
end

function Application:openProject( filename )
	self.archiveObj.file.name = fileName
	openProject( self, self.archiveObj.archive:restore() )
end

function Application:newBlankProject()
	openProject( self, co.new( "lab3d.dom.Project" ) )
end

function Application:addProjectObserver( observer )
	local obs = self.projectObservers
	obs[#obs + 1] = observer
end

function Application:removeProjectObserver( observer )
	local obs = self.openWorldObservers
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

function Application:getCurrentProject()
	return self.currentProject
end

function Application:getSpace()
	return self.space
end

function Application:onEntitiesAdded( service, addedObjects )
	notifyEntityAdded( self, addedObjects )
end

function Application:onEntitiesRemoved( service, removedObjects )
	notifyEntityRemoved( self, removedObjects )
end

function Application:onSelectedEntityChanged( service, previous, current )
	notifyEntitySelectionChanged( self, previous, current )
end

