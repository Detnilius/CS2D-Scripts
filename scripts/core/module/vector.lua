local _VERSION = 'vector: 0.1'

local assert, error, getmetatable, setmetatable, type
	= assert, error, getmetatable, setmetatable, type

local math_sqrt
	= math.sqrt

local M = {_VERSION = _VERSION}
local MMeta = {
	__type = 'module',
	__call = function(self, ...)
		return self.new(...)
	end,
	__tostring = function()
		return _VERSION
	end,
}

local objMethods = {}
local objMeta = {
	__type = 'vector',
	__index = objMethods,
}

local function isObj(v)
	return getmetatable(v) == objMeta
end

local function new(x, y)
	return setmetatable({x = x or 0,y = y or 0}, objMeta)
end

function objMethods:set(x, y)
	assert(type(x) == 'number' and type(y) == 'number', 'set: bad argument types (number expected)')
	self.x, self.y = x, y
	return self
end

function objMethods:replace(a)
	assert(isObj(a), 'replace: bad argument type (vector expected)')
	self.x, self.y = a.x, a.y
	return self
end

function objMethods:dist(a)
	assert(isObj(a), 'dist: bad argument type (vector expected)')
	local vx, vy = a.x - self.x, a.y - self.y
	return math_sqrt(vx*vx + vy*vy)
end

function objMethods:len()
	return math_sqrt(self.x*self.x + self.y*self.y)
end

function objMethods:norm()
	local l = self:len()
	
	if (l ~= 0) then
		self:replace(self/l)
	end
	
	return self
end

function objMethods:unpack()
	return self.x, self.y
end

function objMeta.__add(a, b) -- (+)
	assert(isObj(a) and isObj(b), 'add: bad argument types (vector expected)')
	return new(a.x + b.x, a.y + b.y)
end

function objMeta.__mul(a, b) -- (*)
	if (type(a) == 'number') then 
		return new(a * b.x, a * b.y)
	elseif (type(b) == 'number') then
		return new(a.x * b, a.y * b)
	else
		assert(isObj(a) and isObj(b), 'mul: bad argument types (vector, number expected)')
		return new(a.x * b.x, a.y * b.y)
	end
end

function objMeta.__sub(a, b) -- (-)
	assert(isObj(a) and isObj(b), 'sub: bad argument types (vector expected)')
	return new(a.x - b.x, a.y - b.y)
end

function objMeta.__div(a, b) -- (/)
	assert(type(b) == 'number' and isObj(a), 'div: bad argument types (vector by number expected)')
	return new(a.x / b, a.y / b)
end

function objMeta.__unm(a) -- 	(--)
	return new(-a.x, -a.y)
end

function objMeta.__eq(a, b) --	(==)
	return a.x == b.x and a.y == b.y
end

function objMeta.__tostring(a) -- ("")
	return 'vector{'..a.x..', '..a.y..'}'
end

M.new = new

return setmetatable(M, MMeta)