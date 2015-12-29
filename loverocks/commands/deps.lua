local log = require 'loverocks.log'
local luarocks = require 'luarocks.deps'
local api = require 'loverocks.api'
local loadconf = require 'loadconf'

local deps = {}

function deps:build(parser)
	parser:description
		"Installs all packages listed as dependencies in your conf.lua file."
	parser:option "-s" "--server"
		:description
			"Fetch rocks/rockspecs from this server as a priority."
	parser:option "--only-server"
		:description
			"Fetch rocks/rockspecs from this server, ignoring other servers."
end

function deps:run(args)
	local conf = log:assert(loadconf.parse_file("./conf.lua"))
	if not conf.dependencies then
		log:error("please add a dependency table to your conf.lua FIXME: better error")
	end

	local name = conf.identity or "LOVE_GAME"
	assert(type(name) == 'string')
	local parsed_deps = {}
	for _, s in ipairs(conf.dependencies) do
		table.insert(parsed_deps, luarocks.parse_dep(s))
	end
	local flags = { from = args.server, only_from = args.only_server }

	api.check_flags(flags)

	log:assert(luarocks.fulfill_dependencies({
		name = name,
		version = "",
		dependencies = parsed_deps
	}, "one"))

	api.restore_flags(flags)

	print("Dependencies installed succesfully!")
end

return deps
