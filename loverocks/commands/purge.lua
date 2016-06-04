local luarocks = require 'loverocks.luarocks'
local log      = require 'loverocks.log'

local purge = {}

function purge.build(parser)
	parser:description "Remove all dependencies/internal loverocks state."
end

function purge.run(conf, args)
	assert(type(args) == 'table')
	local flags = luarocks.make_flags(conf)

	log:fs("luarocks purge --tree=" .. (flags.tree or "rocks"))
	log:assert(luarocks.sandbox(flags, function()
		local lr_purge = require 'luarocks.purge'

		return lr_purge.run("--tree=" .. (flags.tree or "rocks"))
	end))
end

return purge
