local glm = require "glm"

-------------------------------------------------------------------------------
-- Local module functions
-------------------------------------------------------------------------------
-- local functions table
local locals = {}

locals.MINIMUM_DISTANCE_TO_CENTER = 0.1

function locals.calculatePointOnSphere( x, y, result )
    glm.setXYZ( result, x, y, 0 )

    local m = x * x + y * y
    if m < 1.0 then
        -- point (x, y) is above the unit sphere.
        result.z = math.sqrt( 1.0 - m );
    else
        -- if the point does not lie on the sphere, push it back to the sphere border.
        m = math.sqrt( m );
		glm.mulVecScalar( result, 1.0 / m, result )
    end
end

-------------------------------------------------------------------------------
-- Component declaration
-------------------------------------------------------------------------------
local ExamineNavigator =  co.Component( "lab3d.core.domain.ExamineNavigator" )


function ExamineNavigator:__init()
	self.startVector 	= glm.Vec3( 0, 0, 0 )
	self.rotationCenter	= glm.Vec3( 0, 0, 0 )
	self.endVector 		= glm.Vec3( 0, 0, 0 )
	self.auxVector 		= glm.Vec3( 0, 0, 0 )
	self.start 			= glm.Quat()
	self.auxQuaternion 	= glm.Quat()
end

function ExamineNavigator:setView( view )
	self.view = view
end

function ExamineNavigator:getView()
	return self.view
end

function ExamineNavigator:beginRotation( nx, ny )
	self.originalPose = self.view:getPose()
	self.start = self.view.orientation
	
	-- uses polar coordinates to calculate initial vector
	locals.calculatePointOnSphere( nx, ny, self.startVector )
end

function ExamineNavigator:updateRotation( nx, ny )
	-- uses polar coordinates to update rotation vector
	locals.calculatePointOnSphere( nx, ny, self.endVector )

	glm.rotationFromToQuat( self.startVector, self.endVector, self.auxQuaternion )

	self.auxQuaternion = self.auxQuaternion * self.start
	self.view.orientation = self.auxQuaternion

	local distanceToCenter = self:getDistanceToCenter()
	local viewRotation = glm.conjugate( self.auxQuaternion )
	glm.setXYZ( self.auxVector, 0, 0, distanceToCenter )

	local rotatedViewPos = viewRotation * self.auxVector
	glm.addVec( rotatedViewPos, self.rotationCenter, rotatedViewPos )
	self.view.position = rotatedViewPos
end

function ExamineNavigator:endRotation()
	-- empty
	self.originalPose = nil
end

function ExamineNavigator:abortRotation()
	if not self.originalPose then return end
	self.view:setPose( self.originalPose )
end

function ExamineNavigator:getDistanceToCenter()
	return glm.length( glm.subVec( self.view.position, self.rotationCenter, self.auxVector ) )
end

function ExamineNavigator:zoom( factor )
	local approachFactor = math.max( 0, 1 + factor )
	
	local translation = ( self.rotationCenter - self.view.position )
	local translationDirection = glm.normalize( translation )
	
	local currentDistance = self:getDistanceToCenter()
	local newDistance = math.max( locals.MINIMUM_DISTANCE_TO_CENTER, currentDistance * approachFactor )
	self.view.position = self.rotationCenter - translationDirection * newDistance
end

function ExamineNavigator:setRotationCenter( rotationCenter )
	self.rotationCenter = rotationCenter
end

function ExamineNavigator:getRotationCenter()
	return self.rotationCenter
end

function ExamineNavigator:evolve( dt )
	-- empty
end

return ExamineNavigator
