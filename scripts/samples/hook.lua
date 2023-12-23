local hook = require 'scripts.core.module.hook'

-- Example 1
join_hook = hook('join', function(id)
	msg(player(id, 'name')..' joined!@C')
end)

-- Example 2
say_hook = hook.add('say')
say_hook.func = function(id, txt)
	if (txt == '!hi') then
		if join_hook.destroy then
			msg('destroying "join" hook!')
			join_hook:destroy()
		else
			msg('already dead')
		end
		return 1
	end
	
	msg(player(id,'name')..': '..txt)
	
	return 1
end

-- Example 3
hook.add('say', function(id, txt)
	if (txt == '!help') then
		msg('This is help command!')
		return 1
	end
end, -100)

-- Custom hook
local plrs = (function()
	local t = {}
	for i = 1, 32 do
		t[i] = {oldMouseX = 0, oldMouseY = 0}
	end
	
	return t
end)()

freetimer('hookUpdate')
timer(0, 'hookUpdate', _, 0)
function hookUpdate()
	if _callhook.movemouse then
		for _, id in next, player(0, 'tableliving') do
			local mouseX, mouseY = player(id, 'mousex'), player(id, 'mousey')
			local oldMX, oldMY = plrs[id].oldMouseX, plrs[id].oldMouseY
			
			if (mouseX ~= oldMX or mouseY ~= oldMY) then
				_callhook.movemouse(id)
			end
			
			plrs[id].oldMouseX, plrs[id].oldMouseY = mouseX, mouseY
		end
	end
end

hook.add('movemouse', function(id)
	msg('player: '..id..' Move mouse')
end, true)
--
