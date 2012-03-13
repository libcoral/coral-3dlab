--[[---------------------------------------------------------------------------
	Base dependencies and required modules
--]]---------------------------------------------------------------------------
local qt = require "qt"
local Viewer = require "lab3d.Viewer"

-- Initializes and registers global application services into coral system
require "lab3d.StartupServices"

-- Initializes viewer app
local viewer = Viewer()
viewer:initialize()
viewer:exec()