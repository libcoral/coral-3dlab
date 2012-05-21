--[[---------------------------------------------------------------------------
	Lua module of application's MainWindow interface. It returns a constructor
	lua closure that will create and setup MainWindow widget using qt system.
--]]---------------------------------------------------------------------------

local ipairs = ipairs
local qt = require "qt"
local lab3d = require "lab3d"
local eigen = require "eigen"

-- local variables table
local L = {}

L.fileFilterString = "OpenSceneGraph File (*.ive *.osg *.osgb *.osgt *.3ds *.dxf *.fbx *.obj *.ply)"
L.projectFilterString = "Lua Project File (*.lua);;"

function L.confirmationBox_finished( sender, returnedCode )
	L.confirmationDlgReturnCode = returnedCode
end

function L.createConfirmationMsgBox()
	L.confirmationDlg = qt.new "QMessageBox"
	L.confirmationDlg.windowTitle = "Unsaved Changes"
	L.confirmationDlg.standardButtons = qt.MessageBox.Cancel + qt.MessageBox.Discard + qt.MessageBox.Save
	L.confirmationDlg:connect( "finished(int)", L.confirmationBox_finished )
end

function L.onCloseEvent( sender )
	return L.askForSaveCurrentProject( sender )
end

function L.askForSaveCurrentProject( sender )
	if lab3d.hasUnsavedChanges() then
		L.confirmationDlg.text = "Save project before closing?"
		L.confirmationDlg:invoke( "exec()" )
		if L.confirmationDlgReturnCode == qt.MessageBox.Cancel then
			return false
		end
		if L.confirmationDlgReturnCode == qt.MessageBox.Save then
			return L.on_action_SaveProject_triggered( sender )
		end
	end

	return true
end

function L.on_action_AddModel_triggered( sender )
	local files = qt.getOpenFileNames( sender, "Select Data File", "", L.fileFilterString  )
	local entity
	for i, filename in ipairs( files ) do
		local model = co.new( "lab3d.scene.Model" ).model
		model.filename = filename
		entity = co.new( "lab3d.dom.Entity" ).entity

		-- create a simple default name from filename
		entity.name = filename:match( "[%w_%.-_\\/]*[\\/]([%w@#-_+%.]*)$" )
		entity:addDecorator( model )
		assert( lab3d.activeProject ):addEntity( entity )
	end
	if entity then
		lab3d.selectedEntity = entity
	end
end

function L.on_action_OpenProject_triggered( sender )
	local files = qt.getOpenFileNames( sender, "Select Project File", "", L.projectFilterString  )
	if #files > 0 then
		lab3d.openProject( files[1] )
	end
end

function L.on_action_SaveProject_triggered( sender )
	local project = lab3d.activeProject
	local filePath = project.filePath
	if filePath == "" then
		filePath = qt.getSaveFileName( sender, "Save Project File", "", L.projectFilterString  )
		if not filePath or filePath == "" then return false end
		project.filePath = filePath
	end
	lab3d.saveProject()
	return true
end

function L.on_action_ExcludeSelected_triggered()
	local selectedEntity = lab3d.selectedEntity
	if selectedEntity then
		lab3d.selectedEntity = nil
		lab3d.activeProject:removeEntity( selectedEntity )
	end
end

-- MainWindow constructor
return function( windowTitle )
	local mainWindow = qt.loadUi( "lab3d:/ui/MainWindow.ui" )
	mainWindow.windowTitle = windowTitle

	-- connects slots of mainWindow to lua closures defined in local table L
	qt.connectSlotsByName( mainWindow, L )

	mainWindow.onClose = L.onCloseEvent

	L.createConfirmationMsgBox()

	return mainWindow
end
