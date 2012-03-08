local glm = require "glm"

-- public module functions
local M = {}

-- identity axis
local identityUp = glm.Vec3( 0, 1, 0 )
local identityRight = glm.Vec3( 1, 0, 0 )
local identityDirection = glm.Vec3( 0, 0, -1 )

-- local module functions
local locals = {}

-- calculates a new pose (position and orientation) using the given distance offset from that point. 
-- The new orientation transforms a vector from identity view forward direction (0,0,-1) to a vector 
-- pointing to the given destination point, always keeping up vector aligned with world up direction.
function locals.calculatePose( self, position, distanceOffset )
	local translationVector = position - self.position
	local distance = glm.length( translationVector )
	glm.normalize( translationVector, translationVector )
	glm.mulVecScalar( translationVector, distance - distanceOffset, translationVector )

	local finalOrientation = glm.fromMat4( glm.lookAt( self.position, position, glm.Vec3( 0, 0, 1 ) ) )
	
	local pose = co.new "lab3d.core.domain.Pose"
	pose.position = ( self.position + translationVector )
	pose.orientation = finalOrientation
	return pose
end

-------------------------------------------------------------------------------
-- Component declaration
-------------------------------------------------------------------------------
local View =  co.Component( "lab3d.core.domain.View" )


function View:__init()
	local rot_90_over_x = glm.rotateQuat( glm.Quat(), -90.0, glm.Vec3( 1, 0, 0 ) )
	self.orientation = self.orientation or rot_90_over_x
	self.position = self.position or glm.Vec3()
end

function View:calculateNavigationToPoint( point )
	local distanceToObject = glm.length( point - self.position )
	return locals.calculatePose( self, point, distanceToObject * 0.666 )
end

function View:calculateNavigationToObject( object )
	local objBounds = object.bounds
	local center = objBounds.center
	local boundRadius = glm.length( center - objBounds.max ) 
	return locals.calculatePose( self, center, boundRadius )
end

function View:getPose()
	local pose = co.new "lab3d.core.domain.Pose"
	pose.position = self.position
	pose.orientation = self.orientation
	return pose
end

function View:setPose( pose )
	self.position = pose.position
	self.orientation = pose.orientation
end

function View:setPosition( position )
	self.position = position
end

function View:getPosition()
	return self.position
end

function View:setOrientation( orientation )
	self.orientation = orientation
end

function View:getOrientation()
	return self.orientation
end

function View:getZeroRollOrientation()
	local m = glm.Mat4()
	glm.lookAt( self.position, self.position + self:getDirection(), glm.Vec3( 0, 0, 1 ), m )
	
	local zeroRollQuat = glm.Quat()
	glm.fromMat4( m, zeroRollQuat )
	
	return zeroRollQuat
end

function View:getUp()
	return identityUp * self.orientation
end

function View:getRight()
	return identityRight * self.orientation 
end

function View:getDirection()
	return identityDirection * self.orientation 
end

return View
