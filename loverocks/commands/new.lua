local etlua = require 'etlua'

local util = require 'loverocks.util'
local versions = require 'loverocks.versions'
local log = require 'loverocks.log'
local config = require 'loverocks.config'

local new = {}

function new:build(parser)
	parser:description "Make a new love project"

	parser:option "-t" "--template"
		:description "The template to follow."
		:default "love9"
	parser:option "--love-version"
		:description "The lua version. If unspecified we guess by running `love --version`"

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
			local d, err = etlua.render(file, env)
			if not d then
				log:error(name .. ": " .. err)
			end
			files[new_name] = d
			if new_name ~= name then
				files[name] = nil
			end
		end
	end
end

local function template_path(name)
	local override = config("loverocks_templates")
	if override then
		override = override .. "/" .. name
		local f, err = io.open(override)
		if f then
			return override
		end
	end

	return util.dpath("templates/" .. name)
end

function new:run(args)
	local env = new_env(args.project, args.love_version)
	if not is_valid_name(args.project) then
		log:error("Invalid project name: %q", args.project)
	end

	local path, err = template_path(args.template)
	if not path then log:error(err) end

	log:info("Using template %q", args.template)
	local files, err = util.slurp(path)
	if not files then log:error(err) end
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
