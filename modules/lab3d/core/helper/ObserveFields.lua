--[[---------------------------------------------------------------------------
This Lua only component creates a layer between the ca.Space and any lua
table that wants to observe a service. So the user does not have to 
implement the traditional ca.IServiceObserver interface and handle the 
ca.IServiceChanges. 
Instead, a lua table can be registered here with the addFieldObserver 
method. Then, if a field in the observed service is changed, a callback in
the registered lua table will be called. 
The callback template is onFieldnameChanged( self, previous, current ) for
Ref and Value Fields, and onFieldnameAdded / onFieldnameRemoved for RefVecs.

- Singleton method, just require and use the functions directly
--]]---------------------------------------------------------------------------

local MT = {}
local strSub = string.sub
local strUpper = string.upper

--[[---------------------------------------------------------------------------
This table has an index for every space to be tracked. Every value indexed
by a space is table that has an index for every service to be tracked in
the space. Every value indexed by a service in these per service table 
is a table with only 2 indices:
first index holds an array of ObserverTables that observers the service.
second index holds a table that maps observerTables to their indices.
service. So, suppose an observerTable ot1 that observes fields of service s1
in space sp1: 
ot1 = spacesTable[sp1][s1][1][ot1Index] -- Array for effiecient iter.
ot1Index = spacesTable[sp1][s1][2][ot1] -- Map for efficient searching
--]]---------------------------------------------------------------------------
local spacesTable = {}

-- This table maps a space to the GenericObserver created for it
local spaceToGenObs = {}

-- Generic service observer. Expect to receive (in constructor)
-- the actual Observer that the field changes events will be forwarded to
local GenericObserver =  co.Component( "lab3d.core.helper.ServiceObserver" )

-- Iterate through the changed fields(any kind). Forwarding the events
-- to the actual observer.
local function forwardEvents( self, service, observerTable, changedFields, numChangedFields )
	for i = 1, numChangedFields do
		local fieldName = changedFields[i].field.name
		local functionName = "on" .. strUpper( strSub( fieldName, 1, 1 ) ) ..
		strSub( fieldName, 2 ) .. "Changed"
		if observerTable[functionName] then
			observerTable[functionName]( observerTable, service, changedFields[i].previous,
			changedFields[i].current )
		end
	end
end

-- Iterate throught the changed array fields. Forwarding a list of added values ( addedObjects )
-- and a list of remuved values ( removedObjects )
local function forwardArrayEvents( self, service, observerTable, changedFields, numChangedFields )
	for i = 1, numChangedFields do
		local fieldName = changedFields[i].field.name
		local functionName1 = "on" .. strUpper( strSub( fieldName, 1, 1 ) ) ..
		strSub( fieldName, 2 ) .. "Added"
		local functionName2 = "on" .. strUpper( strSub( fieldName, 1, 1 ) ) ..
		strSub( fieldName, 2 ) .. "Removed"
		-- Only foward if the observer have  both onObjectAdded 
		-- and onObjectRemoves where 'Object' is the field name.
		if ( observerTable[functionName1] and observerTable[functionName2] ) then
			local old = changedFields[i].previous
			local new = changedFields[i].current
			local addedObjects = {}
			local removedObjects = {}
			local oldAsSet = {}
			-- Create an array 'OldAsSet' with the number of each object in the old array
			for _, v in ipairs(old) do
				if oldAsSet[v] then
					oldAsSet[v] = oldAsSet[v] + 1
				else
					oldAsSet[v] = 1
				end		
			end
			-- If there is an object on the new array which isnt on the oldAsSet
			-- adds this object as an addedObject
			-- If the object it's on the oldAsSet array, subtracts 1 to the number of objects
			for _, v in ipairs(new) do
				if not oldAsSet[v] then
					addedObjects[#addedObjects+1] = v
				elseif ( oldAsSet[v] <= 0 ) then
					addedObjects[#addedObjects+1] = v
				else
					oldAsSet[v] = oldAsSet[v] - 1
				end
			end
			-- If there is any object which the number is more than zero (it wasnt subtracted)
			-- adds this object to the removedObjects array
			for v, k in pairs(oldAsSet) do
				if (k > 0) then
					for i = 1, k do
						removedObjects[#removedObjects+1] = v
					end
				end
			end
			-- Only returns if the array isn't empty
			if( #addedObjects > 0 ) then
				observerTable[functionName1]( observerTable, service, addedObjects )
			end
			if( #removedObjects > 0 ) then
				observerTable[functionName2]( observerTable, service, removedObjects )
			end
		end
	end
end


-- This is the callback called by the space where the service is tracked.
function GenericObserver:onServiceChanged( changes )
	-- Check if there are changed value fields
	local service = changes.service
	local obsTablesArray = self.servicesTable[service][1]
	local obsTablesArrayCount = #obsTablesArray
	local changedVFs = changes.changedValueFields
	local numChangedFs = #changedVFs
	if numChangedFs > 0 then

		for i = 1, obsTablesArrayCount do
			forwardEvents( self, service, obsTablesArray[i], changedVFs, numChangedFs )
		end
	end

	-- Check if there are changed Ref fields
	local changedRFs = changes.changedRefFields
	numChangedFs = #changedRFs
	if numChangedFs > 0 then
		for i = 1, obsTablesArrayCount do
			forwardEvents( self, service, obsTablesArray[i], changedRFs, numChangedFs )
		end
	end

	-- Check if there are changed RefVec fields
	local changedRVFs = changes.changedRefVecFields
	local numChangedFs = #changedRVFs
	if numChangedFs > 0 then
		for i = 1, obsTablesArrayCount do
			forwardArrayEvents( self, service, obsTablesArray[i], changedRVFs, numChangedFs )
		end
	end	
end

-- Add a new lua table to observe a service in the space
function MT:addFieldObserver( space, service, observerTable )
	-- will hold the GenericObserver (a new one if the space is new)
	local genObs = spaceToGenObs[space]

	-- creates a new Generic observer if there is none created for the provided space
	if not spacesTable[space] then 
		-- every per space value contains servicesTable (size is entry "n")
		spacesTable[space] = { n = 0 }

		genObs = ( GenericObserver{ servicesTable = spacesTable[space] } ).observer
		spaceToGenObs[space] = genObs
	end

	local servicesTable = spacesTable[space]
	if not servicesTable[service] then
		-- The GenericObject is added as observer for the provided service
		space:addServiceObserver( service, genObs )
		
		-- 2 tables are used, one is an array for fast iteration and
		-- the other is a table indexed by the observerTable for fast searching
		servicesTable[service] = { {}, {} }
		servicesTable.n = servicesTable.n + 1
	end

	local obsTableArray = servicesTable[service][1]
	local obsTableArraySize = #obsTableArray
	obsTableArray[obsTableArraySize + 1] = observerTable
	servicesTable[service][2][observerTable] = obsTableArraySize + 1
end

-- Removes the observer lua table
function MT:removeFieldObserver( space, service, observerTable )
	local servicesTable = spacesTable[space]
	local obsTablesArray = servicesTable[service][1]
	local obsTablesMap = servicesTable[service][2]

	-- Switch the last element of the array to the position of the removed one
	-- and update the references in the mapping table
	local obsTableIndex = obsTablesMap[observerTable]
	obsTablesMap[observerTable] = nil
	local obsTablesArraySize = #obsTablesArray
	local lastArrayElem = obsTablesArray[obsTablesArraySize]
	obsTablesArray[obsTableIndex] = lastArrayElem
	obsTablesArray[obsTablesArraySize] = nil
	obsTablesMap[lastArrayElem] = obsTableIndex

	-- If there is no more observers for the space, then remove the references.
	if obsTablesArraySize == 1 then
		servicesTable[service] = nil
		servicesTable.n = servicesTable.n - 1
		space:removeServiceObserver( service, spaceToGenObs[space] )
		if servicesTable.n == 0 then
			spacesTable[space] = nil
			spaceToGenObs[space] = nil
		end
	end
end

function MT:trackedSpaces()
	return spacesTable
end

return setmetatable( {}, { __index = MT } )
