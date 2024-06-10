local error, getmetatable, ipairs, loadfile, next, pcall, print, setmetatable, type
	= error, getmetatable, ipairs, loadfile, next, pcall, print, setmetatable, type

local string_find, string_gsub, string_lower
	= string.find, string.gsub, string.lower

local LOOP_MARKER = newproxy()

local include = {}
local loaded, paths, debug = {}, {}, {}

local function get_filename(module_name)
	local var_type = type(module_name)

	if var_type ~= 'string' and var_type ~= 'number' then
		error('bad argument #1 (string expected, got '..var_type..')', 3)
	end

	return string_gsub(string_lower(module_name), '%.', '/')
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

function include.debug(module_name)
	if not module_name then
		return debug
	end

	local filename = get_filename(module_name)

	if not debug[filename] then
		debug[filename] = {}
	end

	return debug[filename]
end

function include.destroy(module_name)
    local filename = get_filename(module_name)
	local module = loaded[filename]

    if module ~= nil then
		local _ = debug.include and print("\169115110255Lua: Destroying module '"..module_name.."'")
		
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

return setmetatable(include, {
    __call = function(self, module_name, ...) -- main loader
        local filename = get_filename(module_name)

        if loaded[filename] == LOOP_MARKER then
            error("loop or previous error loading module '"..module_name.."'", 2)
        elseif loaded[filename] ~= nil then
            return loaded[filename]
        end

        loaded[filename] = LOOP_MARKER
        local files = ''

        for _, path in next, paths do
            local filepath = string_gsub(path, '%?', filename)
            local func, err = loadfile(filepath)

            if func then
                local _ = debug.include and print("\169115110255Lua: Loading module '"..module_name.."'")
			    local status, result = pcall(func, include, ...)

                if status then
                    result = result == nil or result
                    loaded[filename] = result
                    return result
                end

                error(result, 0)
            elseif not string_find(err, 'No such file') then
                error("error loading module '"..module_name.."' from file '"..filepath.."':\n\t"..err, 0)
            end

            files = files.."\n\tno file '"..filepath.."'"
        end

        error("module '"..module_name.."' not found:"..files, 2)
    end,
})