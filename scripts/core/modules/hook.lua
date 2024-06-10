local addhook, error, ipairs, pcall, print, setmetatable, tostring, type, unpack
	= addhook, error, ipairs, pcall, print, setmetatable, tostring, type, unpack

local string_format, string_lower, string_sub
	= string.format, string.lower, string.sub

local table_insert, table_remove, table_sort
	= table.insert, table.remove, table.sort

local GLOBAL_VARNAME = '_callhook'

local hooks = {}
local hook = setmetatable({}, {
	__call = function(self, ...)
		if arg.n == 0 then
			return hooks
		 end
		local status, result = pcall(self.add, unpack(arg))
        if status then
			return result
		end
        error(result, 2)
	end,
})

local objects_cache = {}
local objects_meta = {
	__type = 'hook',
	__index = hook,
    __call = function(self, ...)
        arg[arg.n + 1] = self
        return self.func(unpack(arg))
    end,
	__tostring = function(self)
		return objects_cache[self].address
	end,
}

local function sort_objects(objects_list)
	local objects_index = {}
	
	for i, obj in ipairs(objects_list) do
		objects_index[obj] = i
	end
	
	table_sort(objects_list, function(obj1, obj2)
		if obj1.priority == obj2.priority then
			return objects_index[obj1] < objects_index[obj2]
		end
		
		return obj1.priority > obj2.priority
	end)
end

function hook.add(name, func, par1, par2)
	local priority, custom
	local name_type, func_type = type(name), type(func)
	local par1_type, par2_type = type(par1), type(par2)

	if name_type ~= 'string' then
		error('bad argument #1 (string expected, got '..name_type..')', 2)
	elseif func_type ~= 'function'and func ~= nil then
		error('bad argument #2 (function expected, got '..func_type..')', 2)
	elseif (par1_type == par2_type) and (par1 or par2) then
		error('identical type of parameters #3 #4', 2)
	end

	name = string_lower(name)

	if par1_type == 'number' then
		priority = par1
	elseif par1 == true then
		custom = par1
	end

	if par2_type == 'number' then
		priority = par2
	elseif par2 == true then
		custom = par2
	end

	if not hooks[name] then
		hooks[name] = {}

		if custom then
			print(string_format("\169115110255Lua: Adding function '%s.%s' to custom hook '%s'", GLOBAL_VARNAME, name, name))
		else
			addhook(name, GLOBAL_VARNAME..'.'..name)
		end
	end

	if not _G[GLOBAL_VARNAME] then
		_G[GLOBAL_VARNAME] = {}
	end

	if not _G[GLOBAL_VARNAME][name] then
		_G[GLOBAL_VARNAME][name] = function(...)
			local last_argn = arg.n + 1

			for i = #hooks[name], 1, -1 do
				local obj = hooks[name][i]

				if obj.enabled and type(obj.func) == 'function' then
					arg[last_argn] = obj
					local ret_val = obj.func(unpack(arg))

					if ret_val then
						return ret_val
					end
				end
			end
		end
	end

	local obj = {
		name = name,
		func = func,
		custom = custom,
		priority = priority or 0,
		enabled = true,
	}

	objects_cache[obj] = {
		address = 'hook{'..name..'}: '..string_sub(tostring(obj), 8),
		name = name,
	}

	table_insert(hooks[name], 1, obj)
	sort_objects(hooks[name])
	
	return setmetatable(obj, objects_meta)
end

function hook.call(name, ...)
	local name_type = type(name)
    if name_type ~= 'string' and name_type ~= 'number' then
		error('bad argument #1 (string expected, got '..name_type..')', 2)
    end
    
    name = string_lower(name)

	if _G[GLOBAL_VARNAME] and _G[GLOBAL_VARNAME][name] then
		return _G[GLOBAL_VARNAME][name](...)
	end
end

function hook:destroy()
	local name = objects_cache[self].name

	for i, obj in ipairs(hooks[name]) do
		if self == obj then
			table_remove(hooks[name], i)
			break
		end
	end

	objects_cache[self] = nil
	setmetatable(self, nil)
end

return hook