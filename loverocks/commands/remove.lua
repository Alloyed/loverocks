local log      = require 'loverocks.log'
local luarocks = require 'loverocks.luarocks'

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

function remove.run(conf, args)
	local flags = luarocks.make_flags(conf)

	for _, pkg in ipairs(args.packages) do
		local lr_args = {}
		lr_args.force = args.force
		log:info("Removing %q", pkg)

		log:fs("luarocks remove %s%s", pkg, args.force and " --force" or "")
		log:assert(luarocks.sandbox(flags, function()
			local lr_remove = require 'luarocks.cmd.remove'
			local NO_VERSION = nil
			return lr_remove.command(lr_args, pkg, NO_VERSION)
		end))
	end
end

return remove
