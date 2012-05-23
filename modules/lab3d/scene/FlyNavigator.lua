-------------------------------------------------------------------------------
-- FlyNavigator
-------------------------------------------------------------------------------

local eigen = require "eigen"
local Vec3 = eigen.Vec3

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
	eigen.mulVecScalar( worldTranslation, dt * self.translationVelocity, tempDeltaVector )
	self.view.position = self.view.position + tempDeltaVector
end

-- accumulates the angular variation over the given axis into given quaternion orientation 'currentOrientation'
function locals.accumulateOrientation( currentOrientation, angularVariation, axis )
	return eigen.rotateQuat( currentOrientation, -math.deg( angularVariation ), axis, currentOrientation )
end

function locals.calculateNewOrientation( self, dt )
	-- access real world up direction
	local worldUp = WORLD_UP_DIRECTION

	-- update orientation
	local originalOrientation = self.view.orientation
	local cameraUp = WORLD_UP_DIRECTION * originalOrientation
	local cameraRight = Vec3( 1, 0, 0 )

	-- performs X axis calculation if theres a significant angle over X axis
	if math.abs( self.angleOverXDir ) > ANGULAR_TOLERANCE then
		local angularDx = self.angleOverXDir * dt * ANGULAR_VELOCITY_OVER_X_AXIS

		-- changes camera orientation
		self.view.orientation = locals.accumulateOrientation( self.view.orientation, angularDx, cameraRight )

		-- stops movement with a little inertia (if ANGULAR_SENSITIVITY is non zero)
		self.angleOverXDir = self.angleOverXDir * ( 1 - self.inertialFactor ) * dt

		-- checks whether camera vertical angle has reached maximum angle
		-- (we don't want camera loops along x axis)

		-- measures total angle between camera up and world up
		local currentAngle = math.acos( eigen.dotVec( cameraUp, worldUp ) )
		if 2 * math.abs( currentAngle ) > math.pi then
			-- angle would exceed maximum vertical angle,
			-- so we restore original camera orientation
			self.view.orientation = originalOrientation
		end
	else
		self.angleOverXDir = 0
	end

	-- performs UP axis rotation if theres a significant angle over UP axis
	if math.abs( self.angleOverYDir ) > ANGULAR_TOLERANCE then
		local angularDy = self.angleOverYDir * dt * ANGULAR_VELOCITY_OVER_Y_AXIS

		-- changes camera orientation
		self.view.orientation = locals.accumulateOrientation( self.view.orientation, angularDy, worldUp )

		-- stops movement with a little inertia (if ANGULAR_SENSITIVITY is non zero)
		self.angleOverYDir = self.angleOverYDir * ( 1 - self.inertialFactor ) * dt
	else
		self.angleOverYDir = 0
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
