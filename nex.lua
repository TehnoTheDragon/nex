--# Settings
local CREATE_DESTROY_METHOD = true

--# Private Fields
local _OPERATORS = {
	{"add", "__add"},
	{"sub", "__sub"},
	{"mul", "__mul"},
	{"div", "__div"},
	{"mod", "__mod"},
	{"pow", "__pow"},
	{"neg", "__unm"},
	
	{"equal", "__eq"},
	{"lessThan", "__lt"},
	{"lessEqual", "__le"},
	{"garbage", "__gc"},
	
	{"concat", "__concat"},
	{"len", "__len"},
	{"call", "__call"},
	{"mode", "__mode"},

	{"init", "__init"},
}

--# Private Methods
local function fvalue(value)
	return function()
		return value
	end
end

local function cif(content, name, ...)
	local fn = content[name]
	if fn then
		return fn(...)
	end
	return nil
end

local function rif(flag, value)
	return flag and value or nil
end

local function relse(flag, a, b)
	return flag and a or b
end

local function copyTo(from, to, respectTo)
	for K,B in pairs(from) do
		local A = to[K]
		to[K] = relse(respectTo and (A ~= nil), A, B)
	end
end

local function mfield(content, field)
	return getmetatable(content)[field]
end

local function mmwrapper(t)
	return function(metamethod, value)
		if value ~= nil then
			t[metamethod] = value
		end
	end
end

local function toargn(...)
	local argv = {}
	for i,v in {...} do
		local t = typeof(v)
		if t == "table" then
			local classname = mfield(v, "__name")
			table.insert(argv, classname ~= "table" and classname or t)
		else
			table.insert(argv, t)
		end
	end
	return table.concat(argv, ",")
end

local function getopcontainer(class, metamethod)
	local container = class["op"..metamethod]
	if not container then
		container = {}
		class["op"..metamethod] = container
	end
	return container
end

local function create_op(operator, class, op, metamethod)
	local container = getopcontainer(class, metamethod)
	operator[op] = function(fn, ...)
		container[table.concat({...}, ",")] = fn
	end
	class[metamethod] = function(self, ...)
		local argn = toargn(...)
		local fn = container[argn]
		if fn then
			local result = fn(self, ...)
			return result or self
		end
		error(string.format("No operator '%s (%s)' overloaded for arguments: %s", op, metamethod, argn))
	end
end

--# Tools
local function _cast_class(object, class)
	local instance = class()
	copyTo(object, instance, false)
	instance.cast = function(self, class)
		if self == nil or class == nil then
			return copyTo(instance, object, false)
		else
			return instance:cast(class)
		end
	end
	return instance
end

--# Object
local function _create_object_metatable(object, class)
	local objectMetatable = {}
	objectMetatable.__name = mfield(class, "__name")
	
	local metamethod = mmwrapper(objectMetatable)
	
	metamethod("__index", function(self, key)
		return rawget(self, key) or rawget(class, key)
	end)
	metamethod("__tostring", class.__tostring or mfield(class, "__tostring"))
	metamethod("__mode", class.__mode)
	metamethod("__call", class.__call)
	metamethod("__len", class.__len)
	metamethod("__concat", class.__concat)
	metamethod("__unm", class.__unm)
	metamethod("__add", class.__add)
	metamethod("__sub", class.__sub)
	metamethod("__mul", class.__mul)
	metamethod("__div", class.__div)
	metamethod("__mod", class.__mod)
	metamethod("__pow", class.__pow)
	metamethod("__eq", class.__eq)
	metamethod("__lt", class.__lt)
	metamethod("__le", class.__le)
	metamethod("__gc", class.__gc)
	return objectMetatable
end

local function _create_object(class, ...)
	local object = setmetatable({}, _create_object_metatable({}, class))
	cif(class, "init", object, ...)
	cif(getopcontainer(class, "__init"), toargn(...), object, ...)
	
	object.destroy = rif(CREATE_DESTROY_METHOD, function()
		cif(class, "deinit", object)
	end)
	
	object.cast = function(self, class)
		return _cast_class(self, class)
	end
	
	object.instanceOf = function(self, class)
		return mfield(self, "__name") == mfield(class, "__name")
	end
	
	object.classname = mfield(class, "__name")
	
	return object
end

--# Operator
local function _create_operator(class)
	local operator = {}
	for _, op in _OPERATORS do
		create_op(operator, class, op[1], op[2])
	end
	return setmetatable({}, {__index = operator})
end

--# Super
local function _create_super_metatable(inheritancesCache)
	local superMetatable = {}
	superMetatable.__newindex = function()
		error("Cannot assign value")
	end
	superMetatable.__index = function(self, key)
		return inheritancesCache[key]
	end
	superMetatable.__call = function(_, self, inheritanceName, ...)
		return inheritancesCache[inheritanceName].init(self, ...)
	end
	return superMetatable
end

local function _create_super(inheritancesCache)
	return setmetatable({}, _create_super_metatable(inheritancesCache))
end

--# Class
local function _create_class_metatable(class, inheritance, name)
	local classMetatable = {}
	classMetatable.__index = function(self, key)
		return rawget(self, key) or rawget(getmetatable(self), key)
	end
	classMetatable.__tostring = fvalue(name)
	classMetatable.__call = _create_object
	classMetatable.__name = name
	return classMetatable
end

local function _create_class(name)
	return function(inheritances)
		local inheritancesCache = {}
		
		local class = {}
		
		for i,v in inheritances do
			copyTo(v, class, true)
			inheritancesCache[mfield(v, "__tostring")()] = v
		end
		
		class.super = _create_super(inheritancesCache)
		class.operator = _create_operator(class)
		
		function class:finalize()
			class.super = nil
			class.operator = nil
			return self
		end
		
		return setmetatable(class, _create_class_metatable(class, inheritances, name))
	end
end

--# Final
return _create_class