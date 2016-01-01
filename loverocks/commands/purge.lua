local api = require 'loverocks.api'
local log = require 'loverocks.log'

local purge = {}

function purge:build(parser)
	parser:description "Remove all dependencies/internal loverocks state."
end

function purge:run(args)
	local flags = {}

	log:fs("luarocks purge --tree=rocks")
	log:assert(api.in_luarocks(flags, function()
		local lr_purge = require 'luarocks.purge'

		return lr_purge.run("--tree=rocks")
	end))
end

return purge
