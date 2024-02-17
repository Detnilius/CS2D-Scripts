local _VERSION = 'include: 1.0'

local error, getmetatable, ipairs, loadfile, next, pcall, print, setmetatable, type
	= error, getmetatable, ipairs, loadfile, next, pcall, print, setmetatable, type

local string_find, string_gsub, string_lower
	= string.find, string.gsub, string.lower

local LOOP_MARKER = newproxy()

local loaded, paths, debug = {}, {}, {}
local include = setmetatable({}, {
	__call = function(self, ...)
		return self.load(...)
	end,
	__tostring = function()
		return _VERSION
	end,
})

local function get_filename(modname)
	local var_type = type(modname)

	if var_type ~= 'string' and var_type ~= 'number' then
		error('bad argument #1 (string expected, got '..var_type..')', 3)
	end

	return string_gsub(string_lower(modname), '%.', '/')
end

function include.load(modname, ...)
	local filename = get_filename(modname)

	if loaded[filename] == LOOP_MARKER then
		error("loop or previous error loading module '"..modname.."'", 2)
	elseif loaded[filename] ~= nil then
		return loaded[filename]
	end

	local files = ''

	for _, path in next, paths do
		local filepath = string_gsub(path, '%?', filename)
		local func, err = loadfile(filepath)

		if func then
			if debug.include then
				print("\169115110255Lua: Loading module '"..modname.."'")
			end

			loaded[filename] = LOOP_MARKER
			local status, result = pcall(func, include, ...)

			if status then
				result = result == nil or result
				loaded[filename] = result
				return result
			end

			error(result, 0)
		elseif not string_find(err, 'No such file') then
			error("error loading module '"..modname.."' from file '"..filepath.."':\n\t"..err, 0)
		end

		files = files.."\n\tno file '"..filepath.."'"
	end

	error("module '"..modname.."' not found:"..files, 2)
end

function include.path(...)
	if arg.n == 0 then
		return paths
	end

	for i, path in ipairs(arg) do
		local var_type = type(path)

		if var_type ~= 'string' then
			error('bad argument #'..i..' (string expected, got '..var_type..')', 2)
		end

		paths[#paths + 1] = path
	end
end

function include.debug(modname)
	if not modname then
		return debug
	end

	local filename = get_filename(modname)

	if not debug[filename] then
		debug[filename] = {}
	end

	return debug[filename]
end

function include.destroy(modname)
	local filename = get_filename(modname)
	local module = loaded[filename]

	if module ~= nil then
		if debug.include then
			print("\169115110255Lua: Destroying module '"..modname.."'")
		end

		if type(module) == 'table' then
			local module_meta = getmetatable(module)
			
			if type(module_meta) == 'table' and type(module_meta.__destroy) == 'function' then
				module_meta:__destroy()
			end
		end
		
		loaded[filename] = nil
	end
end

if string_find((...) or '', '-I') then
	loaded.include = include
end

return include