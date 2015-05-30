local etlua = require 'etlua'
local datafile = require 'datafile'
local util = require 'loverocks.util'
local new = {}

function new:build(parser)
	parser:description "Make a new love project"

	-- parser:argument "template"
	-- 	:args("?")
	-- 	:description "the template to follow."

	parser:argument "project"
		:args(1)
		:description "the name of the project"
end

local function raw_version(s)
	return string.format("%q", s:gsub("-1$", ""))
end

local function depstring(s)
	return ("\"love ~> %s\""):format(s:match("%d+.%d+"))
end

default_env = {
	project_name = "oops",
	versions = {
		love       = "0.9.1-1",
		luasocket  = "2.0.2-5",
		enet       = "1.2-1",
		utf8       = "0.1.0-1"
	},
	raw_version = raw_version,
	depstring = depstring,
}

function is_valid_name(s)
	return true -- TODO
end

table.copy = table.copy or function(tbl)
	local t = {}
	for k, v in pairs(tbl) do
		t[k] = v
	end
	return t
end

local function apply_templates(files, env)
	for name, file in pairs(files) do
		if type(file) == 'table' then 
			apply_templates(file, env)
		else
			local new_name = name:gsub("PROJECT", env.project_name)
			files[new_name] = etlua.render(file, env)
			if new_name ~= name then
				files[name] = nil
			end
		end
	end
end

function new:run(args)
	local env = table.copy(default_env)
	env.project_name = args.project
	assert(is_valid_name(env.project_name),
		("Invalid project name: %q"):format(args.project))

	local template = "love9"
	local tpath = "templates/" .. template
	
	print(("Using template %q"):format(template))
	-- for some reason datafile.path doesn't work
	local tmpfile, path = datafile.open(tpath)
	assert(path, "Template not found")
	if tmpfile and tmpfile.close then tmpfile:close() tmpfile = nil end

	print(path)

	local files = util.slurp(path)
	apply_templates(files, env)
	util.spit(files, env.project_name)
	print("Done!")
end

return new
