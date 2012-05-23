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
local lab3d = require "lab3d"
local ObjectTreeModel = require "lab3d.ui.ObjectTreeModel"

local M = {}

--[[---------------------------------------------------------------------------
	Local auxiliary and signal/slots clorsures
--]]---------------------------------------------------------------------------
function M.createTreeContextMenu( actionExcludeSelected )
	M.contextMenu = qt.new "QMenu"
	local actionRemoveElement = qt.new "QAction"
	M.actionExcludeSelected = actionExcludeSelected
	M.contextMenu:addAction( actionExcludeSelected )
end

function M.on_showContextMenu( sender, x, y )
	local selectedEntity = M.user.selectedEntity
	M.actionExcludeSelected.enabled = ( selectedEntity ~= nil )
	if not selectedEntity then
		M.actionExcludeSelected.text = "(Nenhum Objeto Selecionado)"
	else
		M.actionExcludeSelected.text = "Remover '" .. selectedEntity.name .. "'"
	end
	M.contextMenu:exec()
end

-------------------------------------------------------------------------------
-- ObjectTree qt Model
-------------------------------------------------------------------------------
function M:onClickItem( view, itemEntity )
	local project = lab3d.activeProject
	if not project then return end
	project.selectedEntity = itemEntity
end

function M:onDoubleClickItem( view, itemEntity )
	local project = lab3d.activeProject
	if not project then return end

	local view = project.currentView
	view.position, view.orientation = view:calculateNavigationToObject( itemEntity )
end

--[[---------------------------------------------------------------------------
-- Instantiation function
--]]---------------------------------------------------------------------------
return function( mainWindow )
	if not M.dockConsoleWidget then
		-- configuire QTreeView
		local treeViewWidget = qt.new( "QTreeView" )
		treeViewWidget.objectName = "treeViewWidget"
		
		-- configure QTreeView
		treeViewWidget.wordWrap = true
		treeViewWidget.showDropIndicator = true
		treeViewWidget.dragDropMode = qt.DragDrop
		treeViewWidget.alternatingRowColors = true
		treeViewWidget.editTriggers = qt.SelectedClicked
		treeViewWidget.selectionMode = qt.SingleSelection
		treeViewWidget.contextMenuPolicy = qt.CustomContextMenu
		
		treeViewWidget:connect( "customContextMenuRequested(QPoint)", M.on_showContextMenu )
		
		-- creates a new instance of ObjectTreeModel (see qt.IAbstractItemModel)
		local treeModel, selectionModel = ObjectTreeModel( M )
		treeViewWidget:setModel( treeModel )
		treeViewWidget:setSelectionModel( selectionModel )

		M.dockConsoleWidget = qt.new( "QDockWidget" )
		M.dockConsoleWidget.windowTitle = "Project Tree"
		M.dockConsoleWidget:setWidget( treeViewWidget )

		M.createTreeContextMenu( mainWindow.action_ExcludeSelected )
	end

	return M.dockConsoleWidget
end
