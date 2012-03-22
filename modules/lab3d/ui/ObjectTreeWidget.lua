--[[---------------------------------------------------------------------------
	ObjectTree module.
	Provides a Lua based api to manage a QTreeView instance capable of showing
	a hierachy of elements. To add an alement within the three hierarchy,
	simple call addObject passing a table object containing a name.
	The table object can also optionally contain a icon to be displayed along
	with the name. The addObject method always returns the new index for the
	recentyle added element, which is the unique id for it while it is in the
	tree. To add a child element, simple pass the object plus the parent index
	of any other element within the three.

	When the tree is created throu new() method, it receives two lua closures:
	one for click event notification and another for double click event
	notification, respectivelly. Both closures take the clicked element as
	parameter.
--]]---------------------------------------------------------------------------

local qt = require "qt"
local SceneManager = require "lab3d.scene.SceneManager"
local observeFields = require "lab3d.helper.ObserveFields"
local ObjectTreeModel = require "lab3d.ui.ObjectTreeModel"
local ProjectObserver = require "lab3d.helper.ProjectObserver"

local L = {}
-- icon files
L.icons =
{
	group 			= qt.Icon( "coral:/ui/res/tree_roup.png" ),
	element 		= qt.Icon( "coral:/ui/res/tree_element.png" )
}

--[[---------------------------------------------------------------------------
	Local auxiliary
--]]---------------------------------------------------------------------------
-- adds an element into to current model and updates treeview state
function L:addElementToTreeView( parentIndex, name, userData, isGroup )
	local parentNode = self.objectTreeData.instance[parentIndex]
	local position = #parentNode.children
	self.itemModel:beginInsertRows( parentIndex, position, position )
	local newNode = { name = name or "", data = userData, isGroup = isGroup or false }
	local newIndex = self.objectTreeData.instance:add( newNode, parentIndex or -1 )
	self.itemModel:endInsertRows()
	return newIndex
end

function L:removeElementFromTreeView( elementIndex )
	local node = self.objectTreeData.instance[elementIndex]
	local parentIndex = node.parent
	self.itemModel:beginRemoveRows( parentIndex, (node.row-1), (node.row-1) )
	self.objectTreeData.instance:remove( elementIndex )
	self.itemModel:endRemoveRows()
end

function L:setIndexSelection( index, value )
	if not index then return end
	self.treeViewWidget:clearSelection()
	self.treeViewWidget:setItemSelection( index, value )
end

function L:entityAdded( entity )
	local newIndex = self:addElementToTreeView( -1, entity.name, entity )
	self.entityIndices[entity] = newIndex

	if self.application.currentProject.selectedEntity == entity then
		-- remove any other selection
		self.treeViewWidget:clearSelection()
		self:setIndexSelection( newIndex, true )
	end
end

function L:entityRemoved( entity )
	local entityIndex = self.entityIndices[entity]
	self:removeElementFromTreeView( entityIndex )
	self.entityIndices[entity] = nil
	self.treeViewWidget:clearSelection()
end

function L:entitySelectionChanged( current )
	self.treeViewWidget:clearSelection()
	if current then
		local entityIndex = self.entityIndices[current]
		if not entityIndex then return end
		self:setIndexSelection( entityIndex, true )
	end
end

function L:entityNameChanged( entity, newName )
	local entityIndex = self.entityIndices[entity]

	-- change object tree element
	self.objectTreeData.instance[entityIndex].name = newName
	self.itemModel:notifyDataChanged( entityIndex, entityIndex )
end

--[[---------------------------------------------------------------------------
	Local auxiliary and signal/slots closures
--]]---------------------------------------------------------------------------
function L.createTreeContextMenu( actionExcludeSelected )
	L.contextMenu = qt.new "QMenu"
	local actionRemoveElement = qt.new "QAction"
	L.actionExcludeSelected = actionExcludeSelected
	L.contextMenu:addAction( actionExcludeSelected )
end

function L.on_showContextMenu( sender, x, y )
	local selectedEntity = L.application.currentProject.selectedEntity
	L.actionExcludeSelected.enabled = ( selectedEntity ~= nil )
	if not selectedEntity then
		sender:clearSelection()
		L.actionExcludeSelected.text = "(No object selected)"
	else
		L.actionExcludeSelected.text = "Remove '" .. selectedEntity.name .. "'"
	end
	L.contextMenu:exec()
end

-------------------------------------------------------------------------------
-- Object Tree Data Structure
-------------------------------------------------------------------------------
local ObjectTree = {}

-- Add an element
function ObjectTree:add( element, parentIndex )
	-- creates a node data
	local node =
	{
		data = element.data,
		name = element.name,
		icon = element.icon or L.icons.element,
		index = self.nextIndex,
		parent = parentIndex,
		children = {}
	}
	self[node.index] = node
	self.nextIndex = self.nextIndex + 1

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

function ObjectTree:isValidIndex( index )
	return index >= 0
end

function ObjectTree:new()
	ObjectTree.__index = ObjectTree
	local self = setmetatable( {}, ObjectTree )

	self.rootIndex = -1
	self[self.rootIndex] = { children = {} }
	self.nextIndex = 1

	return self
end

-------------------------------------------------------------------------------
-- ObjectTree qt Model
-------------------------------------------------------------------------------
function ObjectTreeModel:itemClicked( view, index )
	local node = self.objectTreeData.instance[index]
	if not node or not node.data then return end

	local entity = node.data

	if L.application.currentProject.selectedEntity == entity then return end

	L.application.currentProject:setEntitySelected( entity )
end

function ObjectTreeModel:itemDoubleClicked( view, index )
	local node = self.objectTreeData.instance[index]
	if not node or not node.data then return end

	local entity = node.data

	local view = SceneManager.scene.camera.view
	view:setPose( view:calculateNavigationToObject( entity ) )
end

--[[---------------------------------------------------------------------------
	Project observer events
--]]---------------------------------------------------------------------------
function L:onProjectOpened( newProject )
	self.entities = newProject.entities

	self.entityIndices = {}
	self.objectTreeData.instance = ObjectTree:new()
	self.objectTreeData.instance.rootName = ""
	self.itemModel:reset()

	for i=1, #newProject.entities do
		local entity = self.entities[i]
		observeFields:addFieldObserver( self.application.space, entity, self )
		self:entityAdded( entity )
	end

	-- set tree root name
	self.objectTreeData.instance.rootName = newProject.name
end

function L:onProjectClosed( project )
	-- Temp workaround to stop observing all the entities from the project being closed
	local ents = project.entities
	for i=1, #ents do
		observeFields:removeFieldObserver( self.application.space, ents[i], self )
	end

	self:entitySelectionChanged( nil )
	self.entities = nil
end

-- Callbacks for observing IProject
function L:onEntitiesAdded( service, addedObjects )
	for i = 1,#addedObjects do
		assert( addedObjects[i] )
		-- install an observing service for that entity, needed to track entity name changes
		observeFields:addFieldObserver( self.application.space, addedObjects[i], self )
		self:entityAdded( addedObjects[i] )
	end
end

function L:onEntitiesRemoved( service, removedObjects )
	for i = 1,#removedObjects do
		assert( removedObjects[i] )
		-- remove installed observer
		observeFields:removeFieldObserver( self.application.space, removedObjects[i], self )
		self:entityRemoved( removedObjects[i] )
	end
end

-- Callback for observing IProject
function L:onEntitySelectionChanged( service, previous, current )
	self:entitySelectionChanged( current )
	L.actionExcludeSelected.enabled = (current ~= nil)
end

-- Callback for observing IEntity
function L:onNameChanged( service, previous, current )
	self:entityNameChanged( service, current )
end

--[[---------------------------------------------------------------------------
-- Instantiation function
--]]---------------------------------------------------------------------------
return function( mainWindow )
	if not L.dockConsoleWidget then
		-- configuire QTreeView
		local treeViewWidget = qt.new( "QTreeView" )
		treeViewWidget.objectName = "treeViewWidget"
		treeViewWidget.contextMenuPolicy = qt.CustomContextMenu
		treeViewWidget:connect( "customContextMenuRequested(QPoint)", L.on_showContextMenu )
		treeViewWidget.alternatingRowColors = true
		treeViewWidget.wordWrap = true

		--[[
			Creates the hierarchical data structure to be used by the tree model.
			The tree widget reflects the state of this data structure. An instance
			pointer is needed for sharing: the instance pointer can be changed any
			time (e.g: due to project close instance = ObjectTree:new()). The same
			instance pointer is shared between WorldObserver and the ObjectTreeModel.
		--]]
		local objectTreeData = { instance = nil }

		-- creates a new instance of ObjectTreeModel (see qt.IAbstractItemModel)
		local treeDelegate = ObjectTreeModel{ objectTreeData = objectTreeData }
		-- creates the model instance sets the delegate into the model
		local itemModel = co.new( "qt.AbstractItemModel" ).itemModel
		itemModel.delegate = treeDelegate.delegate
		treeViewWidget:setModel( itemModel )

		L.itemModel = itemModel
		L.treeViewWidget = treeViewWidget
		L.objectTreeData = objectTreeData
		ProjectObserver:addObserver( L )

		L.dockConsoleWidget = qt.new( "QDockWidget" )
		L.dockConsoleWidget.windowTitle = "Project Tree"
		L.dockConsoleWidget:setWidget( treeViewWidget )

		L.createTreeContextMenu( mainWindow.action_ExcludeSelected )

		L.application = co.system.services:getService( co.Type["lab3d.IApplication"] )
	end

	return L.dockConsoleWidget
end

