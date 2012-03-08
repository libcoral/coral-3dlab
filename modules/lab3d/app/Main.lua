--[[---------------------------------------------------------------------------
	Base dependencies and required modules
--]]---------------------------------------------------------------------------
local qt = require "qt"

-- Initializes and registers global application services into coral system
require "lab3d.app.StartupServices"

-- Initializes application context
local application = co.system.services:getService( co.Type["lab3d.app.IApplication"] )
application:initialize()
application:exec()