local loadconf = require 'loverocks.loadconf'
local api      = require 'loverocks.api'
local log      = require 'loverocks.log'

local purge = {}

function purge.build(parser)
	parser:description "Remove all dependencies/internal loverocks state."
end

function purge.run(args)
	local conf = assert(loadconf.require(args.game))
	local flags = api.make_flags(conf)

	log:fs("luarocks purge --tree=" .. (flags.tree or "rocks"))
	log:assert(api.in_luarocks(flags, function()
		local lr_purge = require 'luarocks.purge'

		return lr_purge.run("--tree=" .. (flags.tree or "rocks"))
	end))
end

return purge
