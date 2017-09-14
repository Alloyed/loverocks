local log      = require 'loverocks.log'
local luarocks      = require 'loverocks.luarocks'

local install = {}

function install.build(parser)
	parser:description
		"Installs a package manually."
	parser:argument "packages"
		:args("+")
		:description
			"The packages to install."
	parser:flag "--only-deps"
		:description(
			"Only install the packages dependencies. "..
			"Analogous to apt-get build-dep.")
	parser:option "-s" "--server"
		:description
			"Fetch rocks/rockspecs from this server as a priority."
	parser:option "--only-server"
		:description
			"Fetch rocks/rockspecs from this server, ignoring other servers."
end

function install.run(conf, args)
	local flags = luarocks.make_flags(conf)
	flags.init_rocks = true

	if args.server then
		table.insert(flags.from, 1, args.server)
	end

	if args.only_server then
		flags.only_from = args.only_server
	end

	for _, pkg in ipairs(args.packages) do
		local lr_args = {pkg} -- TODO: specify versions

		if args.only_deps then
			table.insert(lr_args, "--only-deps")
			log:info("Installing dependencies for %q", pkg)
		else
			log:info("Installing %q", pkg)
		end

		log:fs("luarocks install %s", table.concat(lr_args, " "))
		log:assert(luarocks.sandbox(flags, function()
			local lr_install = require 'luarocks.install'
			return lr_install.run(unpack(lr_args))
		end))
	end

end

return install
