local util = require 'loverocks.util'
local log = require 'loverocks.log'
local purge = {}

function purge:build(parser)
	parser:description "Remove all dependencies/internal loverocks state."
end

function purge:run(args)
	util.luarocks("purge")
end

return purge
