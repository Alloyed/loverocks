local util = require 'loverocks.util'
local log  = require 'loverocks.log'
local api  = require 'loverocks.api'

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

local function fmt_table(t)
	local s = "{"
	local sep = "\n   " -- FIXME: configurable indents

	for _, v in ipairs(t) do
		s = s .. sep .. string.format("%q", v)
		sep = ",\n   "
	end

	return s .. "\n}"
end

function install.run(args)
	local flags = {
		quiet = false,
		from = args.server,
		only_from = args.only_server
	}

	for _, pkg in ipairs(args.packages) do
		local version = "" -- FIXME: specify versions
		log:info("Installing %q", pkg)
		log:fs("luarocks install %s %s", pkg, version)

		log:assert(api.in_luarocks(flags, function()
			local lr_install = require 'luarocks.install'
			return lr_install.run(pkg)
		end))
	end

end

return install
