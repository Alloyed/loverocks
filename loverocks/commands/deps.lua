local log      = require 'loverocks.log'
local luarocks = require 'loverocks.luarocks'

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

function deps.run(conf, args)
	if conf._loverocks_no_config then
		log:error("conf.lua error: %s", conf._loverocks_no_config)
	end
	if not conf.dependencies then
		log:error("please add a dependency table to your conf.lua FIXME: better error")
	end

	local name = conf.identity or "LOVE_GAME"
	assert(type(name) == 'string')

	local flags = luarocks.make_flags(conf)
	flags.init_rocks = true

	if args.server then
		table.insert(flags.from, 1, args.server)
	end
	if args.only_server then
		flags.only_from = args.only_server
	end

	log:fs("luarocks install <> --only-deps")
	log:assert(luarocks.sandbox(flags, function()
		local lr_rockspecs = require 'luarocks.rockspecs'
		local lr_deps = require 'luarocks.deps'

		local NO_GLOBALS = nil
		local SKIP_VALIDATION = true
		local rockspec = assert(lr_rockspecs.from_persisted_table("", {
			package = name,
			version = "love-0",
			source = {url=""},
			dependencies = conf.dependencies,
		}, NO_GLOBALS, SKIP_VALIDATION))

		--error(require'inspect'(rockspec))
		return lr_deps.fulfill_dependencies(rockspec, "dependencies", "one")
	end))

	log:info("Dependencies installed succesfully!")
end

return deps
