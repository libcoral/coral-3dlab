--------------------------------------------------------------------------------
-- Coral 3D Lab Initialization
--------------------------------------------------------------------------------

local ca = require "ca"

-- create the application workspace
local workspace = co.new( "lab3d.dom.Workspace" ).workspace

--------------------------------------------------------------------------------
-- Calcium Model/Space for the 3D Lab Workspace and Projects
--------------------------------------------------------------------------------

local function createUniverse( modelName )
	local model = co.new( "ca.Model" ).model
	model.name = modelName
	local universeObject = co.new "ca.Universe"
	universeObject.model = model
	return model, universeObject.universe
end

local function createSpace( universe, rootObject )
	local spaceObject = co.new "ca.Space"
	spaceObject.universe = universe
	local space = spaceObject.space
	space:initialize( rootObject )
	return space
end

local workspaceModel, workspaceUniverse = createUniverse( 'Workspace' )
local workspaceSpace = createSpace( workspaceUniverse, workspace.provider )

local projectModel, projectUniverse = createUniverse( 'Project' )
local projectSpace = nil

-- observe changes in the active project to figure out whether it "is dirty"
local hasUnsavedChanges = false
ca.observe( projectUniverse, function( e )
	hasUnsavedChanges = true
end )

local observeWorkspace = ca.observe( workspace )
function observeWorkspace.activeProject( e )
	if e.previous then
		projectSpace = nil, nil
	end
	local newActiveProject = e.current
	if newActiveProject then
		projectSpace = createSpace( projectUniverse, newActiveProject.provider )
		projectSpace:notifyChanges()
		hasUnsavedChanges = false
	end
end

--------------------------------------------------------------------------------
-- Project Load/Save from/to Archive
--------------------------------------------------------------------------------

local projectArchiver = co.new "ca.LuaArchive"
projectArchiver.model = projectModel

local function saveProject( project, filePath )
	projectArchiver.file.name = filePath
	projectArchiver.archive:save( project.provider )
end

--------------------------------------------------------------------------------
-- Module Functions
--------------------------------------------------------------------------------

-- the 'lab3d' module
local M = { workspace = workspace, projectUniverse = projectUniverse }

function M.step()
	if projectSpace then
		projectSpace:notifyChanges()
	end
	workspaceSpace:notifyChanges()
	if projectSpace then
		projectSpace:notifyChanges()
	end
end

function M.newProject()
	workspace.activeProject = co.new( "lab3d.dom.Project" ).project
end

function M.closeProject()
	workspace.activeProject = nil
end

function M.hasUnsavedChanges()
	return hasUnsavedChanges
end

function M.saveProject()
	local project = assert( workspace.activeProject, "no active project" )
	local filePath = project.filePath
	assert( project.filePath ~= "", "the active project has no file path" )
	saveProject( project, filePath )
	hasUnsavedChanges = false
end

-- unrecognized module calls are delegated to the workspace
return setmetatable( M, {
	__index = function( t, k ) return workspace[k] end,
	__newindex = function( t, k, v ) workspace[k] = v end,
} )
