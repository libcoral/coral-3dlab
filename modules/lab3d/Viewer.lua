--[[---------------------------------------------------------------------------
	Viewer application instance. This lua module builds and configures
	an aplication for 3d model visualization using coral3d lab core framework.
--]]---------------------------------------------------------------------------

local qt = require "qt"
local glm = require "glm"

-- User Interface Modules
local MainWindow = require "lab3d.ui.MainWindow"
local GLCanvas = require "lab3d.ui.GLCanvasWidget"

local Camera = require "lab3d.scene.Camera"
local SceneManager = require "lab3d.SceneManager"

local M = {}

--[[---------------------------------------------------------------------------
	Sets qt resource search path to the given module path. It allows any qt
	resource to be accessed relatively to the module path on disk, using the
	set alias.
	Ex: qt.setSearchPaths( "myAlias", "myModule.core" ) will expand "myAlias:/"
		to the path on disk of module "myModule.core".		
--]]---------------------------------------------------------------------------
qt.setSearchPaths( "lab3d", "lab3d" )

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
local function loadManipulators( self, manipulatorModule )
	local ns = co.system.types.rootNS
    for w in string.gmatch( manipulatorModule, "%.?(%w+)%.?" ) do
		ns = ns:getChildNamespace( w )
	end
	
	local childTypes = ns.types
	
	local manipulatorManager = self.manipulatorManager
	local imanipulatorType = co.Type[manipulatorModule .. ".IManipulator"]
	if childTypes then
		for i, v in ipairs( childTypes ) do
			local implementsFacet, facetName = implementsFacet( v, imanipulatorType )
			if implementsFacet then
				local manipulatorObj = co.new( v.fullName )
				local manipulator = manipulatorObj[facetName]
				-- the given type is a manipulator component
				manipulatorManager:addManipulator( manipulator )
			end
		end
	end
end

function M:initialize()
	local sceneObj = co.new "lab3d.scene.Scene"
	self.currentScene = sceneObj.scene
	
	-- setup camera
	local cameraObj = Camera()
	self.currentScene.camera = cameraObj.camera
	
	SceneManager:initialize( self.currentScene )
	
	-- create manipulator manager
	local manipulatorManagerObj = co.new "lab3d.manipulator.ManipulatorManager"
	self.manipulatorManager =  manipulatorManagerObj.manager
	
	-- set input listener facet of manipulator manager into canvas
	local canvasWidget, graphicsContext = GLCanvas( sceneObj.painter, manipulatorManagerObj.input )
	sceneObj.graphicsContext = graphicsContext
	
	self.mainWindow = MainWindow( "Coral 3d Lab" )
	self.mainWindow:setCentralWidget( canvasWidget )
	
	-- export main window instance into a global access point
	qt.mainWindow = self.mainWindow
	
	loadManipulators( self, "lab3d.manipulator" )

	co.system.services:getService( co.Type["lab3d.IApplication"] ):newBlankProject()
end

function M:exec()
	self.mainWindow.visible = true
	return qt.exec()
end

return function()
	-- creates a new table with metatable set to M (creates a new Viewer instance)
	return setmetatable( {}, { __index = M } )
end

