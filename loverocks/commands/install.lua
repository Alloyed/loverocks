local loadconf = require 'loadconf'
local log      = require 'loverocks.log'
local api      = require 'loverocks.api'

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

function install.run(args)
	local conf = log:assert(loadconf.parse_file("./conf.lua"))

	local flags = api.make_flags(conf)
	if args.server then
		table.insert(flags.from, 1, args.server)
	end
	if args.only_server then
		flags.only_from = args.only_server
	end

	for _, pkg in ipairs(args.packages) do
		local version = "" -- TODO: specify versions
		log:info("Installing %q", pkg)
		log:fs("luarocks install %s %s", pkg, version)

		log:assert(api.in_luarocks(flags, function()
			local lr_install = require 'luarocks.install'
			return lr_install.run(pkg)
		end))
	end

end

return install
