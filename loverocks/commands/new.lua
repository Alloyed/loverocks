local etlua = require 'etlua'
local datafile = require 'datafile'

local util = require 'loverocks.util'
local versions = require 'loverocks.versions'
local log = require 'loverocks.log'

local new = {}

function new:build(parser)
	parser:description "Make a new love project"

	parser:option "-t" "--template"
	 	:description "The template to follow."
		:default "love9"
	parser:option "--love-version"
		:description "The lua version. If unspecified we guess from running `love --version`"

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

local function new_env(name, v)
	return {
		project_name = name,
		versions = versions.get(v),
		raw_version = raw_version,
		depstring = depstring,
	}
end

function is_valid_name(s) -- TODO
	return true
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
	local env = new_env(args.project, args.love_version)
	if not is_valid_name(args.project) then
		log:error("Invalid project name: %q", args.project)
	end

	local tpath = "templates/" .. args.template
	
	-- for some reason datafile.path doesn't work
	local tmpfile, path = datafile.open(tpath)
	if not tmpfile then
		log:error(path)
	end
	if tmpfile and tmpfile.close then tmpfile:close() tmpfile = nil end

	log:info("Using template %q", args.template)
	local files = util.slurp(path)
	apply_templates(files, env)

	local f, err = io.open(env.project_name)
	if f then
		local should_overwrite = log:ask(
			"Directory %q already exists! overwrite (Y/n)?",
			env.project_name) ('n')

		if not should_overwrite then
			log:info("Aborting.")
			os.exit(0)
		end
		f:close()
	end

	util.spit(files, env.project_name)
	log:info("New LOVERocks project installed at %q", env.project_name .. "/")
end

return new
