#!/usr/bin/env lua

--- Takes each template and makes a slurp-compatible lua file from it
--  so we can avoid wierd datafile resolving issues
local templates = { "love" }
local util = require 'loverocks.util'
local ser = require 'ser'

for _, t_name in ipairs(templates) do
   local s = ser(util.slurp("templates/" .. t_name))
   local fname = "loverocks/templates/"..t_name..".lua"
   io.stderr:write("generating " .. fname .. "\n")
   local f = assert(io.open(fname, 'w'))
   f:write("-- This is automatically generated using")
   f:write("\n-- templates/compile_templates.lua on "..os.date())
   f:write("\n-- luacheck: push ignore\n")
   f:write(s)
   f:write("\n-- luacheck: pop\n")
   f:close()
end
