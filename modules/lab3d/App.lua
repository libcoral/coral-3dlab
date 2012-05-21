--------------------------------------------------------------------------------
-- Launcher Component (launches the application UI)
--------------------------------------------------------------------------------

local App = co.Component( "lab3d.App" )

function App:main( args )
	-- initialize the domain layer
	local lab3d = require "lab3d"
	lab3d.newProject()

	-- initialize the scene layer
	local scene = require "lab3d.scene"

	-- initialize the UI layer
	local ui = require "lab3d.ui"
	scene.setGLContext( ui.init( scene.getPainter() ) )

	local function loopCallback( dt )
		lab3d.step()
	end

	return ui.run( loopCallback )
end
