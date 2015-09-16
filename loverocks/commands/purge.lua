local util = require 'loverocks.util'
local log = require 'loverocks.log'
local api = require 'loverocks.api'
local purge = {}

function purge:build(parser)
	parser:description "Remove all dependencies/internal loverocks state."
end

function purge:run(args)
	log:assert(api.purge())
end

return purge
