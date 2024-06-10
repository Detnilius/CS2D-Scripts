local error, getmetatable, ipairs, msg2, parse, print, tonumber, tostring, type
	= error, getmetatable, ipairs, msg2, parse, print, tonumber, tostring, type

local debug_getinfo
	= debug.getinfo

local string_byte, string_char, string_format, string_gmatch, string_gsub, string_lower
	= string.byte, string.char, string.format, string.gmatch, string.gsub, string.lower

local table_concat
	= table.concat

local base = {}

function base.type(var)
	local var_type = type(var)

	if var_type == 'table' then
		local var_meta = getmetatable(var)

		if type(var_meta) == 'table' and var_meta.__type then
			return var_meta.__type
		end
	end

	return var_type
end

function base.type_error(...)
	local arg_n = arg.n
	
    if arg_n == 0 or arg_n % 2 == 1 then
		error('invalid number of arguments', 2)
	end

    for i = 1, arg_n, 2 do
        local var_type = base.type(arg[i])
		local exp_type = arg[i + 1]

        if type(exp_type) ~= 'string' then
			error('invalid type of argument validation (string expected)', 2)
		end

        local is_valid
		
		for type in string_gmatch(exp_type, '([^,%s]+)') do
			type = string_lower(type)
			if var_type == type or (type == 'value' and var_type ~= 'nil') then
				is_valid = true
				break
			end
		end

        if not is_valid then
			local func_name = debug_getinfo(2, 'n').name or debug_getinfo(1, 'n').name
			error(string_format("bad argument #%d to '%s' (%s expected, got %s)", (i/2 + 1), func_name, exp_type, var_type), 3)
		end
    end
end

function base.string_to_hex(str)
	local num_codes = {string_byte(str, 1, -1)}

	for i, num_code in ipairs(num_codes) do
        num_codes[i] = string_format('x%02X', num_code)
    end

	return table_concat(num_codes)
end

function base.hex_to_string(str)
	str = string_gsub(str, 'x(%x%x?)', function(hex)
		return string_char(tonumber(hex, 16))
	end)

    return str
end

function base.print(...)
	local str = ''

	for _, v in ipairs(arg) do
		str = str..tostring(v)..'\t'
	end

	print('UTF-8:'..base.string_to_hex(str))
end

function base.msg(txt, uid)
	uid = uid or 0
	msg2(uid, 'UTF-8:'..base.string_to_hex(txt or ''))
end

function base.parse(cmds, stop_semicolon)
	parse('UTF-8:'..base.string_to_hex(cmds or ''), stop_semicolon)
end

return base