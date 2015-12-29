local lr_list = require 'luarocks.list'
local log = require 'loverocks.log'
local api  = require 'loverocks.api'
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
	local flags = {}
	if args.outdated then flags.outdated = true end
	api.check_flags(flags)

	local f = {table.concat(args.filter, " ")}
	if flags.outdated then
		table.insert(f, "--outdated")
	end
	if flags.porcelain then
		table.insert(f, "--porcelain")
	end

	log:fs("luarocks list %s", table.concat(f, " "))
	log:assert(lr_list.run(unpack(f)))
	api.restore_flags(flags)
end

return list
