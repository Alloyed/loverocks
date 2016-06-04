local luarocks  = require 'loverocks.luarocks'
local log  = require 'loverocks.log'

local list = {}

function list.build(parser)
	parser:description "List installed dependencies."
	parser:argument "filter"
		:args("*")
		:description "Only return dependencies matching this substring."
	parser:flag "--outdated"
		:description "Only return dependencies that have newer versions available."
end

function list.run(conf, args)
	local flags = luarocks.make_flags(conf)
	if args.outdated then
		flags.outdated = true
	end

	local f = {table.concat(args.filter, " ")}
	if flags.outdated then
		table.insert(f, "--outdated")
	end
	if flags.porcelain then
		table.insert(f, "--porcelain")
	end

	log:fs("luarocks list %s", table.concat(f, " "))
	log:assert(luarocks.sandbox(flags, function()
		local lr_list = require 'luarocks.list'

		return lr_list.run(unpack(f))
	end))
end

return list
