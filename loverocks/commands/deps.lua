local log = require 'loverocks.log'
local api = require 'loverocks.api'
local loadconf = require 'loadconf'

local deps = {}

function deps.build(parser)
	parser:description
		"Installs all packages listed as dependencies in your conf.lua file."
	parser:option "-s" "--server"
		:description
			"Fetch rocks/rockspecs from this server as a priority."
	parser:option "--only-server"
		:description
			"Fetch rocks/rockspecs from this server, ignoring other servers."
end

function deps.run(args)
	local conf = log:assert(loadconf.parse_file("./conf.lua"))
	if not conf.dependencies then
		log:error("please add a dependency table to your conf.lua FIXME: better error")
	end

	local name = conf.identity or "LOVE_GAME"
	assert(type(name) == 'string')

	local flags = {
		tree = conf.rocks_tree,
		from = args.server,
		only_from = args.only_server
	}

	log:fs("luarocks install <> --only-deps")
	log:assert(api.in_luarocks(flags, function()
		local lr_deps = require 'luarocks.deps'

		local parsed_deps = {}
		for _, s in ipairs(conf.dependencies) do
			table.insert(parsed_deps, lr_deps.parse_dep(s))
		end

		return lr_deps.fulfill_dependencies({
			name = name,
			version = "",
			dependencies = parsed_deps
		}, "one")
	end))

	print("Dependencies installed succesfully!")
end

return deps
