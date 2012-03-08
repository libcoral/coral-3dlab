--[[---------------------------------------------------------------------------
	Application Component.
	Provides the main entry point for all application level services and
	instances sucha as IScene through IApplicationContext service.
--]]---------------------------------------------------------------------------

local qt = require "qt"
local glm = require "glm"
local Camera = require "lab3d.core.scene.Camera"

-- User Interface Modules
local MainWindow = require "lab3d.app.ui.MainWindow"
local GLCanvas = require "lab3d.app.ui.GLCanvasWidget"

-------------------------------------------------------------------------------
-- Component declaration
-------------------------------------------------------------------------------
local Application =  co.Component( "lab3d.app.Application" )

function Application:__init()
	-- empty
end

function Application:initialize()
	assert( not self.initialized, "application already initialized, it cannot be initialized twice" )

	local sceneObj = co.new "lab3d.core.scene.Scene"
	self.currentScene = sceneObj.scene
	
	local canvasWidget, graphicsContext = GLCanvas( sceneObj.painter )
	sceneObj.graphicsContext = graphicsContext
	
	-- setup camera
	local cameraObj = Camera()
	self.currentScene.camera = cameraObj.camera
	
	self.mainWindow = MainWindow( "Coral 3d Lab" )
	self.mainWindow:setCentralWidget( canvasWidget )
end

function Application:exec()
	self.mainWindow.visible = true
	qt.exec()
end

function Application:getContext()
	return self.object.context
end

function Application:blank()
	self.currentScene:clear()
end

function Application:getCurrentScene()
	return self.currentScene
end