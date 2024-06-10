local setmetatable, tostring, type
	= setmetatable, tostring, type

local string_sub
	= string.sub

local user = {}

local objects = {}
local objects_cache = {}
local objects_meta = {
	__type = 'user',
    __index = user,
	__tostring = function(self)
		return objects_cache[self].address
	end,
}

function user:get_id()
	return objects_cache[self].id
end

return setmetatable(user, {
	__call = function(self, id)
		if type(id) ~= 'number' or id == 0 then
			return objects
		end
		
		if not objects[id] then
			local obj = {}
			
			objects_cache[obj] = {
                id = id,
                address = 'user{'..id..'}: '..string_sub(tostring(obj), 8),
            }

			objects[id] = setmetatable(obj, objects_meta)
		end
		
		return objects[id]
	end,
})