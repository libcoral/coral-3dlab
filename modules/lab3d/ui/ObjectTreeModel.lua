local qt = require "qt"
local ca = require "ca"
local lab3d = require "lab3d"
local AbstractItemModel = require "qt.AbstractItemModelDelegate"

local ObjectTreeModel = AbstractItemModel( "sivapp.ui.ObjectTreeModel" )

-- icon files
local icons = 
{
	group 			= qt.Icon( "coral:/ui/res/tree_roup.png" ),
	element 		= qt.Icon( "coral:/ui/res/tree_element.png" )
}

-- current object tree instance
local treeData = nil
local qtModel = nil
local qtSelectionModel = nil
-------------------------------------------------------------------------------
-- Simple Object Tree Data Structure
-------------------------------------------------------------------------------
local ObjectTree = {}

-- Add an element
function ObjectTree:add( element, parentIndex )
	-- creates a node data
	local node = 
	{ 
		data = element,
		index = self.nextIndex,
		parent = parentIndex,
		children = {} 
	}
	self[node.index] = node
	self.nextIndex = self.nextIndex + 1

	-- allow reverse data -> index mapping
	self.index[element] = node.index
	
	table.insert( self[parentIndex].children, node )

	-- tracks elements row within parent list
	node.row = #self[parentIndex].children

	return node.index
end

function ObjectTree:remove( elementIndex )
	local node = self[elementIndex]
	local parentIndex = node.parent
	local childrenList = self[parentIndex].children
	table.remove( childrenList, node.row )
	-- update remaining node rows
	for i=node.row, #childrenList do
		childrenList[i].row = childrenList[i].row - 1
	end
end

function ObjectTree:getDataIndex( data )
	return self.index[data]
end

function ObjectTree:isValidIndex( index )
	return index >= 0
end

function ObjectTree:clear()
	self.rootIndex = -1
	self[self.rootIndex] = { children = {} }
	self.index = {}
	self.nextIndex = 1
end

function ObjectTree:new()
	ObjectTree.__index = ObjectTree
	local self = setmetatable( {}, ObjectTree )

	self:clear()

	return self
end

local function isEntitySelected( entity )
	return entity == lab3d.activeProject.selectedEntity
end

local function rebuildTree( entitiesList )
	treeData:clear()
	qtModel:reset()
	if #entitiesList == 0 then return end
	
	local rootIndex = treeData.rootIndex
	qtModel:beginInsertRows( rootIndex, 0, #entitiesList - 1 )
	for i, v in ipairs( entitiesList ) do
		local newIndex = treeData:add( v, rootIndex )
		qtSelectionModel:setItemSelection( newIndex, isEntitySelected( v ) )
	end
	qtModel:endInsertRows()	
end

-------------------------------------------------------------------------------
--- Tree model to show coral type hierarchy
-------------------------------------------------------------------------------
function ObjectTreeModel:__init()
	-- empty
end

function ObjectTreeModel:getIndex( row, col, parentIndex )
	if not treeData then return -1 end
	local parentNode = treeData[parentIndex]
	if #parentNode.children == 0 then
		return -1
	end
	if #parentNode.children <= row then return -1 end
	return parentNode.children[row+1].index
end

function ObjectTreeModel:getParentIndex( index )
	if not treeData then return -1 end
	return treeData[index].parent
end

function ObjectTreeModel:getRow( index )
	if not treeData then return 0 end
	return treeData[index].row - 1
end

function ObjectTreeModel:getColumn( index )
	return 0
end

function ObjectTreeModel:setData( index, data, role )
	if not treeData then return false end
	local entity = treeData[index].data
	
	if role == qt.CheckStateRole then
		local checkState = true
		if data == qt.Unchecked then
			checkState = false
		end
		treeData[index].data.visible = checkState
			
		return true
	elseif role == qt.DisplayRole then
		-- alter name of entity
		return true
	end
	return false
end

function ObjectTreeModel:getData( index, role )
	if not treeData then return nil end
	local data = nil
	if role == qt.DisplayRole then
		-- check whether this is the root namespace (empty name)
		data = treeData[index].data.name
	elseif role == qt.CheckStateRole then
		local checkState = qt.Unchecked
		if treeData[index].data.visible then
			checkState = qt.Checked
		end
		data = checkState
	elseif role == qt.TextAlignmentRole then
		data = qt.AlignLeft + qt.AlignJustify
	elseif role == qt.DecorationRole then
		data = treeData[index].data.icon or icons.element
	elseif role == qt.FontRole then
		data = treeData[index].data.font
	elseif role == qt.ForegroundRole then
		data = treeData[index].data.color
	end
	
	return data
end

function ObjectTreeModel:getFlags( index )
	if not treeData then return 0 end
	return qt.ItemIsSelectable + qt.ItemIsEnabled + qt.ItemIsUserCheckable + qt.ItemIsDragEnabled + qt.ItemIsDropEnabled
end

function ObjectTreeModel:getHorizontalHeaderData( section, role )
	if not treeData then return nil end
	if section == 0 and role == qt.DisplayRole then
		local projectName = treeData.rootName
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
	if not treeData then return 0 end
	-- every parent is at column 0
	-- root element has one column if objectTreeData.instance contains any data
	if not treeData:isValidIndex( parentIndex ) then
		return 1
	end

	if #treeData[parentIndex].children > 0 then
		return 1
	else
		return 0
	end
end

function ObjectTreeModel:getRowCount( parentIndex )
	if not treeData then return 0 end
	return #treeData[parentIndex].children
end

function ObjectTreeModel:dropMimeData( mimeDataList, action, row, column, parentIndex )
	-- iterate moved items indexes
	local insertBeforeIndex = -1
    if row ~= -1 then
		insertBeforeIndex = row
	elseif treeData:isValidIndex( parentIndex ) then
		-- the drop ocurred in a valid item (not somewhere else of the view)
		insertBeforeIndex = self:getRow( parentIndex )
	else
		-- we are dropping into some other point of the view, so append it ater last element
		insertBeforeIndex = self:getRowCount( treeData.rootIndex )
	end
	
	-- shift one because Qt (C++) and this model index columns/rows differently
	insertBeforeIndex = insertBeforeIndex + 1
	local insertBeforeEntity = treeData[insertBeforeIndex].data

	qtSelectionModel:clearSelection()
	
	for i, v in ipairs( mimeDataList ) do
		local currentIndex = tonumber( v )
		local entity = treeData[currentIndex].data
		if entity == insertBeforeEntity then
			return false -- drag and drop item are the same
		end
		
		-- swap place
		lab3d.activeProject:removeEntity( entity )
		lab3d.activeProject:insertEntity( insertBeforeEntity, entity )
	end
	
	rebuildTree( lab3d.activeProject.entities )
	return true
end

function ObjectTreeModel:itemClicked( view, index )
	if type( self.observer.onClickItem ) == "function" then
		self.observer:onClickItem( view, treeData[index].data )
	end
end

function ObjectTreeModel:itemDoubleClicked( view, index )
	if type( self.observer.onDoubleClickItem ) == "function" then
		self.observer:onDoubleClickItem( view, treeData[index].data )
	end
end

-------------------------------------------------------------------------------
--- Implements world and entities observers in order to keep model updated
-------------------------------------------------------------------------------
local function onNameChanged( entity )
	local entityIndex = treeData:getDataIndex( entity ) 
	self.concreteModel:notifyDataChanged( entityIndex, entityIndex )
end

local function onVisibleChanged( entity )
	local entityIndex = treeData:getDataIndex( service ) 
	self.concreteModel:notifyDataChanged( entityIndex, entityIndex )
end

local function onSelectedEntityChanged( previous, current )
	if not current then
		if not previous then return end
		-- just deselected current entity but no other was selected (no selection)
		local previousIndex = treeData:getDataIndex( previous )
		qtSelectionModel:setItemSelection( previousIndex, false )
	else
		local currentIndex = treeData:getDataIndex( current )
		if not currentIndex then return end -- selection event probably occurred before add event
		qtSelectionModel:setItemSelection( currentIndex, true )
	end
end

ca.observe( "lab3d.dom.IProject", function( e )
	if e.service ~= lab3d.activeProject then return end

	local changedEntities = e.changedFields.entities
	if changedEntities then
		rebuildTree( e.service.entities )
	end	
	local selection = e.changedFields.selectedEntity
	if selection then
		onSelectedEntityChanged( selection.previous, selection.current )
	end
end )

ca.observe( "lab3d.dom.IEntity", function( e )
	local entity = e.service
	local changed = e.changedFields
	if changed.name then
		onNameChanged( entity ) 
	end
end )

local observeWorkspace = ca.observe( lab3d.workspace )
function observeWorkspace.activeProject( e )
	local currentProject = e.current
	if currentProject then
		treeData = ObjectTree:new()
		treeData.rootName = currentProject.name		
		rebuildTree( currentProject.entities )		
	end
end

return function( observer )
	local modelObj = co.new( "qt.AbstractItemModel" )
	qtModel = modelObj.itemModel
	qtSelectionModel = modelObj.selectionModel

	qtModel.delegate = ObjectTreeModel{ observer = observer }.delegate
	return qtModel, qtSelectionModel
end