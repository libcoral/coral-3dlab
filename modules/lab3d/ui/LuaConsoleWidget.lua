local qt = require "qt"
local eigen = require "eigen"
local ConsoleControl = require "lab3d.ui.LuaConsoleControl"
local ProjectObserver = require "lab3d.helper.ProjectObserver"

local L = {}

function L.executeCommandAndShowResult( command )
	local success, msg = ConsoleControl.executeNew( command )
	L.console.consoleOutput:invoke( "append(QString)", msg )
end

function L.on_consoleInput_keyPressEvent( source, key, modifiers )
	if key == "Key_Period" or key == 'Key_Colon' then
		local request = ( key == "Key_Period" and "fields" or "methods" )
		local info = ConsoleControl.getMemberInfo( L.console.consoleInput.text, request )
		if info then
			L.console.consoleOutput:invoke( "append(QString)", info )
		end
	elseif key == "Key_Up" then
		L.console.consoleInput.text = ConsoleControl.previousCmd() or L.console.consoleInput.text
	elseif key == "Key_Down" then
		L.console.consoleInput.text = ConsoleControl.nextCmd() or L.console.consoleInput.text
	elseif key == "Key_Return" then
		local command = L.console.consoleInput.text
		L.executeCommandAndShowResult( command )
		L.console.consoleInput:invoke( "clear()" )
	end
end

--[[---------------------------------------------------------------------------

--]]---------------------------------------------------------------------------
function L:onProjectOpened( newProject )
	local env = { project = newProject, eigen = eigen }
	L.env = env
	ConsoleControl.setConsoleEnv( env )
end

function L:onProjectClosed( project )
	ConsoleControl.setConsoleEnv( nil )
end

function L:onEntitySelectionChanged( project, previous, current )
	L.env.selectedEntity = current
end

return function()
	if not L.dockConsoleWidget then
		L.console = qt.loadUi "lab3d:/ui/LuaConsole.ui"
		L.console.consoleInput.onKeyPress = L.on_consoleInput_keyPressEvent

		-- setup DockWidget
		L.dockConsoleWidget = qt.new( "QDockWidget" )
		L.dockConsoleWidget.windowTitle = "Lua Console"
		L.dockConsoleWidget:setWidget( L.console )

		ProjectObserver:addObserver( L )
	end

	return L.dockConsoleWidget
end
