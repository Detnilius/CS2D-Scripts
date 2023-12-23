local _VERSION = 'lib.std: 0.1'

local error, getmetatable, setmetatable, type
	= error, getmetatable, setmetatable, type

local string_format, string_gmatch, string_lower
	= string.format, string.gmatch, string.lower

local debug_getinfo
	= debug.getinfo

local M = {_VERSION = _VERSION}
local MMeta = {
	__type = 'module',
	__tostring = function()
		return _VERSION
	end,
}

function M.type(var)
	local varType = type(var)
	
	if (varType == 'table') then
		local tabMeta = getmetatable(var)
		
		if tabMeta and tabMeta.__type then
			return tabMeta.__type
		end
	end
	
	return varType
end

function M.type_error(...)
	local argN = arg.n
	
	if (argN == 0 or argN % 2 == 1) then
		error('invalid number of arguments', 2)
	end
	
	for i = 1, argN, 2 do
		local varType = M.type(arg[i])
		local expType = arg[i + 1]
		
		if (type(expType) ~= 'string') then
			error('invalid type of argument validation (string expected)', 2)
		end
		
		local isValid
		
		for type in string_gmatch(expType, '([^,%s]+)') do
			type = string_lower(type)
			if (varType == type or (type == 'value' and varType ~= 'nil')) then
				isValid = true
				break
			end
		end
		
		if not isValid then
			local fnName = debug_getinfo(2, 'n').name or debug_getinfo(1, 'n').name
			error(string_format("bad argument #%d to '%s' (%s expected: got %s)", (i/2 + 1), fnName, expType, varType), 3)
		end
	end
end

return setmetatable(M, MMeta)