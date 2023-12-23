local _VERSION = 'include: 0.1'

local error, getmetatable, ipairs, loadfile, next, pcall, print, setmetatable, type
	= error, getmetatable, ipairs, loadfile, next, pcall, print, setmetatable, type

local string_find, string_gsub, string_lower
	= string.find, string.gsub, string.lower

local LOOP_MARKER = newproxy()

local mLoaded = {}
local mPath = {}
local mDebug = {}

local M = {_VERSION = _VERSION}
local MMeta = {
	__type = 'module',
	__call = function(self, ...)
		return M.load(...)
	end,
	__tostring = function()
		return _VERSION
	end,
}

local function getFileName(moduleName)
	local varType = type(moduleName)
		
	if (varType ~= 'string' and varType ~= 'number') then
		error('bad argument #1 (string expected, got '..varType..')', 3)
	end
	
	return string_gsub(string_lower(moduleName), '%.', '/')
end

function M.load(moduleName, ...)
	local fileName = getFileName(moduleName)
	
	if (mLoaded[fileName] == LOOP_MARKER) then
		error("loop or previous error loading module '"..moduleName.."'", 2)
	elseif (mLoaded[fileName] ~= nil) then
		return mLoaded[fileName]
	end
	
	local moduleErr = ''
	
	for _, path in next, mPath do
		local filePath = string_gsub(path, '%?', fileName)
		local fileFunc, fileErr = loadfile(filePath)
		
		if fileFunc then
			mLoaded[fileName] = LOOP_MARKER
			print("\169115110255Lua: Loading module '"..moduleName.."'")
			local success, result = pcall(fileFunc, M, ...)
			
			if success then
				result = result == nil or result
				mLoaded[fileName] = result
				return result
			end
			
			error(result, 0)
		elseif not string_find(fileErr, 'No such file') then
			error("error loading module '"..moduleName.."' from file '"..filePath.."':\n\t"..fileErr, 0)
		end
		
		moduleErr = moduleErr.."\n\t".."no file '"..filePath.."'"
	end
	
	error("module '"..moduleName.."' not found:"..moduleErr, 2)
end

function M.path(...)
	if (arg.n == 0) then
		return mPath
	end
	
	for i, path in ipairs(arg) do
		local varType = type(path)
		
		if (varType ~= 'string') then
			error('bad argument #'..i..' (string expected, got '..varType..')', 2)
		end
		
		mPath[#mPath + 1] = path
	end
end

function M.debug(moduleName, enabled)
	if not moduleName then
		return mDebug
	end
	
	local fileName = getFileName(moduleName)
	
	if not mDebug[fileName] then
		mDebug[fileName] = {}
	end
	
	if (enabled == nil) then
		return mDebug[fileName]
	end
	
	mDebug[fileName].enabled = enabled
end

function M.destroy(moduleName)
	local fileName = getFileName(moduleName)
	
	if (mLoaded[fileName] ~= nil) then
		print("\169115110255Lua: Destroying module '"..moduleName.."'")
		
		if (type(mLoaded[fileName]) == 'table') then
			local moduleMeta = getmetatable(mLoaded[fileName])
			
			if moduleMeta and moduleMeta.__destroy then
				moduleMeta:__destroy()
			end
		end
		
		mLoaded[fileName] = nil
	end
end

if string_find((...) or '', '-I') then
	mLoaded.include = M
end

return setmetatable(M, MMeta)