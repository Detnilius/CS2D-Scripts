local include = assert(loadfile('scripts/core/include.lua'))('-I')
include.path('scripts/?.lua', 'scripts/?/main.lua', 'scripts/core/?.lua', 'scripts/core/modules/?.lua')
include('main')