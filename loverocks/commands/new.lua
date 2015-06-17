local log = require 'loverocks.log'
local config = require 'loverocks.config'
local template = require 'loverocks.template'
local util = require 'loverocks.util'

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

function is_valid_name(s) -- TODO
	return true
end

function new:run(args)
	local env = template.new_env(args.project, args.love_version)
	if not is_valid_name(args.project) then
		log:error("Invalid project name: %q", args.project)
	end

	local path = log:assert(template.path(args.template))

	log:info("Using template %q", path)
	local files = assert(util.slurp(path))
	files = template.apply(files, env)

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

	assert(util.spit(files, env.project_name))
	log:info("New LOVERocks project installed at %q", env.project_name .. "/")
end

return new
