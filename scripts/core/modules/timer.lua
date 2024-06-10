local error, freetimer, next, pcall, setmetatable, timer, tostring, type, unpack
	= error, freetimer, next, pcall, setmetatable, timer, tostring, type, unpack

local os_clock
	= os.clock

local string_sub
	= string.sub

local table_insert
	= table.insert

local GLOBAL_VARNAME = '_calltimer'

local M = setmetatable({}, {
	__call = function(self, ...)
		local func = self.add
		
		if type(arg[2]) == 'string' then
			func = timer
		end

		return func(unpack(arg))
	end,
})

local objects = {}
local objects_meta = {
	__type = 'timer',
	__index = M,
	__tostring = function(self)
		return objects[self].address
	end,
}

local function TIMER_UPDATE()
	for obj in next, objects do
		if obj.func and obj.state > 0 then
			if os_clock() >= obj._tm + obj.interval*0.001 then

				obj.iteration = obj.iteration + 1
				local status, result = pcall(obj.func, unpack(obj.arg))
				obj._tm = os_clock()

				if obj.counter and obj.counter > 0 then
					if obj.counter == 1 then
						obj.state = 0
						if obj.autodestroy then
							obj:destroy()
						end
					else
						obj.counter = obj.counter - 1
					end
				end

				if not status then
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

	if _G[GLOBAL_VARNAME] ~= TIMER_UPDATE then
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

	objects[obj] = {address = 'timer: '..string_sub(tostring(obj), 8)}
	setmetatable(obj, objects_meta)

	-- Add timer itself to last argument to interact with it in function
	table_insert(obj.arg, obj)

	return obj
end

function M:destroy()
	objects[self] = nil
	for k in next, self do
		self[k] = nil
	end
	setmetatable(self, nil)
end

return M