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
		flags["only-from"] = args.only_server
	end

	log:fs("luarocks install <> --only-deps")
	log:assert(luarocks.sandbox(flags, function()
		local lr_deps = require 'luarocks.deps'
		local lr_queries = require 'luarocks.queries'
		local lr_cfg = require 'luarocks.core.cfg'

		local dependencies = {}
		for i, depstring in ipairs(conf.dependencies) do
			local parsed, err = lr_queries.from_dep_string(depstring)
			if not parsed then
				local errorstring = string.format("Parse error processing dependency %q: %s", depstring, err)
				return nil, errorstring
			end
			dependencies[i] = parsed
		end

		local version = ""
		local deps_mode = "one"
		local rocks_provided = lr_cfg.rocks_provided
		lr_deps.report_missing_dependencies(name, version, dependencies, deps_mode, rocks_provided)

		for _, dep in ipairs(dependencies) do
			local ok, err = lr_deps.fulfill_dependency(dep, deps_mode, name, version, rocks_provided)
			if not ok then
				return nil, err
			end
		end

		return true
	end))

	log:info("Dependencies installed succesfully!")
end

return deps
