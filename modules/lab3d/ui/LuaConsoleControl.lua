local M = {}
local commHistory = {}
local historyAt = 0
local env = _ENV
local insert = table.insert
local pcall = pcall
local loadstring = loadstring
local tostring = tostring
local type = type
local loadin = loadin

function M.clearHistory()
	commHistory = {}
end

function M.executeNew( command )
	-- tries to find an '=' symbol at the begining of the string
	-- and replaces it by 'return'
	local cmd = string.gsub( command, "^%s*(=)", "return ")
	insert( commHistory, cmd )
	historyAt = #commHistory + 1

	ret = { pcall( load( cmd, "Console user input", 't', env ) ) }

	local str = ""
	local prefix = ""
	if not ret[1] then
		str = "[Erro]: "
	else
		str = "[Ok]"
		prefix = ": valor(es) retornados: "
	end

	if #ret > 1 then
		str = str .. prefix .. tostring( ret[2] )
		for i = 3, #ret do
			str = str .. ", " .. tostring( ret[i] )
		end
	else
		str = str .. ": Nenhum valor foi retornado"
	end

	return ret[1], str
end

function M.setConsoleEnv( consoleEnv )
	if consoleEnv then
		env = consoleEnv
	else
		env = {}
	end
	setmetatable( env, { __index = _G } )

end

local function extractMethod( method )
	local signature = method.name .. "("
	for i, v in ipairs( method.parameters ) do
		local parameter = ""
		if v.isIn and v.isOut then
			parameter = parameter .. " inout "
		elseif v.isIn then
			parameter = parameter .. " in "
		else
			parameter = parameter .. " out "
		end

		parameter = parameter .. v.type.name .. " " .. v.name
		if i ~= #method.parameters then
			parameter = parameter .. ","
		else
			parameter = parameter .. " "
		end
		signature = signature .. parameter .. " "		
	end
	if method.returnType then
		return method.returnType.name .. " " .. signature .. ")"
	end

	return "void " .. signature .. ")"
end

local function extractMember( member )
	return member.name
end

local function dumpInfo( targetTable, instance, fieldName, description, formatClosure )
	local fields = instance[fieldName]

	if not fields then return end

	for i, v in ipairs( fields ) do
		targetTable[ formatClosure( v ) ] = description
	end
end

function M.openContext( fullCommand )
	local object = env
	for w in string.gmatch( fullCommand, "=?([%w-_]*)%.?" ) do
		if w and w ~= "" then
			if not object then return end
			object = object[w]
		end
	end

	if not object then return end

	local objectType = type( object )
	if objectType == "table" then
		return object

	elseif objectType == "userdata" then
		local contextTable = {}

		-- check if its a component
		local objType = co.Type[ co.typeOf( object ) ]
		if objType then
			dumpInfo( contextTable, objType, "fields", "[Field]", extractMember )
			dumpInfo( contextTable, objType, "facets", "[Facet]", extractMember )
			dumpInfo( contextTable, objType, "receptacles", "[Receptacle]", extractMember )
			dumpInfo( contextTable, objType, "methods", "[Method]", extractMethod )
		end

		return contextTable
	end	
	return nil
end

function M.previousComm()
	historyAt = historyAt > 1 and historyAt - 1 or 1
	return commHistory[historyAt]
end

function M.nextComm()
	local historySize = #commHistory
	historyAt = historyAt < historySize and historyAt + 1 or historySize
	return commHistory[historyAt]
end

return M
