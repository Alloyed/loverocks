local lr_purge = require 'luarocks.purge'
local api = require 'loverocks.api'
local log = require 'loverocks.log'
local purge = {}

function purge:build(parser)
	parser:description "Remove all dependencies/internal loverocks state."
end

function purge:run(args)
	local flags = {}
	api.check_flags(flags)
	log:assert(lr_purge.run("--tree=rocks"))
	api.restory_flags(flags)
end

return purge
