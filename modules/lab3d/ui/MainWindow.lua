--[[---------------------------------------------------------------------------
	Lua module of application's MainWindow interface. It returns a constructor
	lua closure that will create and setup MainWindow widget using qt system.
--]]---------------------------------------------------------------------------

local qt = require "qt"
local eigen = require "eigen"

-- local variables table
local L = {}

L.fileFilterString = "OpenSceneGraph File (*.ive);;"
L.projectFilterString = "Lua Project File (*.lua);;"

function L.save( project, filename )
	L.application:saveProject( project, filename )
	return true
end

function L.confirmationBox_finished( sender, returnedCode )
	L.confirmationDlgReturnCode = returnedCode
end

function L.createConfirmationMsgBox()
	L.confirmationDlg = qt.new( "QMessageBox" )
	L.confirmationDlg.icon = qt.MessageBox.Information
	L.confirmationDlg.standardButtons = qt.MessageBox.Yes + qt.MessageBox.No + qt.MessageBox.Cancel
	L.confirmationDlg:connect( "finished(int)", L.confirmationBox_finished )
end

function L.onCloseEvent( sender )
	return L.askForSaveCurrentProject( sender )
end

function L.askForSaveCurrentProject( sender )
	local currentProject = L.application.currentProject
	local projectDirty = L.application:projectHasChanges( currentProject )
	if projectDirty then
		L.confirmationDlg.text = "The project contains unsaved changes. Save before closing?"
		L.confirmationDlg:invoke( "exec()" )
		if L.confirmationDlgReturnCode == qt.MessageBox.Cancel then
			return false
		end
		if L.confirmationDlgReturnCode == qt.MessageBox.Yes then
			return L.on_action_SaveProject_triggered( sender )
		end
	end

	return true
end

function L.on_action_AddModel_triggered( sender )
	local files = qt.getOpenFileNames( sender, "Select Data File", "", L.fileFilterString  )

	-- check whether the user has cancelled file open dialog
	if #files == 0 then return end

	for i = 1, #files do
		local model = co.new( "lab3d.scene.Model" ).model
		model.filename = files[i]
		local entity = co.new( "lab3d.dom.Entity" ).entity

		-- create a simple default name from file
		local nameFromFile = string.match( model.filename, "[%w_%.-_\\/]*[\\/]([%w@#-_+%.]*)$" )
		entity.name = nameFromFile .. "_" .. (#L.application.currentProject.entities + 1)
		entity:addDecorator( model )
		L.application.currentProject:addEntity( entity )
	end
end

function L.on_action_OpenProject_triggered( sender )
	local files = qt.getOpenFileNames( sender, "Select Project File", "", L.projectFilterString  )

	-- check whether the user has cancelled file open dialog
	if #files == 0 then return end

	local projectFile = files[1]

	L.application:openProject( projectFile )
end

function L.on_action_SaveProject_triggered( sender )
	local project = L.application.currentProject
	local projectFile = L.application:getProjectFilename( project )
	if projectFile == "" then
		local file = qt.getSaveFileName( sender, "Save Project File", "", L.projectFilterString  )
		if not file or file == "" then return false end

		projectFile = file
	end

	L.save( project, projectFile )
	return true
end

function L.on_actionExcludeSelected_triggered()
	local selectedEntity = L.application.currentProject.selectedEntity
	if not selectedEntity then return end

	L.application.currentProject:removeEntity( selectedEntity )
	L.application.currentProject:setEntitySelected( nil )
end

-- MainWindow constructor
return function( windowTitle )
	local mainWindow = qt.loadUi "lab3d:/ui/MainWindow.ui"
	mainWindow.windowTitle = windowTitle

	-- connects slots of mainWindow to lua closures defined in local table L
	qt.connectSlotsByName( mainWindow, L )

	mainWindow.onClose = L.onCloseEvent

	L.application = co.system.services:getService( co.Type["lab3d.IApplication"] )

	L.createConfirmationMsgBox()

	return mainWindow
end
