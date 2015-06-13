local log = require 'loverocks.log'
local util = require 'loverocks.util'
local list = {}

function list:build(parser)
	parser:description "List installed dependencies."
end

function list:run(args)
	util.luarocks("list")
end

return list
