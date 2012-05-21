--------------------------------------------------------------------------------
-- Module 'lab3d.ui' (provides a Qt-based GUI)
--------------------------------------------------------------------------------

local qt = require "qt"
local Timer = require "qt.Timer"

local lfs = require "lfs"
local lab3d = require "lab3d"

-- allows resources in the lab3d module to be addressed like "lab3d:/x" in Qt
qt.setSearchPaths( "lab3d", "lab3d" )

--------------------------------------------------------------------------------
-- Canvas Input Listener
--------------------------------------------------------------------------------

local canvasInputHandler = nil

local CanvasInputListener = co.Component{
	name = "lab3d.ui.CanvasInputListener",
	provides = { listener = "qt.IInputListener" },
}

local function addDelegatedMethod( Component, methodName )
	Component[methodName] = function( self, ... )
		local h = canvasInputHandler
		if h then h[methodName]( ... ) end
	end
end

addDelegatedMethod( CanvasInputListener, "mousePressed" )
addDelegatedMethod( CanvasInputListener, "mouseMoved" )
addDelegatedMethod( CanvasInputListener, "mouseReleased" )
addDelegatedMethod( CanvasInputListener, "mouseDoubleClicked" )
addDelegatedMethod( CanvasInputListener, "keyPressed" )
addDelegatedMethod( CanvasInputListener, "keyReleased" )
addDelegatedMethod( CanvasInputListener, "mouseWheel" )

--------------------------------------------------------------------------------
-- Helper Functions
--------------------------------------------------------------------------------

local function createGLCanvas( painter, inputListener )
	-- create a gl canvas for displaying the graphics
	glWidgetObject = co.new "qt.GLWidget"
	glWidgetObject.painter = assert( painter )
	glWidgetObject.inputListener = assert( inputListener )

	local glContext = glWidgetObject.glContext
	glContext:setFormat(
		qt.FormatOption.DoubleBuffer +
		qt.FormatOption.DepthBuffer +
		qt.FormatOption.Rgba +
		qt.FormatOption.AlphaChannel )

	-- strong focus is necessary to capture keyboard events
	local glWidget = qt.wrap( glContext.widget )
	glWidget.objectName = "canvas"
	glWidget.focusPolicy = qt.StrongFocus

	return glWidget, glContext
end

local function createMainWindow( centralWidget )
	local MainWindow = require "lab3d.ui.MainWindow"
	local mainWindow = MainWindow( "Coral 3D Lab" )
	mainWindow:setCentralWidget( centralWidget )

	-- Project Tree (left dock widget)
	local ObjectTreeWidget = require "lab3d.ui.ObjectTreeWidget"
	local dockTreeWidget = ObjectTreeWidget( mainWindow  )
	mainWindow:addDockWidget( qt.LeftDockWidgetArea, dockTreeWidget )

	-- Lua Console (bottom dock widget)
	local LuaConsoleWidget = require "lab3d.ui.LuaConsoleWidget"
	local luaConsoleWidget = LuaConsoleWidget()
	luaConsoleWidget.visible = false
	mainWindow:addDockWidget( qt.BottomDockWidgetArea, luaConsoleWidget )

	return mainWindow
end

local extensions = {}

local function installExtensions()
	local extensionsDir = assert( co.findFile( 'lab3d.ui', '__init.lua' ) )
	extensionsDir = extensionsDir:gsub( "__init.lua", "extensions" )
	for filename in lfs.dir( extensionsDir ) do
		local scriptName = filename:match( "^(.+)%.lua$" )
		if scriptName then
			local extension = require( "lab3d.ui.extensions." .. scriptName )
			extension.install()
			extensions[#extensions + 1] = extension
		end
	end
end

--------------------------------------------------------------------------------
-- Module Functions
--------------------------------------------------------------------------------

local M = {}

-- Sets which object receives input events for our QGLWidget.
function M.setCanvasInputHandler( handler )
	if canvasInputHandler then
		canvasInputHandler.deactivate()
	end
	canvasInputHandler = handler
	if handler then
		handler.activate()
	end
end

-- Adds a QAction to a named toolbar in the main window.
function M.addToToolbar( toolbarName, action )
	M.mainWindow[toolbarName .. "Toolbar"]:addAction( action )
end

-- Initializes the GUI. Receives an OpenGL painter and returns an OpenGL context.
function M.init( painter )
	assert( M.mainWindow == nil, "lab3d.ui.init() called twice?" )

	local inputListener = CanvasInputListener().listener
	local glWidget, glContext = createGLCanvas( painter, inputListener )

	M.mainWindow = createMainWindow( glWidget )
	installExtensions()

	return glContext
end

-- Runs the main loop until the application exits. Receives a closure to call at 60Hz.
function M.run( loopCallback )
	assert( M.mainWindow ~= nil, "lab3d.ui.init() not called?" )

	local idleTimer = Timer( loopCallback )
	idleTimer:start( 1000 / 60 )

	M.mainWindow.visible = true
	return qt.exec()
end

return M
