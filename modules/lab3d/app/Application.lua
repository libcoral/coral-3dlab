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

--[[---------------------------------------------------------------------------
	Sets qt resource search path to the given module path. It allows any qt
	resource to be accessed relatively to the module path on disk, using the
	set alias.
	Ex: qt.setSearchPaths( "myAlias", "myModule.core" ) will expand "myAlias:/"
		to the path on disk of module "myModule.core".		
--]]---------------------------------------------------------------------------
qt.setSearchPaths( "lab3d", "lab3d.app" )

--[[---------------------------------------------------------------------------
	Local utility functions
--]]---------------------------------------------------------------------------
local function implementsFacet( type, facetType )
	local facets = type.facets
	if not facets then return false end
	for i, v in ipairs( facets ) do
		if v.type == facetType then
			return true, v.name
		end
	end
	return false
end

-- This lua closure search all components that provides "IManipulator" service
-- within manipulator module and loads it, adding it to the UI.
local function loadManipulators( appInstance, manipulatorModule )
	local ns = co.system.types.rootNS
    for w in string.gmatch( manipulatorModule, "%.?(%w+)%.?" ) do
		ns = ns:getChildNamespace( w )
	end
	
	local childTypes = ns.types
	
	local manipulatorManager = appInstance:getManipulatorManager()
	local imanipulatorType = co.Type[manipulatorModule .. ".IManipulator"]
	if childTypes then
		for i, v in ipairs( childTypes ) do
			local implementsFacet, facetName = implementsFacet( v, imanipulatorType )
			if implementsFacet then
				local manipulatorObj = co.new( v.fullName )
				-- the given type is a manipulator component
				manipulatorManager:addManipulator( manipulatorObj[facetName] )
			end
		end
	end
end

--[[---------------------------------------------------------------------------
	Component declaration
--]]---------------------------------------------------------------------------
local Application =  co.Component( "lab3d.app.Application" )

function Application:__init()
	-- empty
end

function Application:initialize()
	assert( not self.initialized, "application already initialized, it cannot be initialized twice" )

	local sceneObj = co.new "lab3d.core.scene.Scene"
	self.currentScene = sceneObj.scene
	
		-- create manipulator manager
	 local manipulatorManagerObj = co.new "lab3d.app.manipulator.ManipulatorManager"
	self.manipulatorManager = manipulatorManagerObj.manager
	
	-- set input listener facet of manipulator manager into canvas
	local canvasWidget, graphicsContext = GLCanvas( sceneObj.painter, manipulatorManagerObj.input )
	sceneObj.graphicsContext = graphicsContext
	
	-- setup camera
	local cameraObj = Camera()
	self.currentScene.camera = cameraObj.camera
	
	self.mainWindow = MainWindow( "Coral 3d Lab" )
	self.mainWindow:setCentralWidget( canvasWidget )
	
	-- export main window instance into a global access point
	qt.mainWindow = self.mainWindow
	
	loadManipulators( self, "lab3d.app.manipulator" )
end

function Application:exec()
	self.mainWindow.visible = true
	qt.exec()
end

function Application:getManipulatorManager()
	return self.manipulatorManager
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