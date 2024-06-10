--utils
function letab(t, f)
	print('------------------------------------------------------')
	for i, k in next, t do
		if f then
			i = tostring(i) .. ' (' .. type(i) .. ')'
			k = tostring(k) .. ' (' .. type(k) .. ')'
		end
		
		print(i, k)
	end
	print('------------------------------------------------------')
end

print(os.clock(), 'Modules System...', (...))
--

include = (...)
include.debug('include')

hook = include 'hook'
hook.add('join', function(uid) msg(player(uid, 'name')..' joined') end)
