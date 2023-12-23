local _VERSION = 'timer: 0.1'

local os_clock
	= os.clock

local string_sub
	= string.sub

local table_insert
	= table.insert

local error, freetimer, next, pcall, setmetatable, timer, tostring, type, unpack
	= error, freetimer, next, pcall, setmetatable, timer, tostring, type, unpack

local GLOBAL_VARNAME = '_calltimer'

local objList = {}
local objMethods = {
    destroy = function(self)
		objList[self] = nil
		for k in next, self do
			self[k] = nil
		end
		setmetatable(self, nil)
	end,
}
local objMeta = {
	__type = 'timer',
	__index = objMethods,
	__tostring = function(self)
		return self._address
	end,
}

local M = {_VERSION = _VERSION}
local MMeta = {
	__type = 'module',
	__call = function(self, ...)
		return type(arg[2]) ~= 'string' and self.add(unpack(arg)) or timer(unpack(arg))
	end,
	__tostring = function()
		return _VERSION
	end,
}

local function TIMER_UPDATE()
	for obj in next, objList do
		if (obj.func and obj.state > 0) then
			if (os_clock() >= obj._tm + obj.interval / 1000) then
				
				obj.iteration = obj.iteration + 1
				local success, result = pcall(obj.func, unpack(obj.arg))
				obj._tm = os_clock()
				
				if (obj.counter and obj.counter > 0) then
					if (obj.counter == 1) then
						obj.state = 0
						if obj.autodestroy then
							obj:destroy()
						end
					else
						obj.counter = obj.counter - 1
					end
				end
				
				if not success then
					error(result, 0)
				end
			end
		else
			obj._tm = os_clock()
		end
	end 
end

function M.add(ms, func, count, ...)
    ms, count = ms or 100, count or 1
	
	if (_G[GLOBAL_VARNAME] ~= TIMER_UPDATE) then
		_G[GLOBAL_VARNAME] = TIMER_UPDATE
		freetimer(GLOBAL_VARNAME)
		timer(0, GLOBAL_VARNAME, nil, 0)
	end

    local obj = {
        _tm = os_clock(),

		interval = ms,
		func = func,
		counter = count,
			
		state = 1,
		iteration = 0,
		autodestroy = true,
		
		arg = {...},
    }

    obj._address = 'timer: ' .. string_sub(tostring(obj), 8)
    objList[obj] = obj

    -- Добавялем в последний аругмент сам таймер, для взаимодествия с ним в функции
	table_insert(obj.arg, obj)

    return setmetatable(obj, objMeta)
end

return setmetatable(M, MMeta)