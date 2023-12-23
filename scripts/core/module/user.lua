local _VERSION = 'user: 0.1'

local setmetatable, tostring
	= setmetatable, tostring

local string_sub
	= string.sub

local objList = {}
local objCache = {}
local objMeta = {
	__type = 'user',
    __index = {
        get_id = function(self)
            return objCache[self].id
        end,
    },
	__tostring = function(self)
		return objCache[self].address
	end,
}

local M = {_VERSION = _VERSION}
local MMeta = {
	__type = 'module',
	__call = function(self, id, key)
		if not id then
			return objList
		end
		
		if not objList[id] then
			local obj = {}
			
			objCache[obj] = {
                id = id,
                address = 'user{'..id..'}: '..string_sub(tostring(obj), 8),
            }

			objList[id] = setmetatable(obj, objMeta)
		end
		
		if (key == nil) then
			return objList[id]
		end
		
		return objList[id][key]
	end,
	__tostring = function()
		return _VERSION
	end,
}

return setmetatable(M, MMeta)