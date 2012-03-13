--[[---------------------------------------------------------------------------
	Camera module.
	Provides lab3d.scene.ICamera interface service.
--]]---------------------------------------------------------------------------

local glm = require "glm"
local View = require "lab3d.dom.View"

-------------------------------------------------------------------------------
-- Component declaration
-------------------------------------------------------------------------------
local Camera =  co.Component( "lab3d.scene.Camera" )


function Camera:__init()
	self.znear = self.znear or 100
	self.zfar = self.zfar or 10000
	self.fovy = self.fovy or 60
	self.aspect = self.aspect or 1
	self.viewportWidth = self.viewportW or 800
	self.viewportHeight = self.viewportH or 600
	local viewObj = View{ position = glm.Vec3( 0, -100, 0 ) }
	self.view = viewObj.view; -- default camera view
end

function Camera:setView( view )
	self.view = view
end

function Camera:getView()
	return self.view
end

function Camera:getFovy()
	return self.fovy
end

function Camera:setFovy( fovy )
	self.fovy = fovy
end

function Camera:getAspect()
	return self.aspect
end

function Camera:setAspect( aspect )
	self.aspect = aspect
end

function Camera:getZNear()
	return self.znear
end

function Camera:setZNear( znear )
	self.znear = znear
end

function Camera:getZFar()
	return self.zfar
end

function Camera:setZFar( zfar )
	self.zfar = zfar
end

function Camera:getViewportWidth()
	return self.viewportWidth
end

function Camera:setViewportWidth( width )
	self.viewportWidth = width
end

function Camera:setViewportHeight( height )
	self.viewportHeight = height
end

function Camera:getViewportHeight( height )
	return self.viewportHeight
end

return Camera

