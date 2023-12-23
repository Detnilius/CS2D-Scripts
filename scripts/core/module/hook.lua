local _VERSION = 'hook: 0.1'

local table_insert, table_remove, table_sort
	= table.insert, table.remove, table.sort

local string_format, string_lower, string_sub
	= string.format, string.lower, string.sub

local addhook, error, ipairs, print, setmetatable, tostring, type, unpack
	= addhook, error, ipairs, print, setmetatable, tostring, type, unpack

local GLOBAL_VARNAME = '_callhook'

local objList = {}
local objMethods = {
    destroy = function(self)
		for i, obj in ipairs(objList[self.name]) do
			if (self == obj) then
				table_remove(objList[self.name], i)
				break
			end
		end

		setmetatable(self, nil)
	end,
}
local objMeta = {
	__type = 'hook',
	__index = objMethods,
	__tostring = function(self)
		return self._address
	end,
}

local M = {_VERSION = _VERSION}
local MMeta = {
	__type = 'module',
	__call = function(self, ...)
		return self.add(unpack(arg))
	end,
	__tostring = function()
		return _VERSION
	end,
}

local function hook_sort(hookList)
	local l = {}
	
	for i, obj in ipairs(hookList) do
		l[obj] = i
	end
	
	table_sort(hookList, function(a, b)
		if (a.priority == b.priority) then
			return l[a] < l[b]
		end
		
		return a.priority > b.priority
	end)
end

function M.add(name, func, par1, par2)
    local nameType, funcType = type(name), type(func)

    if (nameType ~= 'string') then
		error('bad argument #1 (string expected, got '..nameType..')', 2)
	elseif (funcType ~= 'function'and func ~= nil) then
		error('bad argument #2 (function expected, got '..funcType..')', 2)
	end

    local prio, custom

	if (par1 or par2) then
		local par1Type, par2Type = type(par1), type(par2)
		
		if (par1Type == par2Type) then
			error('identical type of parameters #3 #4', 2)
		end
		
		if (par1Type == 'number') then
			prio = par1
		elseif (par1Type == 'boolean') then
			custom = par1
		end
		
		if (par2Type == 'number') then
			prio = par2
		elseif (par2Type == 'boolean') then
			custom = par2
		end
	end

    name = string_lower(name)

	if not _G[GLOBAL_VARNAME] then
		_G[GLOBAL_VARNAME] = {}
	end

    if not _G[GLOBAL_VARNAME][name] then
		_G[GLOBAL_VARNAME][name] = function(...)
			local lastArgN = arg.n + 1

            for i = #objList[name], 1, -1 do
                local obj = objList[name][i]

                if obj.enabled and (type(obj.func) == 'function') then
                    arg[lastArgN] = obj
                    local retVal = obj.func(unpack(arg))
					
					if retVal then
						return retVal
					end
                end
            end
		end
	end

    if not objList[name] then
		objList[name] = {}
		
		if custom then
			print(string_format("\169115110255Lua: Adding function '%s.%s' to custom hook '%s'", GLOBAL_VARNAME, name, name))
		else
			addhook(name, GLOBAL_VARNAME .. '.' .. name)
		end
	end

    local obj = {
        name = name,
		func = func,
		custom = custom,
		
		priority = prio or 0,
		enabled = true,
    }
    
    obj._address = 'hook{'..name..'}: '..string_sub(tostring(obj), 8)

    table_insert(objList[name], 1, obj)
    hook_sort(objList[name])

    return setmetatable(obj, objMeta)
end

return setmetatable(M, MMeta)