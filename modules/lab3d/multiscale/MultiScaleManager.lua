local qt = require "qt"
local UpdateNotifier = require "lab3d.helper.UpdateNotifier"

local M = {}

local MINIMUM_NEAR_DIST = 0.1
local MAXIMUM_NEAR_DIST = 100000000.0
local MAXIMUM_FAR_NEAR_RATIO = 100000.0

local function clamp( x, min, max )
	if x > max then return max end
	if x < min then return min end
	return x
end

function M:update( camera )
    -- recalculates minimum distance from all objects to the camera
    local currentFar = camera.zFar
    local currentNear = camera.zNear
    local pos = camera.view.position
    self.distanceQuery:update( pos.x, pos.y, pos.z, currentNear, currentFar )

    local minDistance = self.distanceQuery:getMinDistance()
    if minDistance == -1 then
        return
    end
    
    local scaledMinDistance = -1
    if minDistance < 1 and minDistance >= 0.0 then
        scaledMinDistance = ( minDistance * ( currentFar - currentNear ) + currentNear ) ;
    end
    
    -- implementation based on 'Mulstiscale 3D Navigation' article
    local a = 2.0
    local alpha = 0.75
    local b = 10.0
    local beta = 1.5
    
    -- the main idea is to expand of reduce the near distance using a mobile exponencial
    -- (an exponencial with weights)
    if scaledMinDistance < a * currentNear then
        currentNear = alpha * currentNear;
    end
    if scaledMinDistance > b * currentNear then
        currentNear = beta * currentNear;
    end
    
    currentNear = clamp( currentNear, MINIMUM_NEAR_DIST, MAXIMUM_NEAR_DIST );
    
    -- Set the new calculated near value to camera
    camera.zNear = currentNear
    camera.zFar = currentNear * MAXIMUM_FAR_NEAR_RATIO;
end

function M:initialize( drawerService, sceneService )
	-- checks out whether the required module exists
	if not co.system.modules:isLoadable( "minDistanceQuery" ) then
		return false
	end
	
	self.enabled = true
	
	UpdateNotifier:addObserver( self )
	
	self.scene = sceneService
	-- turn off OpenSceneGraph auto near far computation if multiscale is enabled
	self.scene.autoAdjustNear = not self.enabled
		
	self.glMinDistanceQueryObj = co.new "minDistanceQuery.GLMinDistanceQuery"
	self.glMinDistanceQueryObj.drawer = drawerService
	self.distanceQuery = self.glMinDistanceQueryObj.distanceQuery
	
	-- integrate with UI
	local action = qt.new( "QAction" )
	action.text = "Enable/Disable Auto Near and Far Adjustment"
	action.icon = qt.Icon( "lab3d:/ui/resources/frustum.png" )
	action.checkable = true
	action.checked = self.enabled
	qt.mainWindow.toolBar:addAction( action )
	
	local slot = function( sender, value ) self:setEnabled( value ) end
	action:connect( "toggled(bool)", slot )
	
	return true
end

function M:setEnabled( value )
	self.scene.autoAdjustNear = not value
	self.enabled = value
end

function M:timeUpdate( dt )
	if not self.enabled then return end
	self:update( self.scene.camera )
end

return M


