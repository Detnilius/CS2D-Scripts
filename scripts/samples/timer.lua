local timer = require 'scripts.core.module.timer'

-- [[
---- In function, function
-- Example 1
timer(100, function()
	msg('Hello World!')
end)

-- Example 2
timer(200, function(txt, objTimer)
	msg(txt:format(objTimer.iteration))
end, 5, 'Hi (%d Times)')

-- Example 3
timer(100+200*5+500, function(objTimer)
	msg('This is infinity cycle')
	objTimer.interval = 500
	if objTimer.iteration > 10 then -- Stop the timer if iteration > 10
		objTimer:destroy()
		msg('Break the cycle')
	end
end, 0)
----]]

-- [[ Out function
local function test(txt) -- Function for 'Example 1'
	msg(txt)
end


local function leobj(txt, objTimer) -- Function for 'Example 2'
	msg(txt)
	
	print(objTimer)
	for i, k in next, objTimer do
		msg(tostring(i)..' = '..tostring(k))
	end
end

-- Example 1
timer(100, test, 5, 'Hi (5 Times)')
-- Example 2
timer(1000, leobj, 1, 'Hello World (1 Times)')
----]]

-- [[ Object orientier
-- Example 1
local obj1 = timer()
obj1.counter = 5
obj1.interval = 1000
obj1.arg = {'Hello', 'World!'}
obj1.func = function(arg1, arg2)
	msg(arg1..' '..arg2)
end

-- Example 2
local obj2 = timer()
obj2.interval = 500
obj2.counter = 5
obj2.arg = {'Hello', 'World!', obj2}
obj2.func = function(arg1, arg2, timerObj)
	msg(arg1..' '..arg2 .. ' (Left: '..timerObj.counter-1 ..')')
end
----]]
