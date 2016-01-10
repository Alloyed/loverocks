local loadconf = require 'loadconf'
local log      = require 'loverocks.log'
local api      = require 'loverocks.api'

local remove = {}

function remove.build(parser)
	parser:description
		"Uninstalls a package manually."
	parser:argument "packages"
		:args("+")
		:description
			"The packages to remove."
	parser:flag "--force"
		:description
			"Remove package, even if required by other packages"
end

function remove.run(args)
	local conf = log:assert(loadconf.parse_file("./conf.lua"))

	local flags = api.make_flags(conf)

	for _, pkg in ipairs(args.packages) do
		local version = "" -- TODO: specify versions
		log:info("Removing %q", pkg)
		log:fs("luarocks remove %s %s", pkg, version)

		log:assert(api.in_luarocks(flags, function()
			local lr_remove = require 'luarocks.remove'
			if args.force then
				return lr_remove.run(pkg, "--force")
			else
				return lr_remove.run(pkg)
			end
		end))
	end
end

return remove
