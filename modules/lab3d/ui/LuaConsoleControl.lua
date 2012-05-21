local pcall = pcall
local loadstring = loadstring
local tostring = tostring
local type = type
local loadin = loadin

local M = {}
local env = _ENV
local history = {}
local historyAt = 0

function M.clearHistory()
	history = {}
end

function M.executeNew( command )
	history[#history + 1] = command
	historyAt = #history + 1

	command = command:gsub( "^%s*(=)", "return ")
	local res = { pcall( load( command, command, 't', env ) ) }

	local str
	if not res[1] then
		str = "[Error]: "
	else
		str = "[OK]: "
	end

	if #res > 1 then
		str = str .. "returned value(s): " .. tostring( res[2] )
		for i = 3, #res do
			str = str .. ", " .. tostring( res[i] )
		end
	else
		str = str .. "no returned value"
	end

	return res[1], str
end

function M.setConsoleEnv( consoleEnv )
	if consoleEnv then
		env = consoleEnv
	else
		env = {}
	end
	setmetatable( env, { __index = _G } )
end

local function getParamQualifier( isIn, isOut )
	return isIn and ( isOut and " inout " or " in " ) or " out "
end

local memberFormatters = {
	MK_PORT = function( port )
		return ( field.isFacet and "provides " or "receives " )
			.. field.name .. " : " .. field.type.fullName
	end,
	MK_FIELD = function( field )
		return field.name .. " : " .. field.type.fullName
			.. ( field.isReadOnly and "(readonly)" or "" )
	end,
	MK_METHOD = function( method )
		local str = "void"
		if method.returnType then
			str = method.returnType.fullName
		end
		str = str .. " " .. method.name .. "("
		for i, v in ipairs( method.parameters ) do
			str = str .. getParamQualifier( v.isIn, v.isOut )
				.. v.type.fullName .. " " .. v.name
				.. ( i ~= #method.parameters and "," or " " )
		end
		return str .. ")"
	end,
}

local function addMemberList( lines, members )
	for i, m in ipairs( members ) do
		lines[#lines+1] = "  " .. memberFormatters[m.kind]( m )
	end
end

function M.getMemberInfo( command, requested )
	local varName = command:match( "^%s*=?%s*([%w_.]-)[.:]?$" )
	if not varName then return end

	local object = env
	for w in varName:gmatch( "([%w_]*)" ) do
		if w and w ~= "" then
			object = object[w]
			if not object then return end
		end
	end

	local lines
	local tp = type( object )

	if tp == "table" and requested == "fields" then
		lines = { "Fields in table '" .. varName .. "':" }
		for k, v in pairs( object ) do
			lines[#lines+1] = "  [" .. tostring( k ) .. "] = " .. tostring( v )
		end
	elseif tp == "userdata" then
		-- check if its a Coral type
		tp = co.typeOf( object )
		if not tp then return end
		tp = co.Type[tp]
		if requested == "fields" then
			if tp.kind == "TK_COMPONENT" then
				lines = { "Ports in " .. varName .. " (" .. tp.fullName .. "):" }
				addMemberList( lines, tp.ports )
			else
				lines = { "Fields in " .. varName .. " (" .. tp.fullName .. "):" }
				addMemberList( lines, tp.fields )
			end
		else
			lines = { "Methods in " .. varName .. " (" .. tp.fullName .. "):" }
			addMemberList( lines, tp.methods )
		end
	end

	if lines then return table.concat( lines, "\n" ) end
end

function M.previousCmd()
	historyAt = historyAt > 1 and historyAt - 1 or 1
	return history[historyAt]
end

function M.nextCmd()
	local historySize = #history
	historyAt = historyAt < historySize and historyAt + 1 or historySize
	return history[historyAt]
end

return M
