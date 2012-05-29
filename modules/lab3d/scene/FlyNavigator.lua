-------------------------------------------------------------------------------
-- FlyNavigator
-------------------------------------------------------------------------------

local eigen = require "eigen"
local Vec3 = eigen.Vec3
local Quat = eigen.Quat

local CAMERA_X_AXIS = eigen.Vec3( 1, 0, 0 )
local WORLD_UP_DIRECTION = eigen.Vec3( 0, 1, 0 )
local ANGULAR_VELOCITY_OVER_X_AXIS 	= 6 * math.pi -- rad/s
local ANGULAR_VELOCITY_OVER_Y_AXIS 	= 6 * math.pi -- rad/s
local ANGULAR_TOLERANCE				= 1e-3

-------------------------------------------------------------------------------
-- Local Module Functions
-------------------------------------------------------------------------------

local locals = {}

function locals.getWorldTranslationVector( self )
	return self.view.orientation * self.translationVector
end

local tempDeltaVector = Vec3()
function locals.calculateNewPosition( self, dt )
	if eigen.length( self.translationVector ) == 0 then
		return
	end

	local worldTranslation = locals.getWorldTranslationVector( self )
	eigen.mulVecScalar( worldTranslation, self.translationVelocity * dt, tempDeltaVector )
	self.view.position = self.view.position + tempDeltaVector
end

function locals.calculateNewOrientation( self, dt )
	local currentOrientation = self.view.orientation
    local up = eigen.conjugate( self.view.orientation ) * WORLD_UP_DIRECTION
    if ( math.abs( self.angleOverYDir ) > ANGULAR_TOLERANCE ) 
		or ( math.abs( self.angleOverXDir ) > ANGULAR_TOLERANCE ) then
		
		local currentDy = self.angleOverYDir * ANGULAR_VELOCITY_OVER_Y_AXIS
		local yawRotation = eigen.setIdentityQuat( self.auxQuaternion )
		yawRotation = eigen.rotateQuat( yawRotation, currentDy, up )

		local currentDx = self.angleOverXDir * ANGULAR_VELOCITY_OVER_X_AXIS
		local auxPitch = self.pitchAcumulator + currentDx
        local pitchRotation = eigen.Quat()
		if auxPitch <= 90.0 and auxPitch >= -90.0 then
			pitchRotation = eigen.rotateQuat( pitchRotation, currentDx, CAMERA_X_AXIS );
			self.pitchAcumulator = auxPitch
		end
		self.angleOverXDir = self.angleOverXDir * ( 1 - self.inertialFactor ) * dt
		self.angleOverYDir = self.angleOverYDir * ( 1 - self.inertialFactor ) * dt
		
		self.view.orientation = currentOrientation * yawRotation * pitchRotation
    end
end

--[[---------------------------------------------------------------------------
	Component declaration/definition
--]]---------------------------------------------------------------------------

local FlyNavigator =  co.Component( "lab3d.scene.FlyNavigator" )

function FlyNavigator:__init()
	self.inertialFactor = self.inertialFactor or 0.3
	self.translationVector = eigen.Vec3( 0, 0, 0 )
	self.angleOverXDir = 0
	self.angleOverYDir = 0
	self.pitchAcumulator = 0
	self.auxQuaternion = Quat()
	self.translationVelocity = 10
end

function FlyNavigator:addPitchOffset( radians )
	self.angleOverYDir = self.angleOverYDir + radians
end

function FlyNavigator:addYawOffset( radians )
	self.angleOverXDir = self.angleOverXDir + radians
end

function FlyNavigator:setTranslationVector( vector )
	self.translationVector = vector
end

function FlyNavigator:setTranslationVelocity( velocity )
	self.translationVelocity = velocity
end

function FlyNavigator:getTranslationVelocity()
	return self.translationVelocity
end

function FlyNavigator:evolve( dt )
	-- update position
	locals.calculateNewPosition( self, dt )

	-- update orientation
	locals.calculateNewOrientation( self, dt )
end

function FlyNavigator:getIntertialFactor()
	return self.intertialFactor
end

function FlyNavigator:setIntertialFactor( factor )
	self.inertialFactor = factor
end

function FlyNavigator:setView( view )
	self.view = view
end

function FlyNavigator:getView()
	return self.view
end

return FlyNavigator
