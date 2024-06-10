local ipairs, menu, next, player, setmetatable, type, unpack
	= ipairs, menu, next, player, setmetatable, type, unpack

local table_insert
	= table.insert

local include = (...)

local base = include 'libs.base'
local hook = include 'hook'
local user = include 'user'

local M = setmetatable({menus = {}}, {
	__call = function(self, ...)
		local func = self.open
		
		if type(arg[1]) == 'number' then
			local uid = arg[1]
			user(uid).menu = nil

			if not player(uid, 'exists') then
				return
			end

			func = menu
		end

		func(unpack(arg))
	end,
})

function M.open(data, uid)
	uid = uid or 0

	if uid == 0 then
		for _, uid in next, player(0, 'table') do
			M.open(data, uid)
		end

		return
	end

	local content = (data.title or '')..','

	for buttonid = 1, 9 do
		local button = data[buttonid]
		local button_name = ''

		if type(button) == 'table' and type(button[1]) == 'string' then
			button_name = button[1]
		end

		content = content..button_name..','
	end

	user(uid).menu = data
	menu(uid, 'UTF-8:'..base.string_to_hex(content))
end

hook.add('menu', function(uid, title, buttonid)
	local data = user(uid).menu

	if type(data) == 'table' then
		buttonid = buttonid == 0 and 10 or buttonid

		local button = data[buttonid]

		if type(button) == 'table' and type(button[2]) == 'function' then
			local arg = {}

			if button.kyc ~= false then
				table_insert(arg, uid)
			end

			if button.context == true then
				table_insert(arg, {data = data, button = button})
			end

			if type(button.arg) == 'table' then
				for _, v in ipairs(button.arg) do
					table_insert(arg, v)
				end
			end

			button[2](unpack(arg))
		end
	end
end)

return M