--[[---------------------------------------------------------------------------
	Lua module of application's MainWindow interface. It returns a constructor
	lua closure that will create and setup MainWindow widget using qt system.
--]]---------------------------------------------------------------------------

local qt = require "qt"

--[[---------------------------------------------------------------------------
	Sets qt resource search path to the given module path. It allows any qt
	resource to be accessed relatively to the module path on disk, using the
	set alias.
	Ex: qt.setSearchPaths( "myAlias", "myModule.core" ) will expand "myAlias:/"
		to the path on disk of module "myModule.core".		
--]]---------------------------------------------------------------------------
qt.setSearchPaths( "lab3d", "lab3d.app" )

-- local variables table
local L = {}

L.fileFilterString = "OSG File (*.ive);;" 

function L.on_action_AddModel_triggered( sender )
	local files = qt.getOpenFileNames( sender, "Select Data File", "", L.fileFilterString  )
	
	-- check whether the user has cancelled file open dialog
	if #files == 0 then return end

	for i = 1, #files do
		local entity = co.new( "lab3d.core.domain.Entity" ).entity
		entity.filename = files[i]
		
		local actorFactory = co.system.services:getService( co.Type["lab3d.core.scene.IActorFactory"] )
		local actor = actorFactory:getOrCreate( entity )
		print( ">>>>", actor )
		
		-- access application main entry point (IApplication service)
		local application = co.system.services:getService( co.Type["lab3d.app.IApplication"] )
		application.context.currentScene:addActor( actor )
	end

end

-- MainWindow constructor
return function( windowTitle )
	local mainWindow = qt.loadUi "lab3d:/ui/MainWindow.ui"
	mainWindow.windowTitle = windowTitle
	
	-- connects slots of mainWindow to lua closures defined in local table L
	qt.connectSlotsByName( mainWindow, L )
	
	return mainWindow
end