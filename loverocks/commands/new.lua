local log = require 'loverocks.log'
local template = require 'loverocks.template'
local util = require 'loverocks.util'
local love_versions = require 'loverocks.love-versions'

local new = {}

function new.build(parser)
	parser:description "Make a new love project"

	parser:option "-t" "--template"
		:description "The template to follow."
		:default "love"

	parser:option "--love-version"
		:description "The lua version. If unspecified we guess by running `love --version`"

	parser:argument "project"
		:args(1)
		:description "the name of the project"
end

function new.run(_, args)
	local versions = love_versions.get(args.love_version)
	local env = template.new_env(versions, args.project)

	log:info("Using template %q", args.template)
	local files = require("loverocks.templates." .. args.template)
	files = template.apply(files, env)

	local f = io.open(env.project_name)
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
