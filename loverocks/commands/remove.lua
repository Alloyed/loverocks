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
		local lr_args = {pkg}
		if args.force then
			table.insert(lr_args, "--force")
		end
		log:info("Removing %q", pkg)
		log:fs("luarocks remove %s", table.concat(lr_args, " "))

		log:assert(luarocks.sandbox(flags, function()
			local lr_remove = require 'luarocks.remove'
			return lr_remove.run(unpack(lr_args))
		end))
	end
end

return remove
