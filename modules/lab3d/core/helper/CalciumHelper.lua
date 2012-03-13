local M = {}

function M.setupModel( self, caModelName )
	local modelObj = co.new "ca.Model" 
	local model = modelObj.model
	model.name = caModelName
	return model
end

-- Helper function. Returns a UndoRedoManager and its Space based on a provided Model
function M.setupCaSpace( self, model )
	-- creates the universe
	local universeObj = co.new "ca.Universe"
	local universe = universeObj.universe

	-- sets universe model
	universeObj.model = model
		
	-- sets the space
	local spaceObj = co.new "ca.Space"
	spaceObj.universe = universe
	
	return spaceObj.space
end

return M
