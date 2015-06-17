local log = require 'loverocks.log'
local util = require 'loverocks.util'
local list = {}

function list:build(parser)
	parser:description "List installed dependencies."
	parser:argument "filter"
		:args("*")
		:description "Only return dependencies matching this substring."
	parser:flag "--outdated"
		:description "Only return dependencies that have newer versions available."
end

function list:run(args)
	util.luarocks("list")
end

return list
