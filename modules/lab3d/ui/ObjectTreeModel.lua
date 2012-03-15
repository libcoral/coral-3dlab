local qt = require "qt"
local AbstractItemModel = require "qt.AbstractItemModel"
local ObjectTreeModel = AbstractItemModel( "sivapp.ui.ObjectTreeModel" )

-------------------------------------------------------------------------------
--- Tree model to show coral type hierarchy
-------------------------------------------------------------------------------
function ObjectTreeModel:getIndex( row, col, parentIndex )
	if not self.objectTreeData.instance then return -1 end
	local parentNode = self.objectTreeData.instance[parentIndex]
	if #parentNode.children == 0 then
		return -1
	end
	if #parentNode.children <= row then return -1 end
	return parentNode.children[row+1].index
end

function ObjectTreeModel:getParentIndex( index )
	if not self.objectTreeData.instance then return -1 end
	return self.objectTreeData.instance[index].parent
end

function ObjectTreeModel:getRow( index )
	if not self.objectTreeData.instance then return 0 end
	return self.objectTreeData.instance[index].row - 1
end

function ObjectTreeModel:getColumn( index )
	return 0
end

function ObjectTreeModel:getData( index, role )
	if not self.objectTreeData.instance then return nil end
	local data = nil
	if role == "DisplayRole" or role == "EditRole" then
		-- check whether this is the root namespace (empty name)
		data = self.objectTreeData.instance[index].name
	elseif role == "TextAlignmentRole" then
		data = qt.AlignLeft + qt.AlignJustify
	elseif role == "DecorationRole" then
		data = self.objectTreeData.instance[index].icon
	elseif role == "FontRole" then
		data = self.objectTreeData.instance[index].font
	elseif role == "ForegroundRole" then
		data = self.objectTreeData.instance[index].color
	end
	
	return data
end

function ObjectTreeModel:getFlags( index )
	if not self.objectTreeData.instance then return 0 end
	return qt.ItemIsSelectable + qt.ItemIsEnabled
end

function ObjectTreeModel:getHorizontalHeaderData( section, role )
	if not self.objectTreeData.instance then return nil end
	if section == 0 and role == "DisplayRole" then
		local projectName = self.objectTreeData.instance.rootName
		if not projectName or projectName == "" then
			projectName = "<Novo Projeto>"
		end
		return projectName
	end

	return nil
end

function ObjectTreeModel:getVerticalHeaderData( section, role )
	return nil -- no vertical header used
end

function ObjectTreeModel:getColumnCount( parentIndex )
	if not self.objectTreeData.instance then return 0 end
	-- every parent is at column 0
	-- root element has one column if objectTreeData.instance contains any data
	if not self.objectTreeData.instance:isValidIndex( parentIndex ) then
		return 1
	end

	if #self.objectTreeData.instance[parentIndex].children > 0 then
		return 1
	else
		return 0
	end
end

function ObjectTreeModel:getRowCount( parentIndex )
	if not self.objectTreeData.instance then return 0 end
	return #self.objectTreeData.instance[parentIndex].children
end

return ObjectTreeModel