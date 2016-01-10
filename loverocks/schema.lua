--- Simple dynamic type/schema checker
local schema = {}

local primitives = {
   ['nil'] = true,
   number = true,
   string = true,
   boolean = true,
   table = true,
   ['function'] = true,
   thread = true,
   userdata = true,
   cdata = true, -- luajit only
}

local function primitive_check(o, t)
   assert(primitives[t], string.format("type %q is not a primitive", t))

   if type(o) == t then
      return true
   else
      return nil, "object is not of type " .. tostring(t)
   end
end

local function predicate_check(o, f)
   local ok, err = f(o)
   if ok then
      return true
   end
   return nil, "predicate: " .. tostring(err)
end

local function compound_check(o, c)
   if type(o) ~= 'table' then
      return nil, "object is not a table"
   end

   for key, s in pairs(c) do
      local ok, err = schema.check(o[key], s)
      if not ok then
         return nil, tostring(key) .. ": " .. err
      end
   end

   return true
end

--- Returns an homogenous array predicate. An object will typecheck if all of
--  its array indices match the input type
function schema.all(t)
   return function(o)
      local ok, err
      ok, err = primitive_check(o, 'table')
      if not ok then return ok, err end

      for i, v in ipairs(o) do
         ok, err = schema.check(v, t)
         if not ok then
            return ok, string.format("array index [%s]: %s", tostring(i), tostring(err))
         end
      end

      return true
   end
end

--- Returns a sum type predicate. An object will typecheck if it also
--  typechecks against at least one of the inputs
function schema.sum(...)
   local types = {...}

   return function(o)
      for _, t in ipairs(types) do
         if schema.check(o, t) then
            return true
         end
      end

      return nil, "object not in sum type"
   end
end

--- Returns an optional type predicate. Shortcut for s or nil
function schema.maybe(s)
   return schema.sum('nil', s)
end

--- Returns an enum predicate. An object will typecheck if it is 
--  the same as at least one of the inputs, ie. rawequal()
function schema.enum(...)
   local set = {}
   for i=1, select('#', ...) do
      set[select(i, ...)] = true -- FIXME: set can't store nil
   end

   return function(o)
      if set[o] then
         return true
      end
      return nil, "object not in enum"
   end
end

--- Returns a match predicate. An object will typecheck if it's a string for
--  which string:match(input) is true
function schema.match(input)
   return function(o)
      if type(o) == 'string' and string.match(o, input) then
         return true
      end

      return nil, string.format("object did not match against %q", input)
   end
end

--- behaves "like" a function, ie. supports call() syntax
function schema.fn(f)
   if type(f) == 'function' then
      return true
   end

   local mt = getmetatable(f)
   if mt and mt.__call ~= nil then
      return true
   end

   return nil, "object is not callable"
end

--- Is an integer number, ie. has no fractional part
function schema.int(i)
   if type(i) == 'number' and math.floor(i) == i then
      return true
   end

   return nil, "object is not an integer"
end

--- Is a natural number, ie. a positive integer
function schema.natural(i)
   if schema.int(i) and i >= 0  then
      return true
   end

   return nil, "object is not a natural number"
end

--- Is a valid array index, ie. an integer from 1 and up
function schema.index(i)
   if schema.int(i) and i > 0 then
      return true
   end

   return nil, "object is not a valid index"
end

function schema.check(o, s)
   if type(s) == 'string' then
      return primitive_check(o, s)
   elseif schema.fn(s) then
      return predicate_check(o, s)
   elseif type(s) == 'table' then
      return compound_check(o, s)
   end
end

function schema.assert(o, s)
   local ok, err = schema.check(o, s)

   if not ok then
      error(err, 2)
   end
end

-- repeated so that error depth doesn't need to change
local function mt_call(_, o, s)
   local ok, err = schema.check(o, s)

   if not ok then
      error(err, 2)
   end
end

return setmetatable(schema, {__call = mt_call})
