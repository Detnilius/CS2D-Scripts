local assert, getmetatable, setmetatable, type
	= assert, getmetatable, setmetatable, type

local math_sqrt
	= math.sqrt

local vector = {}
local vector_meta = {
	__type = 'class',
}

local objects_meta = {
	__type = 'vector',
	__index = vector,
}

local function is_vector(v)
	return getmetatable(v) == objects_meta
end

local function new(x, y)
	return setmetatable({x = x or 0, y = y or 0}, objects_meta)
end

function vector_meta.__call(self, ...)
	return new(...)
end

function objects_meta.__add(a, b) -- (+)
	assert(is_vector(a) and is_vector(b), 'add: bad argument types (vector expected)')
	return new(a.x + b.x, a.y + b.y)
end

function objects_meta.__mul(a, b) -- (*)
	if type(a) == 'number' then 
		return new(a * b.x, a * b.y)
	elseif type(b) == 'number' then
		return new(a.x * b, a.y * b)
	else
		assert(is_vector(a) and is_vector(b), 'mul: bad argument types (vector, number expected)')
		return new(a.x * b.x, a.y * b.y)
	end
end

function objects_meta.__sub(a, b) -- (-)
	assert(is_vector(a) and is_vector(b), 'sub: bad argument types (vector expected)')
	return new(a.x - b.x, a.y - b.y)
end

function objects_meta.__div(a, b) -- (/)
	assert(is_vector(a) and type(b) == 'number', 'div: bad argument types (vector by number expected)')
	return new(a.x / b, a.y / b)
end

function objects_meta.__unm(a) -- (--)
	return new(-a.x, -a.y)
end

function objects_meta.__eq(a, b) --	(==)
	return a.x == b.x and a.y == b.y
end

function objects_meta.__tostring(a) -- ("")
	return 'vector{'..a.x..', '..a.y..'}'
end

function vector:set(x, y)
	assert(type(x) == 'number' and type(y) == 'number', 'set: bad argument types (number expected)')
	self.x, self.y = x, y
	return self
end

function vector:replace(a)
	assert(is_vector(a), 'replace: bad argument type (vector expected)')
	self.x, self.y = a.x, a.y
	return self
end

function vector:dist(a)
	assert(is_vector(a), 'dist: bad argument type (vector expected)')
	local vx, vy = a.x - self.x, a.y - self.y
	return math_sqrt(vx*vx + vy*vy)
end

function vector:len()
	return math_sqrt(self.x*self.x + self.y*self.y)
end

function vector:norm()
	local len = self:len()
	
	if len ~= 0 then
		self:replace(self/len)
	end
	
	return self
end

function vector:unpack()
	return self.x, self.y
end

vector.new = new
vector.is_vector = is_vector

return setmetatable(vector, vector_meta)