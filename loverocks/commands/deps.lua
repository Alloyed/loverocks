local log = require 'loverocks.log'
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

	log:assert(api.deps(conf.identity or "LOVE_GAME", conf.dependencies, {
		from = args.server,
		only_from = args.only_server
	}))

	print("Dependencies installed succesfully!")
end

return deps
