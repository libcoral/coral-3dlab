--[[---------------------------------------------------------------------------
	Lua module of application's MainWindow interface. It returns a constructor
	lua closure that will create and setup MainWindow widget using qt system.
--]]---------------------------------------------------------------------------

local qt = require "qt"

-- local variables table
local L = {}

L.fileFilterString = "OSG File (*.ive);;" 

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

-- MainWindow constructor
return function( windowTitle )
	local mainWindow = qt.loadUi "lab3d:/ui/MainWindow.ui"
	mainWindow.windowTitle = windowTitle
	
	-- connects slots of mainWindow to lua closures defined in local table L
	qt.connectSlotsByName( mainWindow, L )
	
	local application = co.system.services:getService( co.Type["lab3d.IApplication"] )
	
	return mainWindow
end