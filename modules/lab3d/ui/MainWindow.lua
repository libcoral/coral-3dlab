--[[---------------------------------------------------------------------------
	Lua module of application's MainWindow interface. It returns a constructor
	lua closure that will create and setup MainWindow widget using qt system.
--]]---------------------------------------------------------------------------

local qt = require "qt"

-- local variables table
local L = {}

L.fileFilterString = "OSG File (*.ive);;"
L.projectFilterString = "Lua Project File (*.lua);;"

function L.on_action_AddModel_triggered( sender )
	local files = qt.getOpenFileNames( sender, "Select Data File", "", L.fileFilterString  )
	
	-- check whether the user has cancelled file open dialog
	if #files == 0 then return end

	for i = 1, #files do
		local entity = co.new( "lab3d.dom.Entity" ).entity
		entity.filename = files[i]
		
		local application = co.system.services:getService( co.Type["lab3d.IApplication"] )
		application.currentProject:addEntity( entity )
	end
end

function L.on_action_OpenProject_triggered( sender )
	local files = qt.getOpenFileNames( sender, "Select Project File", "", L.projectFilterString  )
	
	-- check whether the user has cancelled file open dialog
	if #files == 0 then return end

	local projectFile = files[1]
			
	local application = co.system.services:getService( co.Type["lab3d.IApplication"] )
	application:openProject( projectFile )
end

function L.on_action_SaveProject_triggered( sender )
	local file = qt.getSaveFileName( sender, "Save Project File", "", L.projectFilterString  )
	
	if not file or file == "" then return false end
	
	local application = co.system.services:getService( co.Type["lab3d.IApplication"] )
	application:saveProject( application.currentProject, file )
end

-- MainWindow constructor
return function( windowTitle )
	local mainWindow = qt.loadUi "lab3d:/ui/MainWindow.ui"
	mainWindow.windowTitle = windowTitle
	
	-- connects slots of mainWindow to lua closures defined in local table L
	qt.connectSlotsByName( mainWindow, L )

	return mainWindow
end