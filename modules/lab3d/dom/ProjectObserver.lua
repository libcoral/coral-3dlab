--[[---------------------------------------------------------------------------
	Observes the project and notify changes through lua closures 
--]]---------------------------------------------------------------------------
local ProjectObserver = co.Component( "lab3d.dom.ProjectObserver" )

function ProjectObserver:__init()
end

function ProjectObserver:onProjectOpened( newProject )
	for k,v in pairs( self.observers ) do
		if v and type( v.onProjectOpened ) == "function" then
			v:onProjectOpened( newProject )
		end
	end
end

function ProjectObserver:onProjectClosed( project )
	for k,v in pairs( self.observers ) do
		if v and type( v.onProjectClosed ) == "function" then
			v:onProjectClosed( project )
		end
	end
end

function ProjectObserver:onEntitiesAdded( project, entities )
	for k,v in pairs( self.observers ) do
		if v and type( v.onEntitiesAdded ) == "function" then
			v:onEntitiesAdded( project, entities )
		end
	end
end

function ProjectObserver:onEntitiesRemoved( project, entities )
	for k,v in pairs( self.observers ) do
		if v and type( v.onEntitiesRemoved ) == "function" then
			v:onEntitiesRemoved( project, entities )
		end
	end
end

function ProjectObserver:onEntitySelectionChanged( project, previous, current )
	for k,v in pairs( self.observers ) do
		if v and type( v.onEntitySelectionChanged ) == "function" then
			v:onEntitySelectionChanged( project, previous, current )
		end
	end
end

local M = {}
 
function M:addObserver( obsTable )
	if not self.observers then
		-- initialize
		self.observers = {}
		M.instance = ProjectObserver{ observers = M.observers }.observer
		co.system.services:getService( co.Type["lab3d.IApplication"] ):addProjectObserver( M.instance )
	end
	
	self.observers[obsTable] = obsTable
end

function M:removeObserver( obsTable )
	self.observers[obsTable] = nil
end

return M