--[[---------------------------------------------------------------------------
	Actor component. An Actor provides IActor service, which is a glue
	between coLab graphical systeam and OpenSceneGraph api.
--]]---------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Component declaration
-------------------------------------------------------------------------------
local Actor =  co.Component( "lab3d.core.scene.Actor" )

-- Actor constructor
function Actor:__init()
	-- empty
end

function Actor:setEntityService( entity )
	self.entity = entity
end

function Actor:getEntityService( entity )
	return self.entity
end

function Actor:getNode()
	-- loads the model osg node, if not already loaded
	if self.node then
		return self.node
	end
	
	local modelLoader = co.system.services:getService( co.Type["lab3d.core.scene.IModelLoader"] )
	local modelNode = modelLoader:load( self.entity.filename )
	self.node = modelNode
	return self.node
end