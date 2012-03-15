--[[---------------------------------------------------------------------------
	Lua utility module for registering lua closures as update callbacks.
	Lua modules can then implement a closure 'timeUpdate(dt)' in a similar 
	fashion to lab3d.dom.IUpdateCallback service.The time update callback
	is called in a frequency close to 60Hz and parameter 'dt' is the elapsed 
	user time between two consecutive update calls.
	
	E.x:
		local UpdateNotifier = require "lab3d.helper.UpdateNotifier"
		
		local M = {}
		M.timeUpdate = function( dt )
			-- perform time based calculations
		end
		
		UpdateNotifier:addObserver( M )
--]]---------------------------------------------------------------------------
local UpdateNotifier =  co.Component( "lab3d.helper.UpdateNotifier" )

function UpdateNotifier:__init()	
	self.updateManager = co.new( "lab3d.dom.UpdateManager" ).updateManager
	self.updateManager:addObserver( self.object.update )
	self.observers = self.observers or {}
end

function UpdateNotifier:timeUpdate( dt )
	for k, v in pairs( self.observers ) do
		if type( v.timeUpdate ) == "function" then
			v:timeUpdate( dt )
		end
	end
end

local M = { observers = {} }

M.instance = UpdateNotifier( M )

function M:addObserver( observer )
	self.observers[observer] = observer
end

function M:removeObserver( observer )
	self.observers[observer] = nil
end
	
return M
